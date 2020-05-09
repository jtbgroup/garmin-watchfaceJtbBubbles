using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time.Gregorian as Calendar;
using JTBUtils as Utils;
using BubblesConstants as Cst;
using JTBComponents as Compo;

class BubblesView extends Ui.WatchFace {

	var COLOR_FOREGROUND = Gfx.COLOR_WHITE;
	var COLOR_TRANSPARENT= Gfx.COLOR_TRANSPARENT;

	//CONSTANTS
	hidden var ANGLE_MINUTE = 6;
	hidden var ANGLE_SECOND = 6;
//	hidden var RADIUS_BUBBLE_SECOND = 5;
	
	hidden const FONT_ICON_CHAR_ALARM="0";
	hidden const FONT_ICON_CHAR_BLUETOOTH="1";
	hidden const FONT_ICON_CHAR_NOTIFICATION="2";
	hidden const FONT_ICON_CHAR_SATELLITE="3";
	
	//INSTANCE VARIBLES
	//properties
	hidden var colorBackground, colorHour, colorMinute, colorSecond, colorBubbleBorder, colorDate, colorTextHour, colorTextMinute;
	hidden var iconColorAlarm, iconColorBluetooth, iconColorNotification;
	hidden var hourMode, dateFormat, orbitDistanceHour, orbitDistanceMinute, orbitDistanceSecond, orbitWidthHour, orbitWidthMinute, orbitWidthSecond; 
	hidden var showOrbitHour, showOrbitMinute, showOrbitSecond, showDate, showAlarm, showBattery, showNotification, showBluetooth;
	hidden var fontIcons, fontHour, fontMinute, fontDate;
	//coordinates
	hidden var co_Screen_Width, co_Screen_Height;
	hidden var batteryComponent;
	hidden var radiusBubbleHour, radiusBubbleMinute;
	hidden var angleHour;
	hidden var sleeping=false;
	hidden var dc;
	

    function onLayout(dc){
    	me.dc = dc;
    	fontIcons = Ui.loadResource(Rez.Fonts.fontIcons);
    	reloadBasics (false);
    	computeCoordinates(dc);
    	
    	if(showBattery){
    		createBattery();
    	}
    
    }
    
    function createBattery(){
    	if(null == batteryComponent){
	    	batteryComponent = new Compo.BatteryComponent({
				:locX=>co_Screen_Width/2,
				:locY=>co_Screen_Height - 15,
				:bgc=>COLOR_TRANSPARENT,
				:fgc=>COLOR_FOREGROUND,
				:dc=>dc,
				:font=>null,
				:showText=>false
			});
		}
    }
    
    function computeCoordinates(dc){
    	//get screen dimensions
		co_Screen_Width = dc.getWidth();
        co_Screen_Height = dc.getHeight();
     }

 	function reloadBasics(reloadComponents){
    	reloadBasicColors();
    	reloadFonts();
    	reloadShows();
    	reloadMetrics();
    	if(reloadComponents){
	    	reloadComponents();
    	}
    }
    
    function reloadFonts(){
    	fontHour = Utils.getPropertyAsFont(Cst.PROP_FONT_SIZE_CLOCK_HOUR);
    	fontMinute = Utils.getPropertyAsFont(Cst.PROP_FONT_SIZE_CLOCK_MINUTE);
    	fontDate = Utils.getPropertyAsFont(Cst.PROP_FONT_SIZE_DATE);
    }
    
    
    function reloadShows(){
    	showNotification = Utils.getPropertyValue(Cst.PROP_SHOW_NOTIFICATION);
    	showDate = Utils.getPropertyValue(Cst.PROP_SHOW_DATE);
    	showBattery = Utils.getPropertyValue(Cst.PROP_SHOW_BATTERY);
    	showAlarm = Utils.getPropertyValue(Cst.PROP_SHOW_ALARM);
    	showBluetooth = Utils.getPropertyValue(Cst.PROP_SHOW_BLUETOOTH);
    
    	showOrbitHour = Utils.getPropertyValue(Cst.PROP_SHOW_ORBIT_HOUR);
		showOrbitMinute = Utils.getPropertyValue(Cst.PROP_SHOW_ORBIT_MINUTE);
		showOrbitSecond = Utils.getPropertyValue(Cst.PROP_SHOW_ORBIT_SECOND);
    }
    
    function reloadComponents(){
    	createBattery();
  		batteryComponent.setForegroundColor(COLOR_FOREGROUND);
    }
    
	function reloadMetrics(){
		hourMode = Utils.getPropertyValue(Cst.PROP_HOUR_MODE);
		dateFormat = Utils.getPropertyValue(Cst.PROP_DATE_FORMAT);
		orbitDistanceHour = Utils.getPropertyValue(Cst.PROP_ORBIT_DISTANCE_HOUR);
		orbitDistanceMinute = Utils.getPropertyValue(Cst.PROP_ORBIT_DISTANCE_MINUTE);
		orbitDistanceSecond = Utils.getPropertyValue(Cst.PROP_ORBIT_DISTANCE_SECOND);
		orbitWidthHour = Utils.getPropertyValue(Cst.PROP_ORBIT_WIDTH_HOUR);
		orbitWidthMinute = Utils.getPropertyValue(Cst.PROP_ORBIT_WIDTH_MINUTE);
		orbitWidthSecond = Utils.getPropertyValue(Cst.PROP_ORBIT_WIDTH_SECOND);
		
		if(hourMode == Cst.OPTION_HOUR_MODE_24){
    		angleHour = 15;
    	}else{
    		angleHour = 30;
    	}
    	
    	radiusBubbleHour = getMax(dc.getTextDimensions("04", fontHour))/2;
    	radiusBubbleMinute = getMax(dc.getTextDimensions("44", fontMinute))/2;
	}
	
	function getMax(numberArray){
		var result = numberArray[0];
		for(var i = 1; i < numberArray.size(); i++){
			if(numberArray[i] > result){
				result = numberArray[i];
			}
		}
		return result;
	}
	
    function reloadBasicColors(){
    	colorBackground = Utils.getPropertyAsColor(Cst.PROP_COLOR_BACKGROUND);
	    colorHour = Utils.getPropertyAsColor(Cst.PROP_COLOR_CLOCK_HOUR);
    	colorMinute = Utils.getPropertyAsColor(Cst.PROP_COLOR_CLOCK_MINUTE);
    	colorSecond = Utils.getPropertyAsColor(Cst.PROP_COLOR_CLOCK_SECOND);
    	colorBubbleBorder = Utils.getPropertyAsColor(Cst.PROP_COLOR_BUBBLE_BORDER);
    	colorDate = Utils.getPropertyAsColor(Cst.PROP_COLOR_DATE);
    	colorTextHour = Utils.getPropertyAsColor(Cst.PROP_COLOR_CLOCK_TEXT_HOUR);
    	colorTextMinute = Utils.getPropertyAsColor(Cst.PROP_COLOR_CLOCK_TEXT_MINUTE);
    	
    	iconColorAlarm = Utils.getPropertyAsColor(Cst.PROP_ICON_COLOR_ALARM);
    	iconColorBluetooth = Utils.getPropertyAsColor(Cst.PROP_ICON_COLOR_BLUETOOTH);
    	iconColorNotification = Utils.getPropertyAsColor(Cst.PROP_ICON_COLOR_NOTIFICATION);
    }


    // Update the view
	function onUpdate(dc){
    	dc.setColor(COLOR_FOREGROUND, colorBackground);
    	dc.clear();
    	
    	if(showBattery){
	    	batteryComponent.draw(dc);
    	}
    	
    	if(showAlarm){
    		displayAlarm(dc);    	
    	}
    	
    	if(showNotification){
	    	displayNotifications(dc);
    	}

    	if(showBluetooth){
			displayBT(dc);
    	}
    	
    	if(showDate){
    		displayDate(dc);
    	}
    	
    	displayTime(dc);
    }
    
    function displayBT(dc){
    	if(System.getDeviceSettings().phoneConnected){
		    dc.setColor(iconColorBluetooth,COLOR_TRANSPARENT);
		    dc.drawText(co_Screen_Width - 5, co_Screen_Height/2, fontIcons, FONT_ICON_CHAR_BLUETOOTH, Gfx.TEXT_JUSTIFY_RIGHT | Gfx.TEXT_JUSTIFY_VCENTER);
		}
    }
    
    function displayAlarm(dc){
    	if(System.getDeviceSettings().alarmCount >= 1){
    		dc.setColor(iconColorAlarm,COLOR_TRANSPARENT);
		    dc.drawText(5, co_Screen_Height/2, fontIcons, FONT_ICON_CHAR_ALARM, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
		}
    }
    
     function displayNotifications(dc){
    	dc.setColor(COLOR_FOREGROUND, COLOR_TRANSPARENT);
		var notif = System.getDeviceSettings().notificationCount;
		if(notif>0){
			dc.setColor(iconColorNotification,COLOR_TRANSPARENT);
		    dc.drawText(co_Screen_Width/2, 10, fontIcons, FONT_ICON_CHAR_NOTIFICATION, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
		}
    }
    
    function displayDate(dc){
   		var info = Calendar.info(Time.now(), Time.FORMAT_SHORT);
   		
   		var data = [info.day.format("%02d"), info.month.format("%02d")];
   		if(dateFormat == Cst.OPTION_DATE_FORMAT_DDMM){
   			data = [info.day.format("%02d"), info.month.format("%02d")];
   		}else if(dateFormat == Cst.OPTION_DATE_FORMAT_MMDD){
   			data = [info.month.format("%02d"), info.day.format("%02d")];
   		}
   		
        var dateStr = Lang.format("$1$/$2$", data);
        dc.setColor(colorDate, COLOR_TRANSPARENT);
        var fh=dc.getFontHeight(fontDate);
        dc.drawText(co_Screen_Width/2,co_Screen_Height/2-fh/2, fontDate, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
    }
    
    function displayTime(dc){
        // Get and show the current time
        var clockTime = System.getClockTime();
        // var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
		
		displayMinutes(dc, clockTime.min);    
				
		var hour = clockTime.hour;
		if(hourMode == Cst.OPTION_HOUR_MODE_12 && hour > 12){
			hour = hour - 12;
		}
		displayHour(dc, hour); 

		if(!sleeping){
			displaySeconds(dc, clockTime.sec);
		}

    }
    
    
    function displaySeconds(dc, second){
    	var coord= getXY(second*ANGLE_SECOND, orbitDistanceSecond);
    	var coordX = coord[0];
    	var coordY = coord[1];
    	
    	//draw orbit
		if(showOrbitSecond){
			dc.setColor(colorSecond, colorBackground); 
			dc.setPenWidth(orbitWidthSecond);
			dc.drawCircle(co_Screen_Width/2, co_Screen_Height/2, orbitDistanceSecond);
			dc.setPenWidth(1);
		}
		
		//draw bubbles
		dc.setColor(colorSecond, COLOR_TRANSPARENT); 
		dc.drawText(coordX, coordY, fontIcons, FONT_ICON_CHAR_SATELLITE, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
//		dc.fillCircle(coordX, coordY, RADIUS_BUBBLE_SECOND);
//		dc.setColor(COLOR_BACKGROUND, Gfx.COLOR_TRANSPARENT); 
//		var fontH = dc.getFontHeight(FONT_HOUR);
//		dc.drawText(coordX, coordY-fontH/2, FONT_HOUR, hour.format("%02d"), Gfx.TEXT_JUSTIFY_CENTER);
    }  
    
    function displayHour(dc, hour){
		var coord= getXY(hour*angleHour, orbitDistanceHour);
    	var coordX = coord[0];
    	var coordY = coord[1];
		
		//draw orbit
		if(showOrbitHour){
			dc.setColor(colorHour, colorBackground); 
			dc.setPenWidth(orbitWidthHour);
			dc.drawCircle(co_Screen_Width/2, co_Screen_Height/2, orbitDistanceHour);
			dc.setPenWidth(1);
		}
		
		//draw bubbles
		dc.setColor( colorBubbleBorder, COLOR_TRANSPARENT); 
		dc.fillCircle(coordX, coordY, radiusBubbleHour+1);
		dc.setColor( colorHour, COLOR_TRANSPARENT); 
		dc.fillCircle(coordX, coordY, radiusBubbleHour);
		dc.setColor(colorTextHour, COLOR_TRANSPARENT); 
		dc.drawText(coordX, coordY, fontHour, hour.format("%02d"), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    }
    
    
    function displayMinutes(dc, minutes){
    	//6 degrees per minute
		var coord= getXY(minutes*ANGLE_MINUTE, orbitDistanceMinute);
    	var coordX = coord[0];
    	var coordY = coord[1];
    	
    	//draw orbit
    	if(showOrbitMinute){
    		dc.setColor(colorMinute, COLOR_TRANSPARENT);
    		dc.setPenWidth(orbitWidthMinute);
			dc.drawCircle(co_Screen_Width/2, co_Screen_Height/2, orbitDistanceMinute);
			dc.setPenWidth(1);
		}
		
		//draw bubbles
		dc.setColor( colorBubbleBorder, COLOR_TRANSPARENT); 
		dc.fillCircle(coordX, coordY, radiusBubbleMinute+1);
		dc.setColor(colorMinute, COLOR_TRANSPARENT);
		dc.fillCircle(coordX, coordY, radiusBubbleMinute);
		dc.setColor(colorTextMinute, COLOR_TRANSPARENT); 
		dc.drawText(coordX, coordY, fontMinute, minutes.format("%02d"), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    }

	// base angle is in degree
	function getXY (baseAngle, distance){
		var angle = baseAngle;
    	var cosAngle = Math.cos(Math.toRadians(angle));
    	var sinAngle = Math.sin(Math.toRadians(angle));
    	
    	var x = 0;
    	var y = 0;
    	
    	if(cosAngle > 0 && sinAngle >= 0){
    		var sideY = cosAngle * distance;
    		y = co_Screen_Height / 2 - sideY;
    		var sideX = sinAngle * distance;
    		x = co_Screen_Width/2 + sideX;
    	}else if (cosAngle < 0 && sinAngle > 0){
    		angle = 180 - baseAngle;
	    	cosAngle = Math.cos(Math.toRadians(angle));
	    	sinAngle = Math.sin(Math.toRadians(angle));
   	  		var sideY = cosAngle * distance;
    		var sideX = sinAngle * distance;
    		y = co_Screen_Height / 2 + sideY;
    		x = co_Screen_Width/2 + sideX;
    	}else if (cosAngle < 0 && sinAngle < 0){
    		angle = baseAngle - 180;
	    	cosAngle = Math.cos(Math.toRadians(angle));
	    	sinAngle = Math.sin(Math.toRadians(angle));
   	  		var sideY = cosAngle * distance;
    		var sideX = sinAngle * distance;
    		y = co_Screen_Height / 2 + sideY;
    		x = co_Screen_Width / 2 - sideX;
    	}else if (cosAngle > 0 && sinAngle < 0){
    		angle = 360 - baseAngle;
	    	cosAngle = Math.cos(Math.toRadians(angle));
	    	sinAngle = Math.sin(Math.toRadians(angle));
   	  		var sideY = cosAngle * distance;
    		var sideX = sinAngle * distance;
    		y = co_Screen_Height / 2 - sideY;
    		x = co_Screen_Width / 2 - sideX;
    	}
    	
    	return [x, y];
	}

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
   function onExitSleep() {
   		sleeping = false;
   		Ui.requestUpdate();
    }
   

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    	sleeping = true;
        Ui.requestUpdate();
    }

}
