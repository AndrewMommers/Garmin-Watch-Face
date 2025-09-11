import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// This is the main application class for the watch face.
class MommersMilitaryApp extends Application.AppBase {

    // Constructor for the app.
    function initialize() {
        AppBase.initialize();
    }

    // This function is called when your application is starting up.
    // For a simple watch face, this can be left empty.
    function onStart(state as Dictionary?) as Void {
    }

    // This function is called when your application is shutting down.
    // For a simple watch face, this can be left empty.
    function onStop(state as Dictionary?) as Void {
    }

    // This is the most important function in this file.
    // It returns the initial view of your application.
    function getInitialView() as Array<Views or InputDelegates>? {
        // This line creates a new instance of your main View and returns it.
        return [ new MommersMilitaryView() ];
    }

}

// This function is used to get a reference to the main app object.
function getApp() as MommersMilitaryApp {
    return Application.getApp() as MommersMilitaryApp;
}