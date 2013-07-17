/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsDefinitions.java
 *  Seeds
 *
 *  Created by Chris Li on 13-5-20. 
 */

package com.simplelife.seeds.android;

public class SeedsDefinitions {
	
	// The string definitions of the dates
	public static final String SEEDS_DATE_BEFYESTERDAY = "befyesterday";
	public static final String SEEDS_DATE_YESTERDAY = "yesterday";
	public static final String SEEDS_DATE_TODAY = "today";	
	public static final String SEEDS_SERVER_DOWNLOADPHP = "http://www.maxp2p.com/load.php";
		
	// The three seeds status by date 
	public static String SEEDS_INFO_READY = "READY";
	public static String SEEDS_INFO_NOTREADY = "NOT_READY";
	public static String SEEDS_INFO_NOUPDATE = "NO_UPDATE";
	public static String SEEDS_INFO_NOTSYNCED = "NOT_SYNCRONIZED";
	
	public class SeedsGlobalErrorCode{
		public static final String SEEDS_ERROR_WRONGREALDATE = "Wrong Calendar Date Detected!";
		public static final String SEEDS_ERROR_WRONGLOGICDATE = "Wrong Logic Date Detected!";
	}
	
	public static String SEEDS_SERVER_ADDRESS_PREFIX = "/seeds/seedService";
	public static String mServerUrl = "http://106.187.38.78:80/seeds/seedService";
	
	public static boolean mDownloadImageWithoutWifiEnabled = true;
	
	
	public static void setServerUrl(String _inUrl){
		mServerUrl = _inUrl;
	}
	
	public static String getServerUrl(){
		return mServerUrl;
	}
	
	public static void setDownloadImageFlag(boolean _inFlag){
		mDownloadImageWithoutWifiEnabled = _inFlag;
	}
	
	public static boolean getDownloadImageFlag(){
		return mDownloadImageWithoutWifiEnabled;
	}
}
