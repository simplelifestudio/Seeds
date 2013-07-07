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

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;

import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;
import com.simplelife.seeds.android.utils.jsonprocess.SeedsJSONMessage;
import com.simplelife.seeds.android.utils.jsonprocess.SeedsJSONMessage.SeedsStatusByDate;
import com.simplelife.seeds.android.utils.networkprocess.SeedsNetworkProcess;
import com.simplelife.seeds.android.utils.seedslogger.SeedsLoggerUtil;

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
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

@SuppressLint("HandlerLeak")
public class SeedsDateListActivity extends Activity {
	
	// UI widgets for before yesterday
	private LinearLayout mLayoutBefYesterday;
	private TextView mDateTextBefYesterday;
	private TextView mNumTextBefYesterday;
	
	// UI widgets for yesterday
	private LinearLayout mLayoutYesterday;
	private TextView mDateTextYesterday;
	private TextView mNumTextYesterday;
	
	// UI widgets for today
	private LinearLayout mLayoutToday;
	private TextView mDateTextToday;
	private TextView mNumTextToday;
	
	private Button mUpdateBtn;
	private Button mFavListBtn;
	private Button mConfigBtn;
	private Button mHttpServerBtn;
	private ProgressDialog mProgressDialog = null; 	
	
	// Date in string format
	private String mDateBefYesterday;
	private String mDateYesterday;
	private String mDateToday;
	private ArrayList<String>  mDateArray;
	private SharedPreferences mSharedPref;
	
	// Below two fields should be removed or changed in final version
	private int tSleepSeconds = 1; 
	
	// Members to store the number of seeds
	private int numOfSeedsBeyYesterday = 0;
	private int numOfSeedsYesterday = 0;
	private int numOfSeedsToday = 0;
	
	// Handler message definition
	final int MESSAGETYPE_BEFYEST = 100;
	final int MESSAGETYPE_YESTERD = 101;
	final int MESSAGETYPE_TODAY   = 102;
	final int MESSAGETYPE_UPDATE  = 103;
	final int MESSAGETYPE_STAYSTILL = 104;
	final int MESSAGETYPE_UPDATEDIALOG = 105;
	final int MESSAGETYPE_TOAST   = 106;
	final int MESSAGETYPE_SETTEXT = 107;
	
	// For log purpose
	private SeedsLoggerUtil mLogger = SeedsLoggerUtil.getSeedsLogger();
	
	// To record the operation status which needs to be handed between threads
	private boolean opeStatus = false;
		
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		mLogger.info("Working on starting the DateListActivity!"); 
		
		// Start the DateList View
		setContentView(R.layout.activity_seeds_datelist);
		
		mLayoutBefYesterday = (LinearLayout)findViewById(R.id.layout_befyesterday);
		mLayoutYesterday = (LinearLayout)findViewById(R.id.layout_yesterday);
		mLayoutToday = (LinearLayout)findViewById(R.id.layout_today);
		
		mDateTextBefYesterday = (TextView)findViewById(R.id.date_befyesterday);
		mDateTextYesterday = (TextView)findViewById(R.id.date_yesterday);
		mDateTextToday = (TextView)findViewById(R.id.date_today);
		
		mNumTextBefYesterday = (TextView)findViewById(R.id.seedsnumber_befyesterday);
		mNumTextYesterday = (TextView)findViewById(R.id.seedsnumber_yesterday);
		mNumTextToday = (TextView)findViewById(R.id.seedsnumber_today);		

		mUpdateBtn  = (Button) findViewById(R.id.update_btn);
		mHttpServerBtn = (Button) findViewById(R.id.httpserver_btn);
		mFavListBtn = (Button) findViewById(R.id.favlist_btn);
		mConfigBtn  = (Button) findViewById(R.id.config_btn);
		
		// Setup the click listener
		mLayoutBefYesterday.setOnClickListener(mLayoutBefYesterdayListener);
		mLayoutYesterday.setOnClickListener(mLayoutYesterdayListener);
		mLayoutToday.setOnClickListener(mLayoutTodayListener);		
		mFavListBtn.setOnClickListener(myFavListBtnListener);
		mConfigBtn.setOnClickListener(myConfigBtnListener);
		mHttpServerBtn.setOnClickListener(myHttpServerBtnListener);
				 
		// Set the progress style as spinner
		mUpdateBtn.setOnClickListener(myUpdateBtnListener);
		
		// Retrieve the date info 
		SeedsDateManager tDataMgr = SeedsDateManager.getDateManager();
		mDateToday = tDataMgr.getRealDateToday();
		mDateYesterday = tDataMgr.getRealDateYesterday();
		mDateBefYesterday = tDataMgr.getRealDateBefYesterday();
		mDateTextBefYesterday.setText(mDateBefYesterday);
		mDateTextYesterday.setText(mDateYesterday);
		mDateTextToday.setText(mDateToday);				
		
		// Initialize the date array list
		mDateArray = new ArrayList<String> ();
		
		// Get the shared preference file instance
		mSharedPref = getSharedPreferences(
		        getString(R.string.seeds_preffilename), Context.MODE_PRIVATE);		
	}
	
	private View.OnClickListener mLayoutBefYesterdayListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {

			mProgressDialog = ProgressDialog.show(SeedsDateListActivity.this, "Loading...", 					          
					          getString(R.string.seeds_datelist_plswait)+"...", true, false);
			
			mProgressDialog.setCanceledOnTouchOutside(true);
			
			// Set up a thread to communicate with server
			new Thread() {				
				@Override
				public void run() {
					try {
						// Only when the seeds info have not been updated
						updateDialogStatus(getString(R.string.seeds_datelist_conntoserver) + "...");	
						
						if (!isSeedsInfoUpdated(mDateBefYesterday))
							opeStatus = updateSeedsInfo(mDateBefYesterday);
						else
							// The seeds have already been updated
							opeStatus = true;
						
					} catch (Exception e) {
						// Show the error message here
						mLogger.excep(e);
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
	
	
	private View.OnClickListener mLayoutYesterdayListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {

			mProgressDialog = ProgressDialog.show(SeedsDateListActivity.this, "Loading...", 
					          getString(R.string.seeds_datelist_plswait)+"...", true, false);
			mProgressDialog.setCanceledOnTouchOutside(true);
			
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
						mLogger.ethrow("Exception detected!", e);
						e.printStackTrace();
					}

					Message t_MsgListData = new Message();
					if (opeStatus)
					{
						mLogger.info("Sending message to handler, message:MESSAGETYPE_YESTERD");
						t_MsgListData.what = MESSAGETYPE_YESTERD;
					}
					else
					{
						mLogger.info("Sending message to handler, message:MESSAGETYPE_STAYSTILL");
						t_MsgListData.what = MESSAGETYPE_STAYSTILL;
					}
										
					handler.sendMessage(t_MsgListData);					
				}
			}.start();	
		}
	};
	
	private View.OnClickListener mLayoutTodayListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {

			mProgressDialog = ProgressDialog.show(SeedsDateListActivity.this, "Loading...", 
					          getString(R.string.seeds_datelist_plswait)+"...", true, false);
			mProgressDialog.setCanceledOnTouchOutside(true);
			
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
			mProgressDialog = ProgressDialog.show(SeedsDateListActivity.this, "Loading...", 
					          getString(R.string.seeds_datelist_plswait)+"...", true, false);
			mProgressDialog.setCanceledOnTouchOutside(true);
			
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
			mProgressDialog = ProgressDialog.show(SeedsDateListActivity.this, "Loading...", 
					          getString(R.string.seeds_datelist_plswait)+"...", true, false);
			mProgressDialog.setCanceledOnTouchOutside(true);
			
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
	
	private View.OnClickListener myHttpServerBtnListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			Intent intent = new Intent(SeedsDateListActivity.this, SeedsHttpServiceActivity.class);
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
            		mLogger.debug("Working on directing to the details ");
        			// Redirect to the new page
        			Intent intent = new Intent(SeedsDateListActivity.this, SeedsListPerDayActivity.class);
        			// Pass the date info
        		    Bundle bundle = new Bundle();
        		    bundle.putString("date", mDateBefYesterday);
        		    intent.putExtras(bundle);
        			startActivity(intent);
        			mProgressDialog.dismiss();
        			break;
            	}
            	case MESSAGETYPE_YESTERD:
            	{
        			// Redirect to the new page
            		mLogger.debug("MESSAGETYPE_YESTERD: Working on directing to the details !");
        			Intent intent = new Intent(SeedsDateListActivity.this, SeedsListPerDayActivity.class);
        			// Pass the date info
        		    Bundle bundle = new Bundle();
        		    bundle.putString("date", mDateYesterday);
        		    intent.putExtras(bundle);
        			startActivity(intent);
        			mProgressDialog.dismiss();
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
        			mProgressDialog.dismiss();
        			break;
            	}
            	case MESSAGETYPE_UPDATEDIALOG:
            	{
            		// Retrieve the date info parameter
            		Bundle bundle = msg.getData();             				
            		//String tPassinDate = bundle.getString("date");
            		String tStatus = bundle.getString("status");
            		
            		mProgressDialog.setMessage(tStatus);
            		break;
            		
            	}
            	case MESSAGETYPE_TOAST:
            	{
            		Bundle bundle = msg.getData();             				
            		int tResId  = bundle.getInt("resId");
            		Toast toast = Toast.makeText(getApplicationContext(), tResId, Toast.LENGTH_SHORT);
            	    toast.setGravity(Gravity.CENTER, 0, 0);
            	    toast.show();
            	    break;
            	}
            	case MESSAGETYPE_SETTEXT:
            	{
            		Bundle bundle = msg.getData();             				
            		String tDate  = bundle.getString("inDate");
            		int tText  = bundle.getInt("inText");
            		TextView tNumOfSeeds = matchNumTextViaRealDate(tDate);
            		tNumOfSeeds.setText(tText);
            	    break;
            	}
                case MESSAGETYPE_UPDATE:
                case MESSAGETYPE_STAYSTILL:
                {
                	mLogger.debug("MESSAGETYPE_UPDATE or MESSAGETYPE_STAYSTILL!");                	
                	mProgressDialog.dismiss();
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
    
    private TextView matchNumTextViaRealDate(String _inRealDate){
    	
    	if(_inRealDate.equals(mDateBefYesterday))
    		return mNumTextBefYesterday;
    	else if(_inRealDate.equals(mDateYesterday))
    		return mNumTextYesterday;
    	else
    		return mNumTextToday;
    }
    
    private void notifyUserViaToast(int _inResId){
			    
		Message t_MsgListData = new Message();
		t_MsgListData.what = MESSAGETYPE_TOAST;
		
	    Bundle bundle = new Bundle();
	    bundle.putInt("resId", _inResId);    
		t_MsgListData.setData(bundle);
		handler.sendMessage(t_MsgListData);		
    }
    
    private void setNumOfSeedsText(String _inDate, int _inText){
		
    	Message t_MsgListData = new Message();
		t_MsgListData.what = MESSAGETYPE_SETTEXT;
		
	    Bundle bundle = new Bundle();
	    bundle.putString("inDate", _inDate); 
	    bundle.putInt("inText", _inText); 
		t_MsgListData.setData(bundle);
		handler.sendMessage(t_MsgListData);	
    }
    
    private int fetchSeedsData(ArrayList<String> _inDataArray) throws Exception{
    	
    	HttpResponse seedsByDateResponse = null;
    	String respInString = null;
    	ArrayList<SeedsEntity> tSeedsList = null; 
    	
		updateDialogStatus(getString(R.string.seeds_datelist_downloadseedsinfo) + "...");
		seedsByDateResponse = SeedsNetworkProcess.sendSeedsByDateReqMsg(_inDataArray);
		
        // Check the response context
		if (seedsByDateResponse.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {            
			respInString = EntityUtils.toString(seedsByDateResponse.getEntity());          
        } else {
        	mLogger.warn("SeedsByDate Message sending failed! Status Code: "
                         + seedsByDateResponse.getStatusLine().getStatusCode());
        	notifyUserViaToast(R.string.seeds_datelist_seedsbydatecommerror);
        	return -1;           
        }

		if (null == respInString)
		{
			updateDialogStatus(getString(R.string.seeds_datelist_emptyseedsbydateresp));
			mLogger.warn("Receiving empty seedsByDate response message!");
			return -1;
		}
		else
		{
			mLogger.info("Parsing SeedsByDateResp Now!");
			updateDialogStatus(getString(R.string.seeds_datelist_analyzeseedsdata) + "...");
			try{
				tSeedsList = SeedsJSONMessage.parseSeedsByDatesRespMsg(_inDataArray,respInString);
			}catch(JSONException e){
				mLogger.excep(e);
			}
			
			mLogger.debug("Parsing SeedsByDateResp DONE, seeds count = "+tSeedsList.size());
			// Retrieve the DB process handler to get data 
		    SeedsDBAdapter tDBAdapter = SeedsDBAdapter.getAdapter();
		    
		    // Store the seeds info into database 
		    updateDialogStatus(getString(R.string.seeds_datelist_saveseedsinfo));
		    int numOfSeeds = tSeedsList.size();
		    for (int index = 0; index < numOfSeeds; index++)
		    {
		    	updateDialogStatus(getString(R.string.seeds_datelist_saveseedsinfo)+index+"/"+numOfSeeds);
	    		tDBAdapter.insertEntryToSeed(tSeedsList.get(index));
		    }		    
		    return numOfSeeds;
		}
    }
    
    private boolean updateSeedsInfo(String tDate) throws Exception{
    	
    	String respInString  = null;
    	HttpResponse upDateStatusResponse = null;
    	HashMap<String, String> respInMap;
    	ArrayList<String> tDateArray = new ArrayList<String> ();
	    
	    // Construct a single entry array so that we can reuse the interface
	    tDateArray.add(tDate);
	    
    	// Notify progress dialog to show the status
	    updateDialogStatus(getString(R.string.seeds_datelist_retrievestatus) + "...");
    	
    	// Communicate with server to retrieve the seeds info
		try {
			upDateStatusResponse = SeedsNetworkProcess.sendUpdateStatusReqMsg(tDateArray);
		} catch (ClientProtocolException e) {
			mLogger.excep(e);
		} catch (JSONException e) {
			mLogger.excep(e);
		} catch (IOException e) {
			mLogger.excep(e);
		}
		
        // Check the response context
		if (upDateStatusResponse.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
            
            respInString = EntityUtils.toString(upDateStatusResponse.getEntity());
            mLogger.debug("Receive response msg: "+ respInString);
            // String strsResult = strResult.replace("\r", "");            
        } else {
        	mLogger.warn("UpdateStatusReq Message Sending Failed! Status Code: "
                         + upDateStatusResponse.getStatusLine().getStatusCode());
        	notifyUserViaToast(R.string.seeds_datelist_updatestatuscommerror);
        	return false;           
        }
		
		if (null == respInString)
		{
			updateDialogStatus(getString(R.string.seeds_datelist_emptyupdatestatusresp));
			mLogger.error("Receiving empty updateStatus response message!");
			return false;
		}
		else
		{
			updateDialogStatus(getString(R.string.seeds_datelist_analyzeseedsstatus) + "...");
			respInMap = SeedsJSONMessage.parseUpdateStatusRespMsg(tDateArray,respInString);			
		}		
		
		
		if (SeedsStatusByDate.isSeedsByDateReady(respInMap.get(tDate)))
		{			
			int tSeedsNum = fetchSeedsData(tDateArray);
			if (0 < tSeedsNum)
			{
				updateSeedsInfoStatus(tDate, true);
				//setNumOfSeedsText(tDate, R.string.seeds_datelist_seedsnumbernotready);
			}
			else
				return false;
		}
		else if(SeedsStatusByDate.isSeedsByDateNotReady(respInMap.get(tDate)))
		{
			notifyUserViaToast(R.string.seeds_datelist_seedsinfonotready);
			setNumOfSeedsText(tDate, R.string.seeds_datelist_seedsnumbernotready);
			return false;			
		}
		else if(SeedsStatusByDate.isSeedsByDateNoUpdate(respInMap.get(tDate)))
		{			
			notifyUserViaToast(R.string.seeds_datelist_seedsinfonoupdate);
			setNumOfSeedsText(tDate, R.string.seeds_datelist_seedsnumbernoupdate);
			return false;						
		}		
		return true;				
    }
    
    private boolean updateSeedsInfo(ArrayList<String> tDateArray) throws Exception{
    	
    	String respInString  = null;
    	String respInString2 = null;
    	HashMap<String, String> respInMap = null;
    	HttpResponse upDateStatusResponse = null;    	
    	
    	// Notify progress dialog to show the status
	    updateDialogStatus(getString(R.string.seeds_datelist_retrievestatus) + "...");
    	
    	// Communicate with server to retrieve the seeds info
		try {
			upDateStatusResponse = SeedsNetworkProcess.sendUpdateStatusReqMsg(tDateArray);
		} catch (ClientProtocolException e) {
			mLogger.excep(e);
		} catch (JSONException e) {
			mLogger.excep(e);
		} catch (IOException e) {
			mLogger.excep(e);
		}
		
        // Check the response context
		if (upDateStatusResponse.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
            
            respInString = EntityUtils.toString(upDateStatusResponse.getEntity());
            mLogger.debug("Receive response msg: "+ respInString);
            // String strsResult = strResult.replace("\r", "");            
        } else {
        	mLogger.warn("UpdateStatusReq Message Sending Failed! Status Code: "
                         + upDateStatusResponse.getStatusLine().getStatusCode());
        	notifyUserViaToast(R.string.seeds_datelist_updatestatuscommerror);
        	return false;           
        }
		
		if (null == respInString)
		{
			updateDialogStatus(getString(R.string.seeds_datelist_emptyupdatestatusresp));
			mLogger.error("Receiving empty updateStatus response message!");
			return false;
		}
		else
		{
			updateDialogStatus(getString(R.string.seeds_datelist_analyzeseedsstatus) + "...");
			try{
				respInMap = SeedsJSONMessage.parseUpdateStatusRespMsg(tDateArray,respInString);			
			}catch (JSONException e){
				mLogger.excep(e);
			}			
		}
		
		ArrayList<String> tDateArray2 = new ArrayList<String> ();
		tDateArray2.clear();
		int numOfDate = tDateArray.size();
		for (int index2 = 0; index2 < numOfDate; index2++)
		{
			String tDate = tDateArray.get(index2);
			mLogger.debug("tDate: "+ tDate +"Status: " + respInMap.get(tDate));
			if (SeedsStatusByDate.isSeedsByDateReady(respInMap.get(tDate)))
			{
				tDateArray2.add(tDate);
			}		
		}
		mLogger.debug("The size of tDateArray2 is "+ tDateArray2.size());
		if (tDateArray2.size() <= 0)
		{			
			notifyUserViaToast(R.string.seeds_datelist_noneedtosync);
			return true;
		}
		
		updateDialogStatus(getString(R.string.seeds_datelist_downloadseedsinfo) + "...");
		if(0 < fetchSeedsData(tDateArray2))
		{				    
		    int numOfDate2 = mDateArray.size();
		    for (int index3 = 0; index3 < numOfDate2; index3++)
		    {
		    	updateSeedsInfoStatus(mDateArray.get(index3), true);	
		    }						
		}
		return true;
    }    

}


