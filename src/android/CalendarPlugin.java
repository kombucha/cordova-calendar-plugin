// (c) 2013 Ten Forward Consulting, Inc. released under the MIT License
// Authored by Brian Samson (@samsonasu) and Ryan Behnke

package fr.smile.cordova.calendar;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import android.app.Activity;
import android.content.Intent;

public class CalendarPlugin extends CordovaPlugin {
	private static final String ACTION_ADD_TO_CALENDAR = "createEvent";
	private static final Integer RESULT_CODE_CREATE = 0;
	private static final SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

	private CallbackContext callback;

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

		try {
			if (ACTION_ADD_TO_CALENDAR.equals(action)) {
				callback = callbackContext;
				Intent calIntent = new Intent(Intent.ACTION_EDIT)
					.setType("vnd.android.cursor.item/event")
					.putExtra("title", args.getString(0))
					.putExtra("eventLocation", args.getString(1))
					.putExtra("description", args.getString(2))
					.putExtra("beginTime", args.getLong(3))
					.putExtra("endTime", args.getLong(4))
					.putExtra("allDay", args.getBoolean(5));

				this.cordova.startActivityForResult(this, calIntent, RESULT_CODE_CREATE);
				return true;
			}
		} catch(Exception e) {
			System.err.println("Exception: " + e.getMessage());
			callbackContext.error("Exception: " + e.getMessage());
			return false;
		}

		return false;
	}

	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(requestCode == RESULT_CODE_CREATE) {
			if(resultCode == Activity.RESULT_OK) {
				callback.success();
			} else {
				callback.error("Activity result code " + resultCode);
			}
		}
	}
}