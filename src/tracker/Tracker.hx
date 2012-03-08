/*
 Copyright (c) 2012, Ian Martins (ianxm@jhu.edu)

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
*/
package tracker;

using Lambda;
using StringTools;
import neko.Lib;
import neko.Sys;
import neko.io.File;
import neko.FileSystem;
import neko.db.Sqlite;
import neko.db.Connection;
import neko.db.Manager;
import altdate.Gregorian;
import tracker.Main;
import utils.Utils;

class Tracker
{
    private var dbFile  :String;
    private var metrics :List<String>;
    private var range   :Array<Gregorian>;
    private var db      :Connection;

    public function new(f, m, r)
    {
        dbFile = f;
        metrics = m;
        range = r;
    }

    // create db file
    public function init()
    {
        if( FileSystem.exists(dbFile) )
            throw "cannot init an existing repository";
        db = Sqlite.open(dbFile);
        Lib.println("creating repository: " + neko.FileSystem.fullPath(dbFile));
        db.request("CREATE TABLE metrics (" +
                   "id INTEGER PRIMARY KEY, " +
                   "name TEXT UNIQUE NOT NULL)");
        db.request("CREATE TABLE occurrences (" +
                   "metricId INTEGER NOT NULL REFERENCES metric (id) ON DELETE SET NULL, " +
                   "date DATE NOT NULL, " +
                   "value REAL NOT NULL, " +
                   "CONSTRAINT key PRIMARY KEY (metricId, date))");
        db.request("CREATE VIEW full AS SELECT " +
                   "metrics.id AS metricId, metrics.name AS metric, occurrences.date AS date, occurrences.value AS value " +
                   "from metrics, occurrences " +
                   "where occurrences.metricId=metrics.id");
    }

    // open db file
    private function connect()
    {
        if( !FileSystem.exists(dbFile) )
            throw "repository doesn't exist, you must run 'init' first";
        db = Sqlite.open(dbFile);
    }

    // get list of existing metrics
    public function info()
    {
        connect();
        var allMetrics = getAllMetrics();
        if( allMetrics.isEmpty() )
        {
            Lib.println("No metrics found");
            return;
        }

        var nameWidth = allMetrics.fold(function(name,width:Int) return Std.int(Math.max(name.length,width)), 5);
        var count;
        var firstDate = null;
        var lastDate = null;
        var buf = new StringBuf();
        var padding = Math.round((nameWidth-"metric".length)/2);
        for( ii in 0...padding )
            buf.add(" ");
        buf.add("metric");
        for( ii in 0...padding )
            buf.add(" ");
        buf.add(" count  first       last      days\n");
        for( metric in allMetrics  )
        {
            count = 0;
            firstDate = null;
            metrics = [metric].list();
            var occurrences = selectRange([null, null], false);
            for( occ in occurrences )
            {
                if( firstDate == null )
                    firstDate = Utils.dayFromJulian(occ.date);
                lastDate = Utils.dayFromJulian(occ.date);
                count++;
            }
            var duration = lastDate.value-firstDate.value + 1;
            buf.add(metric.rpad(" ",nameWidth) +"  "+ 
                    Std.string(count).lpad(" ",3) + 
                    "  "+ firstDate +"  "+ lastDate +
                    "  "+ Std.string(duration).lpad(" ",4) + "\n");
        }
        Lib.println(buf.toString());
    }

    // output all metrics as a csv
    public function exportCsv(fname)
    {
        connect();
        checkMetrics();                                     // check that all requested metrics exist

        var fout = if( fname != null )
        {
            if( FileSystem.exists(fname) )
                throw "file exists: " + FileSystem.fullPath(fname);
            else
                try {
                    File.write(fname);
                } catch( e:Dynamic ) {
                    throw "couldn't open output file: " + fname;
                }
        }
        else
            File.stdout();

        var occurrences = selectRange(range, false);
        fout.writeString("date,metric,value\n");
        for( rr in occurrences )
            fout.writeString(Utils.dayFromJulian(rr.date).toString() +","+ rr.metric +","+ rr.value +"\n");
        fout.close();
    }

    // import metrics from a csv
    public function importCsv(fname)
    {
        connect();

        if( !FileSystem.exists(fname) )
            throw "file not found: " + fname;
        var fin = File.read(fname);
        try
        {
            while( true )
            {
                var line = fin.readLine();
                var fields = line.split(",").map(function(ii) return StringTools.trim(ii)).array();
                var day;
                try {
                    day = Utils.dayFromString(fields[0]);
                } catch( e:String ) {
                    Lib.println("bad date, skipping line: " + line);
                    continue;
                }
                var val = Std.parseFloat(fields[2]);
                if( Math.isNaN(val) )
                {
                    Lib.println("bad value, skipping line: " + line);
                    continue;
                }
                var metricId = getOrCreateMetric(fields[1]);
                setOrUpdate(fields[1], metricId, day, val);
            }
        } catch( e:haxe.io.Eof ) {
        }
        fin.close();
    }

    // run the report generator to view the data
    public function view(cmd, groupType, valType, tail)
    {
        connect();
        checkMetrics();                                     // check that all requested metrics exist

        var reportGenerator = new ReportGenerator(tail);
        reportGenerator.setReport(cmd, groupType, valType);

        if( range[0] != null )                              // start..
            reportGenerator.include(range[0], Main.NO_DATA);

        var occurrences = selectRange(range);
        for( occ in occurrences )
            reportGenerator.include(Utils.dayFromJulian(occ.date), occ.value);

                                                            // ..end (cant be null)
        reportGenerator.include(range[1], Main.NO_DATA);

        reportGenerator.print();
    }

    // increment values
    public function incr(val)
    {
        connect();
        for( metric in metrics )
        {
            var metricId = getOrCreateMetric(metric);
            var day = range[0];
            do
            {
                var rs = db.request("SELECT value FROM occurrences WHERE metricId='"+ metricId +"' AND date='"+ day.toString() +"'");
                var val = if( rs.length != 0 )
                    rs.next().value+val;
                else
                    val;
                setOrUpdate( metric,  metricId, day, val );

                day.day += 1;
            } while( range[1]!=null && range[1].value-day.value>=0 );
        }
    }

    // set values
    public function set(val)
    {
        connect();
        for( metric in metrics )
        {
            var metricId = getOrCreateMetric(metric);
            var day = range[0];
            do
            {
                setOrUpdate( metric, metricId, day, val );
                day.day += 1;
            } while( range[1]!=null && range[1].value-day.value>=0 );
        }
    }

    // get a metric id, create it if it doesn't exist
    private function getOrCreateMetric(metric :String) :Int
    {
        var rs = db.request("SELECT id FROM metrics WHERE name="+ db.quote(metric));
        return if( rs.length != 0 )
            rs.next().id;
        else
        {                                                   // add metric if its new
            db.request("INSERT INTO metrics VALUES (null, "+ db.quote(metric) +")");
            getOrCreateMetric(metric);
        }
    }

    // set a value 
    private function setOrUpdate(metric :String, metricId :Int, day :Gregorian, val :Float)
    {
        db.request("INSERT OR REPLACE INTO occurrences VALUES ('"+ metricId +"','"+ day.value +"','"+ val +"')");
        Lib.println("set " + metric + " to " + val + " for " + day);
    }

    // clear values
    public function remove()
    {
        var count = 0;
        connect();
        checkMetrics();
        var occurrences = selectRange(range, false).results().map(function(ii) return {metricId: ii.metricId, metric: ii.metric, date: ii.date});
        for( occ in occurrences )
        {
            var date = Utils.dayFromJulian(occ.date);
            db.request("DELETE FROM occurrences WHERE metricId='"+ occ.metricId +"' AND date='"+ date.value +"'");
            Lib.println("removed " + occ.metric + " for " + date.toString());
            count++;
        }
        if( count == 0 )
            Lib.println("didn't find anything to remove");
        else
            for( metric in metrics )                        // remove metrics with no occurrences
            {
                var metricId = getOrCreateMetric(metric);
                var count = db.request("SELECT count(metricId) FROM occurrences WHERE metricId='"+ metricId +"'").getIntResult(0);
                if( count == 0 )
                {
                    db.request("DELETE FROM metrics WHERE id='"+ metricId + "'");
                    Lib.println("removed the last occurrence for " + metric);
                }
            }
    }

    // check that metrics exist, replace splat
    private function checkMetrics()
    {
        if( metrics.exists(function(ii) return ii=="*") )
            metrics = getAllMetrics().list();
        else
        {
            var allMetrics = getAllMetrics();
            for( metric in metrics )
                if( !allMetrics.has(metric) )
                    throw "unknown metric: " + metric;
        }
    }

    // get a set of all metrics in the db
    private function getAllMetrics()
    {
        var rs = db.request("SELECT name FROM metrics");
        return rs.results().map(function(ii) return ii.name);
    }

    // select a date range from the db
    private function selectRange(range :Array<Gregorian>, ?shouldCombine = true)
    {
        var rs = db.request("SELECT name FROM metrics");
        if( rs.length == 0 )
        {
            Lib.println("No metrics found");
            Sys.exit(0);
        }

        var select = new StringBuf();
        select.add("SELECT ");
        select.add((shouldCombine) ? "metric, date, sum(value) AS value " : "* ");
        select.add("FROM full WHERE ("+ metrics.map(function(ii) return "metric="+db.quote(ii)).join(" OR ") +") ");
        if( range[0]!=null )                               // start..
            select.add("AND date >= '"+ range[0].value +"' ");
        if( range[1]!=null )                               // ..end
            select.add("AND date <= '"+ range[1].value +"' ");
        select.add((shouldCombine) ? "GROUP BY date " : " ");
        select.add("ORDER BY date");

        return db.request(select.toString());
    }

    // close db file
    public function close()
    {
        db.close();
    }
}
