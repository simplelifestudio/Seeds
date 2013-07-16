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
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.preference.EditTextPreference;
import android.preference.ListPreference;
import android.preference.Preference;
import android.preference.Preference.OnPreferenceChangeListener;
import android.preference.Preference.OnPreferenceClickListener;
import android.preference.PreferenceFragment;
import android.preference.PreferenceManager;
import android.preference.SwitchPreference;
import android.view.Gravity;
import android.widget.Toast;

public class SeedsConfigActivity extends Activity {

	// For log purpose
	private static SeedsLoggerUtil mLogger = SeedsLoggerUtil.getSeedsLogger();
	
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
	
    public static class SeedsPreferenceFragment extends PreferenceFragment 
                  implements OnPreferenceChangeListener, OnPreferenceClickListener{
    	
    	private EditTextPreference mEditTextPrefServerAddr;
    	private Preference mPrefVerifyServer;
    	private ListPreference mListPrefSelectChan;
    	private SwitchPreference mSwitchPrefWifi;
    	private Preference mPrefClearCache;
    	private Preference mPrefChangePwd;
    	private Preference mPrefFeedback;
    	private Preference mPrefAbout;
    	private SharedPreferences mSharedPrefs;
    	
    	private String mServerUrl = null;
    	private String mResponse  = null;
    	private ProgressDialog mProgressDialog = null;
    	
        @Override  
        public void onCreate(Bundle savedInstanceState) {    
            super.onCreate(savedInstanceState);  
            addPreferencesFromResource(R.xml.seeds_preferences);
            
            mSharedPrefs = PreferenceManager.getDefaultSharedPreferences(getActivity());
            
            mEditTextPrefServerAddr = (EditTextPreference)findPreference("config_changeserver");
            mPrefVerifyServer   = (Preference)findPreference("config_verifyserver");
            mListPrefSelectChan = (ListPreference)findPreference("config_selectchannel");
            mSwitchPrefWifi = (SwitchPreference)findPreference("config_network");
            mPrefClearCache = (Preference)findPreference("config_clearcache");
            mPrefChangePwd  = (Preference)findPreference("config_changepwd");
            mPrefFeedback   = (Preference)findPreference("config_feedback");
            mPrefAbout = (Preference)findPreference("config_about");
            
            mEditTextPrefServerAddr.setOnPreferenceChangeListener(this);
            mListPrefSelectChan.setOnPreferenceChangeListener(this);
            mSwitchPrefWifi.setOnPreferenceChangeListener(this);
            
            mPrefVerifyServer.setOnPreferenceClickListener(this);
            mPrefClearCache.setOnPreferenceClickListener(this);
            mPrefChangePwd.setOnPreferenceClickListener(this);
            mPrefFeedback.setOnPreferenceClickListener(this);
            mPrefAbout.setOnPreferenceClickListener(this);
        }
        
        @Override    
        public boolean onPreferenceChange(Preference preference, Object newValue) {    
            
        	if(mEditTextPrefServerAddr == preference)
        	{        		
        		mEditTextPrefServerAddr.setSummary(mSharedPrefs.getString(preference.getKey(), "N/A"));
        	}
        	else if(mListPrefSelectChan == preference)
        	{
        		// Do Nothing Now
        	}
        	else if(mSwitchPrefWifi == preference)
        	{
        		
        	}
        	else if(mPrefChangePwd == preference)
        	{
        		
        	}
        	else if(mPrefFeedback == preference)
        	{
        		
        	}
        	else if(mPrefAbout == preference)
        	{
        		
        	}
            return true;    
        }
        
        public boolean onPreferenceClick(Preference preference) {
        	
        	if(mPrefVerifyServer == preference)
        	{
        		onVerifyAddress(mSharedPrefs.getString(preference.getKey(), "N/A"));
        	}
        	else if(mPrefClearCache == preference)
        	{
        		
        	}
        	else if(mPrefChangePwd == preference)
        	{
        		
        	}
        	
        	return false;
        }
        
        public void onVerifyAddress(String _inUrl) {   	
        	
        	if(_inUrl.equals("N/A")){
        		mServerUrl = SeedsDefinitions.getServerUrl();
        	}
        	else{
        		mServerUrl = "http://"+_inUrl+"/seeds/messageListener";
        	}
        	
        	mProgressDialog = ProgressDialog.show(getActivity(), "Verifying...", "Communicating with server "+mServerUrl, true, false);
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
                    		
                    		Toast toast = Toast.makeText(getActivity(),
                    				R.string.seeds_toast_configsucc, Toast.LENGTH_LONG);
                    	    toast.setGravity(Gravity.CENTER, 0, 0);
                    	    mProgressDialog.dismiss();
                    		toast.show();
                    	}
                    	else
                    	{
                    		// Toast here
                    		Toast toast = Toast.makeText(getActivity(),
                    				R.string.seeds_toast_configfail, Toast.LENGTH_LONG);
                    	    toast.setGravity(Gravity.CENTER, 0, 0);
                    	    mProgressDialog.dismiss();
                    		toast.show();
                    	} 
                    	
                    	
            		}
            	}        	
            	
            }
    	};
        
    	private void showToast(String _message) {
    	    Toast.makeText(getActivity(), _message, Toast.LENGTH_SHORT).show();
    	}
        
    }  

}
