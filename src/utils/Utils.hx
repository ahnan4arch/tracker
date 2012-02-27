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
package utils;

import neko.Lib;
import neko.Sys;

class Utils
{
    // get a dayStr (YYYY-MM-DD) from a date or string (parse the string to ensure 
    // it is properly formatted
    public static function dayStr( ?date :Date, ?str :String ) :String
    {
        var date = day(str, date);
        return (date==null) ? null : date.toString().substr(0, 10);
    }

    public static function day( ?str :String, ?date :Date ) :Date
    {
        if( date==null && day==null )
            return null;
        if ( str!=null )
        {
            if( str=="" )
                return null;
            try {
                date = Date.fromString(str);
            } catch ( e:Dynamic ) {
                throw "date must be YYYY-MM-DD";
            }
        }
        return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0);
    }

    inline public static function dayToStr( date :Date ) :String
    {
        return (date==null) ? null : date.toString().substr(0, 10);
    }

    inline public static function dayShift( date :Date, days :Int )
    {
        return new Date(date.getFullYear(), date.getMonth(), date.getDate()+days, 0, 0, 0);
    }

    inline public static function dayDelta( date1 :Date, date2 :Date ) :Int
    {
        return Std.int(Math.ceil((date2.getTime()-date1.getTime())/(1000*60*60*24)));
    }

    inline public static function tenths(val :Float) :Float
    {
        return Math.round(val*10)/10;
    }
}
