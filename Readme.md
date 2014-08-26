# Calendar Plugin for Cordova / Phonegap #
This plugins allows (limited) access to the calendar APIs on iOS and Android


## Adding the Plugin to your project ##

1. `cordova plugin add fr.smile.cordova.calendar`
2. There is no step two

## Usage ##

Creating an event

```js
cordova.plugins.CalendarPlugin.createEvent(
    'Title of the event',
    'Location of the event',
    'Description of the event',
    0, // Start date as a timestamp in ms
    0, // End date as a timestamp in ms
    false, // Whether it is an all day event or not,
    successCallback, // function called on success
    errorCallback // function called on error
);
```

## Caveats ##

* The only API that is implemented is createEvent.  If you have a need for the other apis, feel free to implement them and send a pull request :) 
* On Android, this plugin uses an undocumented API (that was finally documented in Jelly Bean).  As such it may not work on pre 4.0 devices.

## Sources ##

The code in this plugin was mostly lifted from existing plugins and updated for the latest versions of cordova (3.x).

See
 
* [Phonegap-Calendar-Plugin-ios](https://github.com/felixactv8/Phonegap-Calendar-Plugin-ios)
* [Phonegap-Calendar-Plugin-android](https://github.com/tenforwardconsulting/Phonegap-Calendar-Plugin-android)

## License

[MIT License](http://en.wikipedia.org/wiki/MIT_License)
