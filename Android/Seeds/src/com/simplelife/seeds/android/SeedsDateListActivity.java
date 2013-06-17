/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsDateListActivity.java
 *  Seeds
 *
 *  Created by Chris Li on 13-5-20. 
 */

package com.simplelife.seeds.android;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

import org.apache.http.client.ClientProtocolException;
import org.json.JSONException;

import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;
import com.simplelife.seeds.android.utils.jsonprocess.SeedsJSONMessage;
import com.simplelife.seeds.android.utils.jsonprocess.SeedsJSONMessage.SeedsStatusByDate;
import com.simplelife.seeds.android.utils.networkprocess.SeedsNetworkProcess;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
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
	private Button myConfigBtn;
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
	final int MESSAGETYPE_STAYSTILL = 104;
	final int MESSAGETYPE_UPDATEDIALOG = 105;
	
	// For log purpose
	private static final String LOGCLASS = "SeedsDateList"; 
	
	// To record the operation status which needs to be handed between threads
	private boolean opeStatus = false;
		
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
		myFavListBtn = (Button) findViewById(R.id.favlist_btn);
		myConfigBtn  = (Button) findViewById(R.id.config_btn);
		
		// Setup the click listener
		myBefYesterdayBtn.setOnClickListener(myBefYesterdayBtnListener);
		myYesterdayBtn.setOnClickListener(myYesterdayBtnListener);
		myTodayBtn.setOnClickListener(myTodayBtnListener);
		myFavListBtn.setOnClickListener(myFavListBtnListener);
		myConfigBtn.setOnClickListener(myConfigBtnListener);
		
		Log.i(LOGCLASS, "Working on setting the ProgressDialog style"); 
		// Set the progress style as spinner
		//tProgressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER); 
		myUpdateBtn.setOnClickListener(myUpdateBtnListener);
		
		// Retrieve the date info 
		SeedsDateManager tDataMgr = SeedsDateManager.getDateManager();
		mDateToday = tDataMgr.getRealDateToday();
		mDateYesterday = tDataMgr.getRealDateYesterday();
		mDateBefYesterday = tDataMgr.getRealDateBefYesterday();
		
		// Initialize the date array list
		mDateArray = new ArrayList<String> ();
		
		// Get the shared preference file instance
		mSharedPref = getSharedPreferences(
		        getString(R.string.seeds_preffilename), Context.MODE_PRIVATE);		
	}
	
	private View.OnClickListener myBefYesterdayBtnListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {

			tProgressDialog = ProgressDialog.show(SeedsDateListActivity.this, "Loading...", "Please wait...", true, false);
			tProgressDialog.setCanceledOnTouchOutside(true);
			
			// Set up a thread to communicate with server
			new Thread() {				
				@Override
				public void run() {
					try {
						// Only when the seeds info have not been updated
						updateDialogStatus("Connecting to Server...");	
						
						if (!isSeedsInfoUpdated(mDateBefYesterday))
							opeStatus = updateSeedsInfo(mDateBefYesterday);
						else
							// The seeds have already been updated
							opeStatus = true;
						
					} catch (Exception e) {
						// Show the error message here
						e.printStackTrace();
					}
					Message t_MsgListData = new Message();
					if (opeStatus)
						t_MsgListData.what = MESSAGETYPE_BEFYEST;
					else
						t_MsgListData.what = MESSAGETYPE_STAYSTILL;
										
					handler.sendMessage(t_MsgListData);					
				}
			}.start();							
		}
	};
	
	
	private View.OnClickListener myYesterdayBtnListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {

			tProgressDialog = ProgressDialog.show(SeedsDateListActivity.this, "Loading...", "Please wait...", true, false);
			tProgressDialog.setCanceledOnTouchOutside(true);
			
			// Set up a thread to communicate with server
			new Thread() {
				
				@Override
				public void run() {
					try {
						// Only when the seeds info have not been updated
						if (!isSeedsInfoUpdated(mDateYesterday))
							opeStatus = updateSeedsInfo(mDateYesterday);
						else
							// The seeds have already been updated
							opeStatus = true;
					} catch (Exception e) {
						// Show the error message here
						Log.i(LOGCLASS,"Exception detected!");
						e.printStackTrace();
					}
					Log.i(LOGCLASS,"Sending message to handler!");
					Message t_MsgListData = new Message();
					if (opeStatus)
					{
						Log.i(LOGCLASS,"Sending message to handler, message:MESSAGETYPE_YESTERD");
						t_MsgListData.what = MESSAGETYPE_YESTERD;
					}
					else
					{
						Log.i(LOGCLASS,"Sending message to handler, message:MESSAGETYPE_STAYSTILL");
						t_MsgListData.what = MESSAGETYPE_STAYSTILL;
					}
										
					handler.sendMessage(t_MsgListData);					
				}
			}.start();	
		}
	};
	
	private View.OnClickListener myTodayBtnListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {

			tProgressDialog = ProgressDialog.show(SeedsDateListActivity.this, "Loading...", "Please wait...", true, false);
			tProgressDialog.setCanceledOnTouchOutside(true);
			
			// Set up a thread to communicate with server
			new Thread() {				
				@Override
				public void run() {
					try {
						// Only when the seeds info have not been updated
						if (!isSeedsInfoUpdated(mDateToday))
							opeStatus = updateSeedsInfo(mDateToday);
						else
							// The seeds have already been updated
							opeStatus = true;
					} catch (Exception e) {
						// Show the error message here
					}
					Message t_MsgListData = new Message();
					if (opeStatus)
						t_MsgListData.what = MESSAGETYPE_TODAY;
					else
						t_MsgListData.what = MESSAGETYPE_STAYSTILL;
										
					handler.sendMessage(t_MsgListData);				
				}
			}.start();	
		}
	};
	
	private View.OnClickListener myFavListBtnListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {
			tProgressDialog = ProgressDialog.show(SeedsDateListActivity.this, "Loading...", "Please wait...", true, false);
			tProgressDialog.setCanceledOnTouchOutside(true);
			
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
					t_MsgListData.what = MESSAGETYPE_STAYSTILL;
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
			// Show the dialog
			tProgressDialog = ProgressDialog.show(SeedsDateListActivity.this, "Loading...", "Please wait...", true, false);
			tProgressDialog.setCanceledOnTouchOutside(true);
			
			// Set up a thread to communicate with server
			new Thread() {				
				@Override
				public void run() {
					try {
						// Only when the seeds info have not been updated
						ArrayList<String> tDateArray = new ArrayList<String>();
						if (!isSeedsInfoUpdated(mDateBefYesterday))
							tDateArray.add(mDateBefYesterday);
						if (!isSeedsInfoUpdated(mDateYesterday))
							tDateArray.add(mDateYesterday);
						if (!isSeedsInfoUpdated(mDateToday))
							tDateArray.add(mDateToday);
						
						if (0 < tDateArray.size())
						{
							opeStatus = updateSeedsInfo(tDateArray);
						}							
					} catch (Exception e) {
						// Show the error message here
					}
					Message t_MsgListData = new Message();
					if (opeStatus)
						t_MsgListData.what = MESSAGETYPE_UPDATE;
					else
						t_MsgListData.what = MESSAGETYPE_STAYSTILL;
										
					handler.sendMessage(t_MsgListData);				
				}
			}.start();			
			
		}
	};
	
	private View.OnClickListener myConfigBtnListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			Intent intent = new Intent(SeedsDateListActivity.this, SeedsConfigActivity.class);
			startActivity(intent);
		}
	};
	
	private void updateDialogStatus(String inContents){
		
		Message t_MsgListData = new Message();
		t_MsgListData.what = MESSAGETYPE_UPDATEDIALOG;
		
	    Bundle bundle = new Bundle();
	    bundle.putString("status", inContents);	    
		t_MsgListData.setData(bundle);
		handler.sendMessage(t_MsgListData);					
		
	}
	
    // Define a handler to process the progress update
	private Handler handler = new Handler(){  
  
        @Override  
        public void handleMessage(Message msg) {  
              
        	switch (msg.what) {
            	
            	case MESSAGETYPE_BEFYEST:
            	{
        			Log.i(LOGCLASS, "Working on directing to the details ");
        			// Redirect to the new page
        			Intent intent = new Intent(SeedsDateListActivity.this, SeedsListPerDayActivity.class);
        			// Pass the date info
        		    Bundle bundle = new Bundle();
        		    bundle.putString("date", mDateBefYesterday);
        		    intent.putExtras(bundle);
        			startActivity(intent);
        			tProgressDialog.dismiss();
        			break;
            	}
            	case MESSAGETYPE_YESTERD:
            	{
        			// Redirect to the new page
            		Log.i(LOGCLASS,"MESSAGETYPE_YESTERD: Working on directing to the details !");
        			Intent intent = new Intent(SeedsDateListActivity.this, SeedsListPerDayActivity.class);
        			// Pass the date info
        		    Bundle bundle = new Bundle();
        		    bundle.putString("date", mDateYesterday);
        		    intent.putExtras(bundle);
        			startActivity(intent);
        		    tProgressDialog.dismiss();
        			break;
            	}
            	case MESSAGETYPE_TODAY:
            	{
        			// Redirect to the new page
        			Intent intent = new Intent(SeedsDateListActivity.this, SeedsListPerDayActivity.class);
        			// Pass the date info
        		    Bundle bundle = new Bundle();
        		    bundle.putString("date", mDateToday);
        		    intent.putExtras(bundle);
        			startActivity(intent);
        		    tProgressDialog.dismiss();
        			break;
            	}
            	case MESSAGETYPE_UPDATEDIALOG:
            	{
            		// Retrieve the date info parameter
            		Bundle bundle = msg.getData();             				
            		//String tPassinDate = bundle.getString("date");
            		String tStatus = bundle.getString("status");
            		
            		tProgressDialog.setMessage(tStatus);
            		break;
            		
            	}
                case MESSAGETYPE_UPDATE:
                case MESSAGETYPE_STAYSTILL:
                {
                	Log.i(LOGCLASS,"MESSAGETYPE_UPDATE or MESSAGETYPE_STAYSTILL!");
        		    tProgressDialog.dismiss();
                    break;
                }
                default:
                	break;
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
    
    private boolean updateSeedsInfo(String tDate) throws Exception{
    	
    	String respInString  = null;
    	String respInString2 = null;
    	HashMap<String, String> respInMap;
    	ArrayList<SeedsEntity> tSeedsList = null;
    	
	    // Construct a single entry array so that we can reuse the interface
    	mDateArray.clear();
	    mDateArray.add(tDate);
	    
    	// Notify progress dialog to show the status
    	//tProgressDialog.setMessage("Retrieving Seeds Info Status...");
	    updateDialogStatus("Retrieving Seeds Info Status...");
    	
    	// Communicate with server to retrieve the seeds info
		/*respInString = stubReadExternalFile("SeedsUpdateStatusByDatesResponse.txt");
		status = true;*/
		try {
			respInString = SeedsNetworkProcess.sendUpdateStatusReqMsg(mDateArray);
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
		
		Log.i("DateList", "seedsUpdateStatusReq msg communication finished, msg: "+respInString);
		if (null == respInString)
		{
			updateDialogStatus("Retrieving Seeds Info Failed!");			
			return false;
		}
		else
		{
			updateDialogStatus("Analyzing Seeds Info Status...");
			respInMap = SeedsJSONMessage.parseUpdateStatusRespMsg(mDateArray,respInString);			
		}
		
		if (SeedsStatusByDate.isSeedsByDateReady(respInMap.get(tDate)))
		{
			updateDialogStatus("Downloading Seeds Info...");
			respInString2 = SeedsNetworkProcess.sendSeedsByDateReqMsg(mDateArray);

			if (null == respInString2)
			{
				// TODO: add warding info here, notify user the problem
				updateDialogStatus("Downloading Seeds Info Failed!");
				return false;
			}
			else
			{
				//tProgressDialog.setMessage("Parsing Seeds Info...");
				Log.i("DateList", "Parsing SeedsByDateResp now!");
				try{
					tSeedsList = SeedsJSONMessage.parseSeedsByDatesRespMsg(mDateArray,respInString2);
				}catch(JSONException e){
					e.printStackTrace();
				}
				
				Log.i("DateList", "Parsing SeedsByDateResp DONE, seeds count = "+tSeedsList.size());
				// Retrieve the DB process handler to get data 
			    SeedsDBAdapter tDBAdapter = SeedsDBAdapter.getAdapter();
			    
			    // Store the seeds info into database 
			    //tProgressDialog.setMessage("Store Seeds Info...");
			    int numOfSeeds = tSeedsList.size();
			    Log.i("DateList", "The size of the SeedsList is: "+numOfSeeds);
			    for (int index = 0; index < numOfSeeds; index++)
			    {
			    	//tProgressDialog.setMessage("Store Seeds Info "+index+"/"+numOfSeeds);
		    		tDBAdapter.insertEntryToSeed(tSeedsList.get(index));
			    }
				updateSeedsInfoStatus(tDate, true);
			}
		}
		else if(SeedsStatusByDate.isSeedsByDateNotReady(respInMap.get(tDate)))
		{
			//tProgressDialog.setMessage("Seeds Info Not Ready!");
			return false;			
		}
		else if(SeedsStatusByDate.isSeedsByDateNoUpdate(respInMap.get(tDate)))
		{
			//tProgressDialog.setMessage("Seeds Info No Update!");
			return false;						
		}
		
		return true;
				
    }
    
    private boolean updateSeedsInfo(ArrayList<String> tDateArray) throws Exception{
    	
    	String respInString  = null;
    	String respInString2 = null;
    	HashMap<String, String> respInMap = null;
    	// Notify progress dialog to show the status
    	//tProgressDialog.setMessage("Retrieving Seeds Info Status...");
    	
    	// Communicate with server to retrieve the seeds info
		/*respInString = stubReadExternalFile("SeedsUpdateStatusByDatesResponse.txt");
		status = true;*/

		try {
			respInString = SeedsNetworkProcess.sendUpdateStatusReqMsg(tDateArray);
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
		
		if (null == respInString)
		{
			//tProgressDialog.setMessage("Retrieving Seeds Info Failed!");
		}
		else
		{
			//tProgressDialog.setMessage("Analyzing Seeds Info Status...");
			try{
				respInMap = SeedsJSONMessage.parseUpdateStatusRespMsg(tDateArray,respInString);			
			}catch (JSONException e){
				e.printStackTrace();
			}
		}
		Log.i("DateList", "The size of respInMap is "+ respInMap.size());
		Log.i("DateList", "The size of tDateArray is "+ tDateArray.size());
		int numOfDate = tDateArray.size();
		Log.i("DateList", "The size of mDateArray is "+ mDateArray.size());
		mDateArray.clear();
		Log.i("DateList", "The size of mDateArray is "+ mDateArray.size());
		for (int index2 = 0; index2 < numOfDate; index2++)
		{
			String tDate = tDateArray.get(index2);
			Log.i("DateList", "tDate: "+ tDate +"Status: " + respInMap.get(tDate));
			if (SeedsStatusByDate.isSeedsByDateReady(respInMap.get(tDate)))
			{
				//tProgressDialog.setMessage("Seeds Info Is Ready! "+tDate);
				mDateArray.add(tDate);
			}
			else if(SeedsStatusByDate.isSeedsByDateNotReady(respInMap.get(tDate)))
			{
				//tProgressDialog.setMessage("Seeds Info Not Ready! "+tDate);							
			}
			else if(SeedsStatusByDate.isSeedsByDateNoUpdate(respInMap.get(tDate)))
			{
				//tProgressDialog.setMessage("Seeds Info No Update! "+tDate);										
			}			
		}
		Log.i("DateList", "The size of mDateArray is "+ mDateArray.size());
		if (mDateArray.size() <= 0)
		{
			//tProgressDialog.setMessage("Seeds Info No Update!");
			return false;
		}
		
		//tProgressDialog.setMessage("Downloading Seeds Info... ");
		respInString2 = SeedsNetworkProcess.sendSeedsByDateReqMsg(mDateArray);
		/*respInString2 = stubReadExternalFile("SeedsByDatesResponse.txt");
		status2 =  true;*/
		
		if (null == respInString2)
		{
			//tProgressDialog.setMessage("Downloading Seeds Info Failed!");
			return false;
		}
		else
		{
			//tProgressDialog.setMessage("Parsing Seeds Info... ");
			ArrayList<SeedsEntity> tSeedsList = SeedsJSONMessage.parseSeedsByDatesRespMsg(mDateArray,respInString2);
			
			// Retrieve the DB process handler to get data 
		    SeedsDBAdapter tDBAdapter = SeedsDBAdapter.getAdapter();
		    
		    // Store the seeds info into database
		    //tProgressDialog.setMessage("Store Seeds Info... ");
		    int numOfSeeds = tSeedsList.size();
		    for (int index = 0; index < numOfSeeds; index++)
		    {
		    	//tProgressDialog.setMessage("Store Seeds Info "+index+"/"+numOfSeeds);
		    	try{
		    		tDBAdapter.insertEntryToSeed(tSeedsList.get(index));			    	
		    	}catch(Exception e){
		    		e.printStackTrace();
		    	}			    	
		    }
		    
		    int numOfDate2 = mDateArray.size();
		    for (int index3 = 0; index3 < numOfDate2; index3++)
		    {
		    	updateSeedsInfoStatus(mDateArray.get(index3), true);	
		    }						
		}
		return true;
    }
    
	public String stubReadExternalFile(String fileName){		
		String text = "";
		try {
			java.io.InputStream is = getAssets().open(fileName);
            
            int size = is.available();
            
            byte[] buffer = new byte[size];
            is.read(buffer);
            is.close();
            
            text = new String(buffer);
			
			
			/*FileInputStream fin = new FileInputStream(fileName);

			int length = fin.available();
			byte[] buffer = new byte[length];
			fin.read(buffer);
			res = EncodingUtils.getString(buffer, "UTF-8");
			fin.close();*/

		} catch (Exception e) {
			e.printStackTrace();
		}
		return text;
    }

}


