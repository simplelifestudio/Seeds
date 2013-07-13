/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsWirelessManager.java
 *  Seeds
 *
 *  Created by Chris Li on 13-7-12. 
 */

package com.simplelife.seeds.android.utils.wirelessmanager;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo.State;


public class SeedsWirelessManager {

	public static boolean isMobileDataOpen(Context _context){
		ConnectivityManager tConMan = (ConnectivityManager)
				_context.getSystemService(Context.CONNECTIVITY_SERVICE);
		
		State tMobile = tConMan.getNetworkInfo(ConnectivityManager.TYPE_MOBILE).getState();
		
        if(tMobile == State.CONNECTED)
            return true;
        else
        	return false;
	}
	
	public static boolean isWifiOpen(Context _context){
		ConnectivityManager tConMan = (ConnectivityManager)
				_context.getSystemService(Context.CONNECTIVITY_SERVICE);
		
		State tWifi = tConMan.getNetworkInfo(ConnectivityManager.TYPE_WIFI).getState();
		
        if(tWifi == State.CONNECTED)
            return true;
        else
        	return false;
	}
	
}
