using Toybox.Application;

class BubblesApp extends Application.AppBase {

	var view;
	
    function initialize() {
        AppBase.initialize();
        PropertiesHelper.loadProperties();
    }

    // onStart() is called on application start up
    function onStart(state) {
	    System.print(">>>>> on start");
		
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
        System.print(">>>>> on stop");
    }

    // Return the initial view of your application here
    function getInitialView() {
		view =  new BubblesView();
		return [ view ];
    }
    
    function onSettingsChanged(){
		PropertiesHelper.loadProperties();
	}

}