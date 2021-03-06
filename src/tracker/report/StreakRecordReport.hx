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
package tracker.report;

using StringTools;
import altdate.Gregorian;
import tracker.Main;
import utils.Utils;
import tracker.report.RecordReport;

class StreakRecordReport implements Report
{
    private var startOfStreak    :Gregorian;
    private var lastDay          :Gregorian;
    private var val              :Float;

    private var bestVal          :Float;
    private var bestStartDate    :Gregorian;

    private var filterName       :String;
    private var isStreakOn       :Bool;
    private var isBest           :Float -> Float -> Bool;

    private var cmd              :Command;
    dynamic public function include(thisDay :Gregorian, val :Float) {}

    public function new(keep :FilterStrategy, c :Command)
    {
        cmd = c;

        bestVal = 0;
        bestStartDate = null;
        startOfStreak = null;
        lastDay = null;
        val = 0;

        switch( keep )
        {
        case KEEP_LOWEST:
            {
                filterName = "longest off streak: ";
                isBest = function(a,b) return a>=b;
                include = includeOff;
            }
        case KEEP_HIGHEST:
            {
                filterName = (cmd==STREAKS) ? "longest on streak: " : "highest burst: ";
                isBest = function(a,b) return a>=b;
                include = includeOn;
            }
        case KEEP_CURRENT:
            {
                filterName = (cmd==STREAKS) ? "current streak: " : "current burst: ";
                isBest = function(a,b) return true;
                include = includeCurrent;
            }
        }
    }

    public function toString()
    {
        var onOrOff = if( isStreakOn == null )
            "\n";
        else if( isStreakOn == true )
            " (on)\n";
        else
            " (off)\n";
        return if( bestStartDate == null )
            "none\n";
        else if( cmd == BURSTS )
            bestVal + " starting on " + bestStartDate +"\n";
        else if( bestVal == 1 )
            "  1 day  starting on " + bestStartDate + onOrOff;
        else
            Std.string(bestVal).lpad(' ',3) + " days starting on " + bestStartDate + onOrOff;
    }

    inline public function getLabel()
    {
        return filterName;
    }

    private function checkBest(checkDate :Gregorian, checkVal :Float)
    {
        if( isBest(checkVal, bestVal) )
        {
            bestStartDate = checkDate;
            bestVal = checkVal;
        }
    }

    // val may be zero for first and last call
    public function includeOff(occDay :Gregorian, occVal :Float)
    {
        if( lastDay == null )
            lastDay = occDay;

        var delta = Std.int(occDay.value-lastDay.value);
        checkBest(Utils.dayShift(lastDay, 1), delta-1);
        lastDay = occDay;
    }

    // val may be zero for first and last call
    public function includeOn(occDay :Gregorian, occVal :Float)
    {
        if( lastDay == null )
            lastDay = occDay;

        var delta = Std.int(occDay.value-lastDay.value);

        if( delta==1 && val>0)                              // extend current on streak
        {
            val += if( cmd==STREAKS )
                1;
            else if( Main.IS_NO_DATA(occVal) )
                0;
            else
                occVal;
        }
        else if( !Main.IS_NO_DATA(occVal) )                 // start new streak
        {
            startOfStreak = occDay;
            val = (cmd==STREAKS) ? 1 : occVal;
        }
        checkBest(startOfStreak, val);                      // check for new best
        lastDay = occDay;
    }

    // val may be zero for first and last call
    public function includeCurrent(occDay :Gregorian, occVal :Float)
    {
        if( lastDay == null )
            lastDay = occDay;

        var delta = Std.int(occDay.value-lastDay.value);

        if( delta==1  && !Main.IS_NO_DATA(occVal) )        // extend current on streak
            val += (cmd==STREAKS) ? 1 : occVal;
        else
        {
            if( !Main.IS_NO_DATA(occVal) )                  // start new on streak
            {
                startOfStreak = occDay;
                val = (cmd==STREAKS) ? 1 : occVal;
                isStreakOn = true;
            }
            else if( delta != 0 )                           // end of an off streak
            {
                startOfStreak = Utils.dayShift(lastDay, 1);
                val = delta;
                isStreakOn = false;
                bestStartDate = null;
            }
        }
        if( isStreakOn || cmd==STREAKS )
            checkBest(startOfStreak, val);                  // check for new best
        lastDay = occDay;
    }
}
