using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time.Gregorian as Calendar;

class watchFaceJtbBubblesView extends Ui.WatchFace {

	var COLORS = [Gfx.COLOR_WHITE, Gfx.COLOR_LT_GRAY, Gfx.COLOR_DK_GRAY, Gfx.COLOR_BLACK, Gfx.COLOR_RED, Gfx.COLOR_DK_RED, Gfx.COLOR_ORANGE, Gfx.COLOR_YELLOW, Gfx.COLOR_GREEN, Gfx.COLOR_DK_GREEN, Gfx.COLOR_BLUE, Gfx.COLOR_DK_BLUE, Gfx.COLOR_PURPLE, Gfx.COLOR_PINK];
	var HOUR_MODE_12=0;
	var HOUR_MODE_24=1;
	var DATE_FORMAT_DDMM=0;
	var DATE_FORMAT_MMDD=1;

	var COLOR_FOREGROUND = Gfx.COLOR_WHITE;
	var COLOR_TRANSPARENT= Gfx.COLOR_TRANSPARENT;
	
	var HOUR_ANGLE = 0;
	var MIN_ANGLE = 0;
	var SEC_ANGLE = 0;
	var HOUR_RAD = 20;
	var MIN_RAD = 15;
	var SEC_RAD = 5;

	var FONT_HOUR = Gfx.FONT_SYSTEM_MEDIUM;
	var FONT_MIN = Gfx.FONT_SYSTEM_TINY;
	var FONT_DATE = Gfx.FONT_SYSTEM_XTINY;
	
	var iconBT, iconBell, iconEnveloppe = null;
	var screenWidth, screenHeight= 0;
	var sleeping=false;

	//PROPERTIES -- configurables
	var PROP_COLOR_BACKGROUND = Gfx.COLOR_BLACK;

	var PROP_DISTANCE_HOUR = 40;
	var PROP_DISTANCE_MINUTE = 80;
	var PROP_DISTANCE_SECOND = 110;

	var PROP_COLOR_HOUR = Gfx.COLOR_RED;
	var PROP_COLOR_MINUTE = Gfx.COLOR_BLUE;
	var PROP_COLOR_SECOND = Gfx.COLOR_GREEN;
	
	var PROP_ORBIT_HOUR = true;
	var PROP_ORBIT_MINUTE = true;
	var PROP_ORBIT_SECOND = true;
	
	var PROP_ORBIT_WIDTH_HOUR = 7;
	var PROP_ORBIT_WIDTH_MINUTE = 3;
	var PROP_ORBIT_WIDTH_SECOND = 1;
	
	var PROP_HOUR_MODE=HOUR_MODE_12;
	var PROP_DATE_FORMAT=DATE_FORMAT_DDMM;
	
    function onShow() {
    }
    
    function onLayout(dc){
    	iconEnveloppe = Ui.loadResource( Rez.Drawables.iconEnveloppe );
    	iconBell = Ui.loadResource( Rez.Drawables.iconBell );
    	iconBT = Ui.loadResource( Rez.Drawables.iconBT );
    	loadProperties();
    }

  function loadProperties(){
		try{
			PROP_HOUR_MODE = Application.Properties.getValue("PROP_HOUR_MODE");
		} catch (e instanceof InvalidKeyException) {
   			System.println(e.getErrorMessage());
		}
		
		try{
			PROP_DATE_FORMAT = Application.Properties.getValue("PROP_DATE_FORMAT");
		} catch (e instanceof InvalidKeyException) {
   			System.println(e.getErrorMessage());
		}
		
		try{
			PROP_COLOR_BACKGROUND = COLORS[Application.Properties.getValue("PROP_COLOR_BACKGROUND")];
		} catch (e instanceof InvalidKeyException) {
   			System.println(e.getErrorMessage());
		}
		
		try{
			PROP_COLOR_HOUR = COLORS[Application.Properties.getValue("PROP_COLOR_HOUR")];
		} catch (e instanceof InvalidKeyException) {
   			System.println(e.getErrorMessage());
		}
		
		try{
			PROP_COLOR_MINUTE = COLORS[Application.Properties.getValue("PROP_COLOR_MINUTE")];
		} catch (e instanceof InvalidKeyException) {
   			System.println(e.getErrorMessage());
		}
		
		try{
			PROP_COLOR_SECOND = COLORS[Application.Properties.getValue("PROP_COLOR_SECOND")];
		} catch (e instanceof InvalidKeyException) {
   			System.println(e.getErrorMessage());
		}
		
		
		try{
			PROP_ORBIT_HOUR = Application.Properties.getValue("PROP_ORBIT_HOUR");
		} catch (e instanceof InvalidKeyException) {
   			System.println(e.getErrorMessage());
		}
		
		try{
			PROP_ORBIT_MINUTE = Application.Properties.getValue("PROP_ORBIT_MINUTE");
		} catch (e instanceof InvalidKeyException) {
   			System.println(e.getErrorMessage());
		}
		try{
			PROP_ORBIT_SECOND = Application.Properties.getValue("PROP_ORBIT_SECOND");
		} catch (e instanceof InvalidKeyException) {
   			System.println(e.getErrorMessage());
		}
		
		try{
			PROP_DISTANCE_HOUR = Application.Properties.getValue("PROP_DISTANCE_HOUR");
		} catch (e instanceof InvalidKeyException) {
   			System.println(e.getErrorMessage());
		}
		
		try{
			PROP_DISTANCE_MINUTE = Application.Properties.getValue("PROP_DISTANCE_MINUTE");
		} catch (e instanceof InvalidKeyException) {
   			System.println(e.getErrorMessage());
		}
		
		try{
			PROP_DISTANCE_SECOND = Application.Properties.getValue("PROP_DISTANCE_SECOND");
		} catch (e instanceof InvalidKeyException) {
   			System.println(e.getErrorMessage());
		}
		
		try{
			PROP_ORBIT_WIDTH_HOUR = Application.Properties.getValue("PROP_ORBIT_WIDTH_HOUR");
		} catch (e instanceof InvalidKeyException) {
   			System.println(e.getErrorMessage());
		}
		try{
			PROP_ORBIT_WIDTH_MINUTE = Application.Properties.getValue("PROP_ORBIT_WIDTH_MINUTE");
		} catch (e instanceof InvalidKeyException) {
   			System.println(e.getErrorMessage());
		}
		try{
			PROP_ORBIT_WIDTH_SECOND = Application.Properties.getValue("PROP_ORBIT_WIDTH_SECOND");
		} catch (e instanceof InvalidKeyException) {
   			System.println(e.getErrorMessage());
		}
	
    }
    
    // Update the view
    function onUpdate(dc) {
    	MIN_ANGLE = 6;
    	SEC_ANGLE = 6;
		
		if(PROP_HOUR_MODE == HOUR_MODE_24){
    		HOUR_ANGLE = 15;
    	}else{
    		HOUR_ANGLE = 30;
    	}	

    	screenHeight = dc.getHeight();
    	screenWidth = dc.getWidth();
    	
    	dc.setColor(COLOR_FOREGROUND, PROP_COLOR_BACKGROUND);
    	dc.clear();
    	
    	displayAlarm(dc);    	
    	displayNotifications(dc);
		displayBT(dc);
    	displayTime(dc);
    	displayDate(dc);
    }
    
    function displayBT(dc){
    	if(System.getDeviceSettings().phoneConnected){
		    dc.drawBitmap(screenWidth - 13, screenHeight/2-8 , iconBT);	
		}
    }
    
    function displayAlarm(dc){
    	if(System.getDeviceSettings().alarmCount >= 1){
		    dc.drawBitmap(4, screenHeight/2-8 , iconBell);	
		}
    }
    
     function displayNotifications(dc){
    	dc.setColor(COLOR_FOREGROUND, COLOR_TRANSPARENT);
		var notif = System.getDeviceSettings().notificationCount;
		if(notif>0){
		    dc.drawBitmap(screenWidth/2 - 13, 5 , iconEnveloppe);
//			dc.drawText(64, heartR_y, FONT_SMALL, notif.toString(),Gfx.TEXT_JUSTIFY_LEFT);	    	
		}
    }
    
    function displayDate(dc){
   		var info = Calendar.info(Time.now(), Time.FORMAT_SHORT);
   		
   		var data = [info.day.format("%02d"), info.month.format("%02d")];
   		if(PROP_DATE_FORMAT == DATE_FORMAT_DDMM){
   			data = [info.day.format("%02d"), info.month.format("%02d")];
   		}else if(PROP_DATE_FORMAT == DATE_FORMAT_MMDD){
   			data = [info.month.format("%02d"), info.day.format("%02d")];
   		}
   		
        var dateStr = Lang.format("$1$/$2$", data);
        dc.setColor(COLOR_FOREGROUND, COLOR_TRANSPARENT);
        var fh=dc.getFontHeight(FONT_DATE);
        dc.drawText(screenWidth/2,screenHeight/2-fh/2, FONT_DATE, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
    }
    
    function displayTime(dc){
        // Get and show the current time
        var clockTime = System.getClockTime();
        // var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
		
		if(!sleeping){
			displaySeconds(dc, clockTime.sec);
		}
		
		displayMinutes(dc, clockTime.min);    
				
		var hour = clockTime.hour;
		if(PROP_HOUR_MODE == HOUR_MODE_12 && hour >= 12){
			hour = hour - 12;
		}
		displayHour(dc, hour); 
    }
    
    
    function displaySeconds(dc, second){
    	var coord= getXY(second*SEC_ANGLE, PROP_DISTANCE_SECOND);
    	var coordX = coord[0];
    	var coordY = coord[1];
    	
    	//draw orbit
		if(PROP_ORBIT_SECOND){
			dc.setColor(PROP_COLOR_SECOND, PROP_COLOR_BACKGROUND); 
			dc.setPenWidth(PROP_ORBIT_WIDTH_SECOND);
			dc.drawCircle(screenWidth/2, screenHeight/2, PROP_DISTANCE_SECOND);
			dc.setPenWidth(1);
		}
		
		//draw bubbles
		dc.setColor(PROP_COLOR_SECOND, PROP_COLOR_BACKGROUND);
		dc.fillCircle(coordX, coordY, SEC_RAD);
//		dc.setColor(COLOR_BACKGROUND, Gfx.COLOR_TRANSPARENT); 
//		var fontH = dc.getFontHeight(FONT_HOUR);
//		dc.drawText(coordX, coordY-fontH/2, FONT_HOUR, hour.format("%02d"), Gfx.TEXT_JUSTIFY_CENTER);
    }  
    
    function displayHour(dc, hour){
		var coord= getXY(hour*HOUR_ANGLE, PROP_DISTANCE_HOUR);
    	var coordX = coord[0];
    	var coordY = coord[1];
		
		//draw orbit
		if(PROP_ORBIT_HOUR){
			dc.setColor(PROP_COLOR_HOUR, PROP_COLOR_BACKGROUND); 
			dc.setPenWidth(PROP_ORBIT_WIDTH_HOUR);
			dc.drawCircle(screenWidth/2, screenHeight/2, PROP_DISTANCE_HOUR);
			dc.setPenWidth(1);
		}
		
		//draw bubbles
		dc.setColor(PROP_COLOR_HOUR, PROP_COLOR_BACKGROUND);
		dc.fillCircle(coordX, coordY, HOUR_RAD);
		dc.setColor(PROP_COLOR_BACKGROUND, Gfx.COLOR_TRANSPARENT); 
		var fontH = dc.getFontHeight(FONT_HOUR);
		dc.drawText(coordX, coordY-fontH/2, FONT_HOUR, hour.format("%02d"), Gfx.TEXT_JUSTIFY_CENTER);
    }
    
    
    function displayMinutes(dc, minutes){
    	//6 degrees per minute
		var coord= getXY(minutes*MIN_ANGLE, PROP_DISTANCE_MINUTE);
    	
    	var coordX = coord[0];
    	var coordY = coord[1];
    	
    	//draw orbit
    	if(PROP_ORBIT_MINUTE){
    		dc.setColor(PROP_COLOR_MINUTE, PROP_COLOR_BACKGROUND);
    		dc.setPenWidth(PROP_ORBIT_WIDTH_MINUTE);
			dc.drawCircle(screenWidth/2, screenHeight/2, PROP_DISTANCE_MINUTE);
			dc.setPenWidth(1);
		}
		
		//draw bubble
		dc.setColor(PROP_COLOR_MINUTE, PROP_COLOR_BACKGROUND);
		dc.fillCircle(coordX, coordY, MIN_RAD);
		dc.setColor(PROP_COLOR_BACKGROUND, Gfx.COLOR_TRANSPARENT); 
		var fontH = dc.getFontHeight(FONT_MIN);
		dc.drawText(coordX, coordY-fontH/2, FONT_MIN, minutes.format("%02d"), Gfx.TEXT_JUSTIFY_CENTER);
    }

	// bas angle is in degree
	function getXY (baseAngle, distance){
		var angle = baseAngle;
    	var cosAngle = Math.cos(Math.toRadians(angle));
    	var sinAngle = Math.sin(Math.toRadians(angle));
    	
    	var x = 0;
    	var y = 0;
    	
    	if(cosAngle > 0 && sinAngle >= 0){
    		var sideY = cosAngle * distance;
    		y = screenHeight / 2 - sideY;
    		var sideX = sinAngle * distance;
    		x = screenWidth/2 + sideX;
    	}else if (cosAngle < 0 && sinAngle > 0){
    		angle = 180 - baseAngle;
	    	cosAngle = Math.cos(Math.toRadians(angle));
	    	sinAngle = Math.sin(Math.toRadians(angle));
   	  		var sideY = cosAngle * distance;
    		var sideX = sinAngle * distance;
    		y = screenHeight / 2 + sideY;
    		x = screenWidth/2 + sideX;
    	}else if (cosAngle < 0 && sinAngle < 0){
    		angle = baseAngle - 180;
	    	cosAngle = Math.cos(Math.toRadians(angle));
	    	sinAngle = Math.sin(Math.toRadians(angle));
   	  		var sideY = cosAngle * distance;
    		var sideX = sinAngle * distance;
    		y = screenHeight / 2 + sideY;
    		x = screenWidth / 2 - sideX;
    	}else if (cosAngle > 0 && sinAngle < 0){
    		angle = 360 - baseAngle;
	    	cosAngle = Math.cos(Math.toRadians(angle));
	    	sinAngle = Math.sin(Math.toRadians(angle));
   	  		var sideY = cosAngle * distance;
    		var sideX = sinAngle * distance;
    		y = screenHeight / 2 - sideY;
    		x = screenWidth / 2 - sideX;
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
