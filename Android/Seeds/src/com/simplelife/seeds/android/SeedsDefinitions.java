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
	
	public class SeedsGlobalErrorCode{
		public static final String SEEDS_ERROR_WRONGREALDATE = "Wrong Calendar Date Detected!";
		public static final String SEEDS_ERROR_WRONGLOGICDATE = "Wrong Logic Date Detected!";
	}
	
	public static String serverUrl = "http://106.187.38.52:80/seeds/messageListener";
	
	public static void setServerUrl(String _inUrl){
		serverUrl = _inUrl;
	}
	
	public static String getServerUrl(){
		return serverUrl;
	}
	
}
