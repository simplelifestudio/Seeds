/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsConfigActivity.java
 *  Seeds
 *
 *  Created by Chris Li on 13-5-20. 
 */

package com.simplelife.seeds.android;

import java.io.IOException;

import org.apache.http.client.ClientProtocolException;
import org.json.JSONException;

import com.simplelife.seeds.android.utils.networkprocess.SeedsNetworkProcess;
import com.simplelife.seeds.android.utils.seedslogger.SeedsLoggerUtil;

import android.app.ActionBar;
import android.app.Activity;
import android.app.ProgressDialog;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.preference.PreferenceFragment;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.EditText;
import android.widget.RadioButton;
import android.widget.Toast;

public class SeedsConfigActivity extends Activity {

	private String mServerUrl = null;
	private String mResponse  = null;
	private ProgressDialog mProgressDialog = null;
	private boolean mRadioOneChecked = false;
	private boolean mRadioTwoChecked = false;
	private boolean mRadioThreeChecked = false;
	
	// For log purpose
	private SeedsLoggerUtil mLogger = SeedsLoggerUtil.getSeedsLogger();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		//setContentView(R.layout.activity_seeds_config);
		
		getFragmentManager()
		.beginTransaction()
		.replace(android.R.id.content, new SeedsPreferenceFragment()).commit();
		
		// Set a title for this page
		ActionBar tActionBar = getActionBar();
		tActionBar.setTitle(R.string.seeds_config_page);
	}
	
    /* Called when the user clicks the Verify button */
    public void onVerifyAddress(View view) {
        // Do something in response to button
    	EditText editText = (EditText) findViewById(R.id.edit_serveraddr);
    	
    	if(editText.getText().toString().equals("")){
    		mServerUrl = SeedsDefinitions.getServerUrl();
    	}
    	else{
    		mServerUrl = "http://"+editText.getText().toString()+"/seeds/messageListener";
    	}
    	
    	mProgressDialog = ProgressDialog.show(SeedsConfigActivity.this, "Verifying...", "Please wait...", true, false);
    	mProgressDialog.setCanceledOnTouchOutside(true);
    	
		new Thread() {
						
			@Override
			public void run() {
		    	// Communicate with server to see if the address is valid
		    	try{
		    		mResponse = SeedsNetworkProcess.sendAlohaReqMsg(mServerUrl);    		 
				} catch (ClientProtocolException e) {
					mLogger.excep(e);
				} catch (JSONException e) {
					mLogger.excep(e);
				} catch (IOException e) {
					mLogger.excep(e);
				}
				Message t_MsgListData = new Message();
				t_MsgListData.what = 0;									
				handler.sendMessage(t_MsgListData);	
			}				
		}.start();
    }
    
    // Define a handler to process the progress update
	private Handler handler = new Handler(){  
  
        @Override  
        public void handleMessage(Message msg) {  
        	
        	switch (msg.what) {
        		case 0:
        		{
                	if (null != mResponse)
                	{
                		// Record the address
                		SeedsDefinitions.setServerUrl(mServerUrl);
                		
                		Toast toast = Toast.makeText(getApplicationContext(),
                				R.string.seeds_toast_configsucc, Toast.LENGTH_LONG);
                	    toast.setGravity(Gravity.CENTER, 0, 0);
                	    mProgressDialog.dismiss();
                		toast.show();
                	}
                	else
                	{
                		// Toast here
                		Toast toast = Toast.makeText(getApplicationContext(),
                				R.string.seeds_toast_configfail, Toast.LENGTH_LONG);
                	    toast.setGravity(Gravity.CENTER, 0, 0);
                	    mProgressDialog.dismiss();
                		toast.show();
                	} 
                	
                	
        		}
        	}        	
        	
        }
	};
	
	public void onChannelOneClick(View view) {
		
		RadioButton tRadioButton = (RadioButton)findViewById(R.id.radioButton1);
        //boolean tIsChecked = tRadioButton.isChecked() ;
        
		if(mRadioOneChecked){
			tRadioButton.setChecked(false);
			mRadioOneChecked = false ;
        }else{
        	tRadioButton.setChecked(true);
        	mRadioOneChecked = true ;
        }        
	}
	
	public void onChannelTwoClick(View view) {
		
		RadioButton tRadioButton = (RadioButton)findViewById(R.id.radioButton2);
        //boolean tIsChecked = tRadioButton.isChecked() ;
        
		if(mRadioTwoChecked){
			tRadioButton.setChecked(false);
			mRadioTwoChecked = false ;
        }else{
        	tRadioButton.setChecked(true);
        	mRadioTwoChecked = true ;
        }        
	}
	
	public void onChannelThreeClick(View view) {
		
		RadioButton tRadioButton = (RadioButton)findViewById(R.id.radioButton3);
        //boolean tIsChecked = tRadioButton.isChecked() ;
        
		if(mRadioThreeChecked){
			tRadioButton.setChecked(false);
			mRadioThreeChecked = false ;
        }else{
        	tRadioButton.setChecked(true);
        	mRadioThreeChecked = true ;
        }        
	}
	
    public static class SeedsPreferenceFragment extends PreferenceFragment{  
        @Override  
        public void onCreate(Bundle savedInstanceState) {  
            // TODO Auto-generated method stub  
            super.onCreate(savedInstanceState);  
            addPreferencesFromResource(R.xml.seeds_preferences);  
        }  
    }  

}
