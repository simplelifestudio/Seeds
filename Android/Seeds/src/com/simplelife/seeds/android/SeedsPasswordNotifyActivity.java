package com.simplelife.seeds.android;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.TextView;

public class SeedsPasswordNotifyActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		// Get the message from intent
		Intent intent = getIntent();
		String message = intent.getStringExtra(SeedsPasswordActivity.EXTRA_MESSAGE);
		
	    verifyPassword(message);

	}
	
	private void verifyPassword(String inMessage){
		
		if (inMessage.equals("chris717")){
			Intent intent = new Intent(this, SeedsDateListActivity.class);
			startActivity(intent);
			finish();
		}
		else
		{
			// Create the text view
		    TextView textView = new TextView(this);
		    textView.setTextSize(40);
		    textView.setText(inMessage);
			
		    // This line is added to identify the changes via EGit
		    // By Chris -- simplelife.chris@gamil.com
		    setContentView(textView);
		    //setContentView(R.layout.activity_display_message);
			// Show the Up button in the action bar.
			//getActionBar().setDisplayHomeAsUpEnabled(true);
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_seeds_start_display_message, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case android.R.id.home:
			// This ID represents the Home or Up button. In the case of this
			// activity, the Up button is shown. Use NavUtils to allow users
			// to navigate up one level in the application structure. For
			// more details, see the Navigation pattern on Android Design:
			//
			// http://developer.android.com/design/patterns/navigation.html#up-vs-back
			//
			NavUtils.navigateUpFromSameTask(this);
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

}