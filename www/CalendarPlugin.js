//
// PhoneGap Calendar Plugin
// Author: Felix Montanez 
// Created: 01-17-2012
//
// Contributors : 
// Michael Brooks
// Sean Bedford
// 


function CalendarPlugin() {
}

CalendarPlugin.prototype.createEvent = function (title, location, notes, startDate, endDate, allDay, successCallback, errorCallback) {
    if (typeof errorCallback != "function") {
        console.log("CalendarPlugin.createEvent failure: errorCallback parameter must be a function");
        return
    }

    if (typeof successCallback != "function") {
        console.log("CalendarPlugin.createEvent failure: successCallback parameter must be a function");
        return
    }
    cordova.exec(successCallback, errorCallback, "CalendarPlugin", "createEvent", [title, location, notes, startDate, endDate, allDay]);
};

CalendarPlugin.prototype.deleteEvent = function (title, location, notes, startDate, endDate, deleteAll, successCallback, errorCallback) {
    if (typeof errorCallback != "function") {
        console.log("CalendarPlugin.deleteEvent failure: errorCallback parameter must be a function");
        return
    }

    if (typeof successCallback != "function") {
        console.log("CalendarPlugin.deleteEvent failure: successCallback parameter must be a function");
        return
    }
    cordova.exec(successCallback, errorCallback, "CalendarPlugin", "deleteEvent", [title, location, notes, startDate, endDate, deleteAll]);
}

CalendarPlugin.prototype.findEvent = function (title, location, notes, startDate, endDate, successCallback, errorCallback) {
    if (typeof errorCallback != "function") {
        console.log("CalendarPlugin.findEvent failure: errorCallback parameter must be a function");
        return
    }

    if (typeof successCallback != "function") {
        console.log("CalendarPlugin.findEvent failure: successCallback parameter must be a function");
        return
    }
    cordova.exec(successCallback, errorCallback, "CalendarPlugin", "findEvent", [title, location, notes, startDate, endDate]);
}

CalendarPlugin.prototype.modifyEvent = function (title, location, notes, startDate, endDate, newTitle, newLocation, newNotes, newStartDate, newEndDate, successCallback, errorCallback) {
    if (typeof errorCallback != "function") {
        console.log("CalendarPlugin.modifyEvent failure: errorCallback parameter must be a function");
        return
    }

    if (typeof successCallback != "function") {
        console.log("CalendarPlugin.modifyEvent failure: successCallback parameter must be a function");
        return
    }
    cordova.exec(successCallback, errorCallback, "CalendarPlugin", "modifyEvent", [title, location, notes, startDate, endDate, newTitle, newLocation, newNotes, newStartDate, newEndDate]);
}

module.exports = new CalendarPlugin();