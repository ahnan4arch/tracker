package tracker;

import neko.Lib;
import neko.Sys;
import neko.FileSystem;
import neko.db.Sqlite;
import neko.db.Connection;
import neko.db.Manager;
import utils.Utils;
import utils.Set;

class Tracker
{
    private var metrics :List<String>;
    private var db :Connection;

    public function new(m)
    {
        metrics = m;
        connect();
    }

    // open db file
    private function connect()
    {
        var exists = FileSystem.exists(Main.DB_FILE);
        db = Sqlite.open(Main.DB_FILE);
        if( !exists )
        {
            //trace("creating table");
            db.request("CREATE TABLE occurrence ("
                       + "metric TEXT NOT NULL, "
                       + "date TEXT NOT NULL, "
                       + "value INT NOT NULL);");
        }
        neko.db.Manager.cnx = db;
        neko.db.Manager.initialize();
    }

    // get list of existing metrics
    public function list()
    {
        if( Occurrence.manager.count()==0 )
        {
            Lib.println("No metrics found");
            return;
        }

        var allMetrics = new Set<String>();
        var occurrences = Occurrence.manager.search({}, false);
        for( rr in occurrences )
            allMetrics.add(rr.metric);

        Lib.println("Current Metrics:");
        for( metric in allMetrics )
            Lib.println("- "+ metric);
    }

    // run the report generator to view the data
    public function view(range, cmd)
    {
        var reportGenerator = new ReportGenerator(range);
        reportGenerator.setReport(cmd);
        var occurrences = selectRange(range);

        if( range[0] != null )                               // start..
            reportGenerator.include(Utils.day(range[0]), 0);

        for( occ in occurrences )
            reportGenerator.include(Utils.day(occ.date), occ.value);

        reportGenerator.include(Utils.day(range[1]), 0); // ..end (cant be null)

        reportGenerator.print();
    }

    // increment values
    public function incr(range)
    {
        for( metric in metrics )
        {
            var day = range[0];
            do
            {
                var occ = Occurrence.manager.getWithKeys({metric: metric, date: day});
                if( occ != null )
                {
                    occ.value++;
                    occ.update();
                    Lib.println("set " + occ.metric + " to " + occ.value + " for " + day);
                }
                else
                    setNew( metric, day, 1 );

                day = Utils.dayToStr(Utils.dayShift(Utils.day(day), 1));

            } while( range[1]!=null && Utils.dayDelta(Utils.day(day), Utils.day(range[1])) >= 0 );
        }
    }

    private  function setNew(metric, day, val)
    {
        var occ = new Occurrence();
        occ.metric = metric;
        occ.date = day;
        occ.value = val;
        occ.insert();
        Lib.println("set " + metric + " to " + val + " for " + day);
    }

    // set values (clear if val is 0)
    public function set(range, val)
    {
        for( metric in metrics )
        {
            var day = range[0];
            do
            {
                var occ = Occurrence.manager.getWithKeys({metric: metric, date: day});
                if( occ != null )
                {
                    if( val != 0 )
                    {
                        occ.value = val;
                        occ.update();
                        Lib.println("set " + metric + " to " + val + " for " + day);
                    }
                    else
                    {
                        occ.delete();
                        Lib.println("deleted " + metric + " for " + day);
                    }
                }
                else
                    if( val != 0 )
                        setNew(metric, day, val);

                day = Utils.dayToStr(Utils.dayShift(Utils.day(day), 1));
            } while( range[1]!=null && Utils.dayDelta(Utils.day(day), Utils.day(range[1])) >= 0 );
        }
    }

    // clear values
    public function clear(range)
    {
        var occurrences = selectRange(range, false);
        for( occ in occurrences )
        {
            occ.delete();
            Lib.println("deleted " + occ.metric + " for " + occ.date);
        }
    }

    // select a date range from the db
    private function selectRange(range, ?shouldCombine = true)
    {
        if( Occurrence.manager.count()==0 )
        {
            Lib.println("No metrics found");
            Sys.exit(0);
        }

        var select = new StringBuf();
        select.add("SELECT ");
        select.add((shouldCombine) ? "date, sum(value) as value" : "*");
        select.add(" FROM occurrence ");
        select.add("WHERE ("+ metrics.map(function(ii) return "metric='"+ii+"'").join(" or ") +")");
        if( range[0]!=null )                               // start..
            select.add(" AND date >= '"+ range[0] +"'");
        if( range[1]!=null )                               // ..end
            select.add(" AND date <= '"+ range[1] +"'");
        select.add((shouldCombine) ? " GROUP BY date" : " ");
        select.add(" ORDER BY date");

        //trace("select: " + select);
        return Occurrence.manager.objects(select.toString(), false);
    }

    // close db file
    public function close()
    {
        neko.db.Manager.cleanup();
        db.close();
    }
}
