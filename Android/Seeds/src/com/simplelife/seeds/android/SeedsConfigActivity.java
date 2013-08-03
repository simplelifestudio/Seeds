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
import java.text.DecimalFormat;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.http.client.ClientProtocolException;
import org.json.JSONException;

import com.simplelife.seeds.android.SeedsAboutActivity.SeedsAboutDialog;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.ImageCache;
import com.simplelife.seeds.android.utils.networkprocess.SeedsNetworkProcess;
import com.simplelife.seeds.android.utils.seedslogger.SeedsLoggerUtil;

import android.annotation.SuppressLint;
import android.app.ActionBar;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.preference.EditTextPreference;
import android.preference.Preference;
import android.preference.Preference.OnPreferenceChangeListener;
import android.preference.Preference.OnPreferenceClickListener;
import android.preference.PreferenceFragment;
import android.preference.PreferenceManager;
import android.preference.SwitchPreference;
import android.widget.Toast;

public class SeedsConfigActivity extends Activity {

	// For log purpose
	private static SeedsLoggerUtil mLogger = SeedsLoggerUtil.getSeedsLogger();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
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
    	private Preference mPrefResetServer;
    	//private ListPreference mListPrefSelectChan;
    	private SwitchPreference mSwitchPrefWifi;
    	private SwitchPreference mSwitchEnablePwd;
    	private Preference mPrefClearCache;
    	private Preference mPrefChangePwd;
    	//private Preference mPrefFeedback;
    	private Preference mPrefAbout;
    	private SharedPreferences mSharedPrefs;
    	
    	private String mServerIp  = SeedsDefinitions.SEEDS_SERVER_DEFAUL_IPANDPORT;
    	private String mServerUrl = SeedsDefinitions.getServerUrl();
    	private String mResponse  = null;
    	private ProgressDialog mProgressDialog = null;
    	
    	private final int MESSAGE_CONFIG_VERIFYSERVER = 0;
    	private final int MEESAGE_CONFIG_CLEARCACHE   = 1;
    	
        @Override  
        public void onCreate(Bundle savedInstanceState) {    
            super.onCreate(savedInstanceState);  
            addPreferencesFromResource(R.xml.seeds_preferences);
            
            mSharedPrefs = PreferenceManager.getDefaultSharedPreferences(getActivity());
            
            mEditTextPrefServerAddr = (EditTextPreference)findPreference("config_changeserver");
            mPrefVerifyServer = (Preference)findPreference("config_verifyserver");
            mPrefResetServer  = (Preference)findPreference("config_resetserver");
            //mListPrefSelectChan = (ListPreference)findPreference("config_selectchannel");
            mSwitchPrefWifi  = (SwitchPreference)findPreference("config_network");
            mSwitchEnablePwd = (SwitchPreference)findPreference("config_enablepwd");
            mPrefClearCache = (Preference)findPreference("config_clearcache");
            mPrefChangePwd  = (Preference)findPreference("config_changepwd");
            //mPrefFeedback   = (Preference)findPreference("config_feedback");
            mPrefAbout = (Preference)findPreference("config_about");
            
            try {            	
            	String tCacheSizeInString = getCacheDirSize();				
            	mPrefClearCache.setSummary(getString(R.string.seeds_config_clearcachesum)+tCacheSizeInString);
			} catch (Exception e) {
				mLogger.excep(e);
			}
            
            mEditTextPrefServerAddr.setOnPreferenceChangeListener(this);
            //mListPrefSelectChan.setOnPreferenceChangeListener(this);
            mSwitchPrefWifi.setOnPreferenceChangeListener(this);
            
            mPrefVerifyServer.setOnPreferenceClickListener(this);
            mPrefResetServer.setOnPreferenceClickListener(this);
            mPrefClearCache.setOnPreferenceClickListener(this);
            mPrefChangePwd.setOnPreferenceClickListener(this);
            //mPrefFeedback.setOnPreferenceClickListener(this);
            mPrefAbout.setOnPreferenceClickListener(this);
        }
        
        @Override    
        public boolean onPreferenceChange(Preference preference, Object newValue) {    
            
        	if(mEditTextPrefServerAddr == preference)
        	{        		
        		//String tServerAddr = mSharedPrefs.getString(preference.getKey(), "N/A");
        		String tServerAddr = newValue.toString();
        		
        		if(isValidIp(tServerAddr)){
            		mServerUrl = "http://"+tServerAddr+SeedsDefinitions.SEEDS_SERVER_ADDRESS_PREFIX;
            		mEditTextPrefServerAddr.setSummary(getString(R.string.seeds_config_setserveraddrsum) + tServerAddr);
            	}
            	else{
        			showToast(R.string.seeds_config_setserveraddrfailed);
        			mEditTextPrefServerAddr.setText(SeedsDefinitions.SEEDS_SERVER_DEFAULT_FULLADDR);
            	}
        		
        		// Set the global address
        		SeedsDefinitions.setServerUrl(mServerUrl);    		
        	}
        	else if(mSwitchPrefWifi == preference)
        	{
        		boolean tFlag = mSharedPrefs.getBoolean(preference.getKey(), true);
        		if(true == tFlag)
            	    SeedsDefinitions.setDownloadImageFlag(false);
        		else
        			SeedsDefinitions.setDownloadImageFlag(true);
        	}
            return true;    
        }
        
        public boolean onPreferenceClick(Preference preference) {
        	
        	if(mPrefResetServer == preference)
        	{
        		onResetAddress();
        	}
        	if(mPrefVerifyServer == preference)
        	{
        		onVerifyAddress(mServerUrl);
        	}
        	else if(mPrefClearCache == preference)
        	{
        		onClearCache();
        	}
        	else if(mPrefChangePwd == preference)
        	{
        		boolean tPwdFlag = mSharedPrefs.getBoolean("config_enablepwd", true);
        		if (false == tPwdFlag)
        		{
        			showToast(R.string.seeds_config_toast_changepwdunavail);
        		}else{
            		Intent intent = new Intent(getActivity(), SeedsSetPasswordActivity.class);
            		startActivity(intent);        			
        		}
        	}
        	else if(mPrefAbout == preference)
        	{
        		SeedsAboutDialog tDialog = new SeedsAboutDialog(getActivity());
        		tDialog.show();
        	}
        	
        	return false;
        }
        
        public boolean isValidIp(String _inIpAddr){
            String test = "^(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|[1-9])\\."
                        + "(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\."
                        + "(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\."
                        + "(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)$";
            Pattern pattern = Pattern.compile(test);
            Matcher matcher = pattern.matcher(_inIpAddr);
            return matcher.matches();
        }
        
        public void onResetAddress(){
        	SeedsDefinitions.resetServerAddress();
        	mServerUrl = SeedsDefinitions.getServerUrl();
        	showToast(R.string.seeds_config_toast_resetserver);
        	mEditTextPrefServerAddr.setSummary(getString(R.string.seeds_config_setserveraddrindefault));
        }
        
        public void onVerifyAddress(String _inUrl) {   	
        	        	
        	mProgressDialog = ProgressDialog.show(getActivity(), "Verifying...", 
        			          getString(R.string.seeds_config_verifyserveraddrcommun)+mServerUrl, true, false);
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
    				t_MsgListData.what = MESSAGE_CONFIG_VERIFYSERVER;									
    				handler.sendMessage(t_MsgListData);	
    			}				
    		}.start();
        }
        
        public void onClearCache() {   	
        	
        	mProgressDialog = ProgressDialog.show(getActivity(), "Loading...", 
        			          getString(R.string.seeds_config_toast_clearcache), true, false);
        	mProgressDialog.setCanceledOnTouchOutside(true);
        	
    		new Thread() {
    						
    			@Override
    			public void run() {
    		    	ImageCache.clearImageCache(ImageCache.getExternalCacheDir(getActivity()));
    				Message t_MsgListData = new Message();
    				t_MsgListData.what = MEESAGE_CONFIG_CLEARCACHE;									
    				handler.sendMessage(t_MsgListData);	
    			}				
    		}.start();
        }
        
    	@SuppressLint("HandlerLeak")
		private Handler handler = new Handler(){  
    		  
            @Override  
            public void handleMessage(Message msg) {  
            	
            	switch (msg.what) {
            		case MESSAGE_CONFIG_VERIFYSERVER:
            		{
                    	if (null != mResponse)
                    	{
                    		showToast(R.string.seeds_config_verifyserveraddrsucc);
                    	}
                    	else
                    	{
                    		showToast(R.string.seeds_config_verifyserveraddrfail);
                    	}
                    	mProgressDialog.dismiss();
                    	break;
            		}
            		case MEESAGE_CONFIG_CLEARCACHE:
            		{
                        try {
            				String tCacheSize = getCacheDirSize();
                        	mPrefClearCache.setSummary(getString(R.string.seeds_config_clearcachesum)+tCacheSize);
            			} catch (Exception e) {
            				mLogger.excep(e);
            			}
                        mProgressDialog.dismiss();
                        showToast(R.string.seeds_config_clearcachedone);
                        break;
            		}
            	}        	
            	
            }
    	};
        
    	private void showToast(int _messageId) {
    		if(null != getActivity())
    			Toast.makeText(getActivity(), _messageId, Toast.LENGTH_SHORT).show();
    	}
    	
    	public String getCacheDirSize(){
        	long tCacheSizeInBytes = 0;
			try {
				tCacheSizeInBytes = ImageCache.getCacheSize(getActivity(), ImageCache.getExternalCacheDir(getActivity()));
			} catch (Exception e) {
				mLogger.excep(e);
			}
        	String tCacheSizeInString = FormetFileSize(tCacheSizeInBytes);
        	
        	return tCacheSizeInString;
    	}
    	
    	public String FormetFileSize(long fileS){
     	    
    		DecimalFormat df = new DecimalFormat("#.00");
      	    String fileSizeString = "";
      	    if (fileS < 1024)
      	    {
      	        fileSizeString = df.format((double) fileS) + "B";
      	    }
      	    else if (fileS < 1048576)
      	    {
      	        fileSizeString = df.format((double) fileS / 1024) + "KB";
      	    }
      	    else if (fileS < 1073741824)
      	    {
      	        fileSizeString = df.format((double) fileS / 1048576) + "MB";
      	    }
      	    else
      	    {
      	        fileSizeString = df.format((double) fileS / 1073741824) + "GB";
      	    }
      	    return fileSizeString;    		 
    	}
        
    }    

}

