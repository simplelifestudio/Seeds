package com.simplelife.seeds.android;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;

import org.apache.http.client.ClientProtocolException;
import org.json.JSONException;

import com.simplelife.seeds.android.Utils.NetworkProcess.SeedsNetworkProcess;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.widget.Button;

@SuppressLint("HandlerLeak")
public class SeedsDateListActivity extends Activity {

	private Button myBefYesterdayBtn;
	private Button myYesterdayBtn;
	private Button myTodayBtn;
	private Button myUpdateBtn;
	private Button myFavListBtn;
	private ProgressDialog tProgressDialog = null; 	
	
	// Date in string format
	private String mDateBefYesterday;
	private String mDateYesterday;
	private String mDateToday;
	private ArrayList<String>  mDateArray;
	private SharedPreferences mSharedPref;
	
	// Below two fields should be removed or changed in final version
	private int tSleepSeconds = 1; 
	
	// Handler message definition
	final int MESSAGETYPE_BEFYEST = 100;
	final int MESSAGETYPE_YESTERD = 101;
	final int MESSAGETYPE_TODAY   = 102;
	final int MESSAGETYPE_UPDATE  = 103;
	
	// For log purpose
	private static final String LOGCLASS = "SeedsDateList"; 
		
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		Log.i(LOGCLASS, "Working on starting the DateListActivity ");  
		
		// Start the DateList View
		setContentView(R.layout.activity_seeds_datelist);
		
		// Locate those buttons
		myBefYesterdayBtn = (Button) findViewById(R.id.befyesterday_btn);
		myYesterdayBtn    = (Button) findViewById(R.id.yesterday_btn);
		myTodayBtn   = (Button) findViewById(R.id.today_btn);
		myUpdateBtn  = (Button) findViewById(R.id.update_btn);
		myFavListBtn =  (Button) findViewById(R.id.favlist_btn);
		
		// Setup the click listener
		myBefYesterdayBtn.setOnClickListener(myBefYesterdayBtnListener);
		myYesterdayBtn.setOnClickListener(myYesterdayBtnListener);
		myTodayBtn.setOnClickListener(myTodayBtnListener);
		myFavListBtn.setOnClickListener(myFavListBtnListener);
		
		Log.i(LOGCLASS, "Working on setting the ProgressDialog style"); 
		// Set the progress style as spinner
		//tProgressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER); 
		myUpdateBtn.setOnClickListener(myUpdateBtnListener);
		
		// Calculate the date
		Calendar tCal = Calendar.getInstance();
		mDateToday = new SimpleDateFormat("yyyy-MM-dd").format(tCal.getTime());
		tCal.add(Calendar.DATE, -1);
		mDateYesterday = new SimpleDateFormat("yyyy-MM-dd").format(tCal.getTime());
		tCal.add(Calendar.DATE, -1);
		mDateBefYesterday = new SimpleDateFormat("yyyy-MM-dd").format(tCal.getTime());
		
		// Initialize the date array list
		mDateArray = new ArrayList<String> ();
		
		// Get the shared preference file instance
		mSharedPref = getSharedPreferences(
		        getString(R.string.seeds_preffilename), Context.MODE_PRIVATE);		
	}
	
	private View.OnClickListener myBefYesterdayBtnListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {
			// 1. Start the seeds update job, communicate with server
			// 2. Need a progress bar here.
			// Redirect to the seeds list page
			tProgressDialog = ProgressDialog.show(SeedsDateListActivity.this, "Loading...", "Please wait...", true, false);
			
			// Set up a thread to communicate with server
			new Thread() {
				
				@Override
				public void run() {
					try {
						// Only when the seeds info have not been updated
						if (!isSeedsInfoUpdated(mDateBefYesterday))
						{
						    // Populate the date array
						    mDateArray.clear();
						    mDateArray.add(mDateBefYesterday);
						
						    updateSeedsInfo(mDateArray);
						}
						
					} catch (Exception e) {
						// Show the error message here
					}
					Message t_MsgListData = new Message();
					t_MsgListData.what = MESSAGETYPE_UPDATE;
					handler.sendMessage(t_MsgListData);					
				}
			}.start();	
			
			Log.i(LOGCLASS, "Working on directing to the details ");
			// Redirect to the new page
			Intent intent = new Intent(SeedsDateListActivity.this, SeedsListPerDayActivity.class);
			// Pass the date info
		    Bundle bundle = new Bundle();
		    bundle.putString("date", "befyesterday");
		    intent.putExtras(bundle);
			startActivity(intent);
			
		}
	};
	
	
	private View.OnClickListener myYesterdayBtnListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {
			// Log.v("", "");
			// TO-DO:
			// 1. Start the seeds update job, communicate with server
			// 2. Need a progress bar here.
			tProgressDialog = ProgressDialog.show(SeedsDateListActivity.this, "Loading...", "Please wait...", true, false);
			
			// Set up a thread to communicate with server
			new Thread() {
				
				@Override
				public void run() {
					try {
						// Communicate with server
						// As a temp solution to make the dialog move on,
						// set a stub code here to drive the dialog
						Thread.sleep(tSleepSeconds * 1000);						
					} catch (Exception e) {
						// Show the error message here
					}
					Message t_MsgListData = new Message();
					t_MsgListData.what = MESSAGETYPE_UPDATE;
					handler.sendMessage(t_MsgListData);					
				}
			}.start();	
			// Redirect to the seeds list page
			Intent intent = new Intent(SeedsDateListActivity.this, SeedsListPerDayActivity.class);
			// Pass the date info
		    Bundle bundle=new Bundle();
		    bundle.putString("date", "yesterday");
		    intent.putExtras(bundle);
			startActivity(intent);
		}
	};
	
	private View.OnClickListener myTodayBtnListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {
			// Log.v("", "");
			// TO-DO:
			// 1. Start the seeds update job, communicate with server
			// 2. Need a progress bar here.
			tProgressDialog = ProgressDialog.show(SeedsDateListActivity.this, "Loading...", "Please wait...", true, false);
			
			// Set up a thread to communicate with server
			new Thread() {
				
				@Override
				public void run() {
					try {
						// Communicate with server
						// As a temp solution to make the dialog move on,
						// set a stub code here to drive the dialog
						Thread.sleep(tSleepSeconds * 1000);						
					} catch (Exception e) {
						// Show the error message here
					}
					Message t_MsgListData = new Message();
					t_MsgListData.what = MESSAGETYPE_UPDATE;
					handler.sendMessage(t_MsgListData);					
				}
			}.start();	
			Intent intent = new Intent(SeedsDateListActivity.this, SeedsListPerDayActivity.class);
			// Pass the date info
		    Bundle bundle = new Bundle();
		    bundle.putString("date", "today");
		    intent.putExtras(bundle);
			startActivity(intent);
		}
	};
	
	private View.OnClickListener myFavListBtnListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {
			//Log.v("MyListView4", "myAdapter");
			// To-DO:
			// 1. Start the seeds update job, communicate with server
			// 2. Need a progress bar here.
			// 3. Stay inside the activity if the update finished
			// Show the dialog
			tProgressDialog = ProgressDialog.show(SeedsDateListActivity.this, "Loading...", "Please wait...", true, false);
			
			// Set up a thread to communicate with server
			new Thread() {
				
				@Override
				public void run() {
					try {
						// Communicate with server
						// As a temp solution to make the dialog move on,
						// set a stub code here to drive the dialog
						Thread.sleep(tSleepSeconds * 1000);						
					} catch (Exception e) {
						// Show the error message here
					}
					Message t_MsgListData = new Message();
					t_MsgListData.what = MESSAGETYPE_UPDATE;
					handler.sendMessage(t_MsgListData);					
				}
			}.start();
			
			Intent intent = new Intent(SeedsDateListActivity.this, SeedsFavListActivity.class);
			startActivity(intent);			
		}
	};
	
	private View.OnClickListener myUpdateBtnListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {
			//Log.v("MyListView4", "myAdapter");
			// To-DO:
			// 1. Start the seeds update job, communicate with server
			// 2. Need a progress bar here.
			// 3. Stay inside the activity if the update finished
			// Show the dialog
			tProgressDialog = ProgressDialog.show(SeedsDateListActivity.this, "Loading...", "Please wait...", true, false);
			
			// Set up a thread to communicate with server
			new Thread() {
				
				@Override
				public void run() {
					try {
						// Communicate with server
						// As a temp solution to make the dialog move on,
						// set a stub code here to drive the dialog
						SeedsNetworkProcess.sendAlohaReqMsg();
						Thread.sleep(tSleepSeconds * 1000);						
					} catch (Exception e) {
						// Show the error message here
					}
					Message t_MsgListData = new Message();
					t_MsgListData.what = MESSAGETYPE_UPDATE;
					handler.sendMessage(t_MsgListData);					
				}
			}.start();			
			
		}
	};
	
    // Define a handler to process the progress update
	private Handler handler = new Handler(){  
  
        @Override  
        public void handleMessage(Message msg) {  
              
            switch (msg.what) {
            	
            	case MESSAGETYPE_BEFYEST:
            
                case MESSAGETYPE_UPDATE:                                        
                    //close the ProgressDialog
                    tProgressDialog.dismiss(); 
                    break;
                // Or try something here
            }
             
        }
    }; 
    
    private boolean isSeedsInfoUpdated(String tDate){
    	
    	// Retrieve the seeds info status by date via the shared preference file
    	return mSharedPref.getBoolean(tDate,false);    	
    }
    
    private void updateSeedsInfoStatus(String tDate, Boolean tTag){
    	
    	// Retrieve the seeds info status by date via the shared preference file
    	SharedPreferences.Editor editor = mSharedPref.edit();
    	editor.putBoolean(tDate, tTag);
    	editor.commit();    	
    }
    
    private void updateSeedsInfo(ArrayList<String> tDateArray){
    	
    	// Notify progress dialog to show the status
    	tProgressDialog.setMessage("Retrieving Seeds info status...");
    	
    	// Communicate with server to retrieve the seeds info
		try {
			SeedsNetworkProcess.sendUpdateStatusReqMsg(tDateArray);
		} catch (ClientProtocolException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		tProgressDialog.setMessage("Analyze Seeds info status...");
		

    }
     

}

