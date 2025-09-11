import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Time.Gregorian;
import Toybox.Position;
import Toybox.Weather;

class MommersMilitaryView extends WatchUi.WatchFace {

    // Member variable to hold the custom icon font
    private var iconsFont;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        // Load the custom font from resources and store it
        iconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // --- Clear the screen and draw custom graphics first ---
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(42, 275, 332, 100, 10);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, 5, Graphics.FONT_MEDIUM, "N", Graphics.TEXT_JUSTIFY_CENTER);

        // --- Call the parent onUpdate function to draw the layout from layout.xml ---
        View.onUpdate(dc);

        // --- Get all data and update the text labels ---
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$:$3$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d"), clockTime.sec.format("%02d")]);
        (View.findDrawableById("TimeLabel") as Text).setText(timeString);

        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_LONG);
        var dateString = Lang.format("$1$, $2$ $3$ $4$", [info.day_of_week, info.day, info.month, info.year]);
        (View.findDrawableById("DateLabel") as Text).setText(dateString);
        
        // Get Activity Info (contains HR, Steps, and Altitude)
        var activityInfo = ActivityMonitor.getInfo();

        var heartRate = activityInfo.currentHeartRate;
        var hrString = (heartRate != null) ? heartRate.toString() + " bpm" : "-- bpm";
        (View.findDrawableById("HeartRateLabel") as Text).setText("Heart Rate:\n" + hrString);

        // ** ADDED STEPS COUNTER **
        var steps = activityInfo.steps;
        var stepsString = (steps != null) ? steps.toString() : "0";
        (View.findDrawableById("StepsLabel") as Text).setText(stepsString + " Steps");

        var battery = System.getSystemStats().battery;
        // ** FIXED BATTERY ID **
        (View.findDrawableById("BatteryLevel") as Text).setText("Battery:\n" + battery.format("%d") + "%");

        var altitude = activityInfo.altitude;
        var altString = (altitude != null) ? altitude.format("%d") + " M" : "-- M";
        (View.findDrawableById("AltitudeLabel") as Text).setText("Altitude:\n" + altString);
        
        var utc = Gregorian.utcInfo(now, Time.FORMAT_SHORT);
        var zuluString = Lang.format("$1$:$2$ Z", [utc.hour.format("%02d"), utc.min.format("%02d")]);
        (View.findDrawableById("ZuluLabel") as Text).setText("Zulu:\n" + zuluString);

        (View.findDrawableById("GpsTitleLabel") as Text).setText("GPS");
        var positionInfo = Position.getInfo();
        var gpsString = "NO SIGNAL";
        if (positionInfo != null && positionInfo.accuracy != null && positionInfo.accuracy > Position.QUALITY_POOR) {
            var location = positionInfo.position.toDegrees();
            gpsString = formatLocation(location[0], location[1]);
        }
        (View.findDrawableById("GpsCoordsLabel") as Text).setText(gpsString);

        var conditions = Weather.getCurrentConditions();
        if (conditions != null) {
            // ** FIXED WEATHER ICON ID **
            var weatherIcon = View.findDrawableById("WeatherIconLabel") as Text;
            weatherIcon.setFont(iconsFont);
            var codepoint = getWeatherIconCodepoint(conditions.condition);
            weatherIcon.setText(codepoint.toChar().toString());
            
            var temp = conditions.temperature;
            var tempString = (temp != null) ? temp.format("%d") + "°C" : "--°C";
            // A simple way to get a text description for weather condition
            var conditionString = getConditionString(conditions.condition);
            (View.findDrawableById("WeatherLabel") as Text).setText(tempString + " " + conditionString);
        }
    }

    function formatLocation(lat as Float, lon as Float) as String {
        var latStr = Math.abs(lat).format("%.4f") + (lat >= 0 ? " N" : " S");
        var lonStr = Math.abs(lon).format("%.4f") + (lon >= 0 ? " E" : " W");
        return latStr + ", " + lonStr;
    }

    function getWeatherIconCodepoint(condition as Number) as Number {
        if (condition == Weather.CONDITION_CLEAR) { return 0xe518; } // sunny
        if (condition == Weather.CONDITION_PARTLY_CLOUDY) { return 0xe2bd; } // cloud
        if (condition == Weather.CONDITION_CLOUDY) { return 0xe2bd; } // cloud
        if (condition == Weather.CONDITION_RAIN) { return 0xf047; } // rainy
        if (condition == Weather.CONDITION_SNOW) { return 0xe81a; } // cloudy_snowing
        if (condition == Weather.CONDITION_THUNDERSTORM) { return 0xeb7d; } // thunderstorm
        if (condition == Weather.CONDITION_WINDY) { return 0xe867; } // air
        if (condition == Weather.CONDITION_FOG) { return 0xe317; } // fog
        return 0xe518; // Default to sunny
    }
    
    // ** ADDED HELPER FOR WEATHER TEXT **
    function getConditionString(condition as Number) as String {
        if (condition == Weather.CONDITION_CLEAR) { return "Clear"; }
        if (condition == Weather.CONDITION_PARTLY_CLOUDY) { return "P. Cloudy"; }
        if (condition == Weather.CONDITION_CLOUDY) { return "Cloudy"; }
        if (condition == Weather.CONDITION_RAIN) { return "Rain"; }
        if (condition == Weather.CONDITION_SNOW) { return "Snow"; }
        if (condition == Weather.CONDITION_THUNDERSTORM) { return "T-Storm"; }
        if (condition == Weather.CONDITION_WINDY) { return "Windy"; }
        if (condition == Weather.CONDITION_FOG) { return "Fog"; }
        return "N/A";
    }

    function onShow() as Void {}
    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}