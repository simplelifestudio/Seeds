/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsDateManager.java
 *  Seeds
 *
 *  Created by Chris Li on 13-5-20. 
 */

package com.simplelife.seeds.android;

import java.text.SimpleDateFormat;
import java.util.Calendar;

import com.simplelife.seeds.android.SeedsDefinitions.SeedsGlobalErrorCode;

import android.content.Context;
import android.util.Log;

public class SeedsDateManager {
	
 	// Context of the application using the database.  
 	private final Context context;
 	
	// Date in string format
	private String mDateBefYesterday;
	private String mDateYesterday;
	private String mDateToday;
 	 	
    // Singleton Pattern  
    private static SeedsDateManager mInstance = null;  
	
 	public SeedsDateManager (Context _context) { 		
 		context = _context;
 		
 		// Calculate the date
 		Calendar tCal = Calendar.getInstance();
 		mDateToday = new SimpleDateFormat("yyyy-MM-dd").format(tCal.getTime());
 		tCal.add(Calendar.DATE, -1);
 		mDateYesterday = new SimpleDateFormat("yyyy-MM-dd").format(tCal.getTime());
 		tCal.add(Calendar.DATE, -1);
 		mDateBefYesterday = new SimpleDateFormat("yyyy-MM-dd").format(tCal.getTime());
 	}  
	
    public static SeedsDateManager getDateManager(){  
        return mInstance;  
    } 
    
    public static void initDateManager(Context _context){  
    	Log.i("SeedsDBAdapter", "Initialize the Date Manager!");
    	if(mInstance == null){  
    		mInstance = new SeedsDateManager(_context);  
        }     	
    }
    
    public String getRealDateBefYesterday(){
    	return mDateBefYesterday;
    }
    
    public String getRealDateYesterday(){
    	return mDateYesterday;
    }
    
    public String getRealDateToday(){
    	return mDateToday;
    }
    
    public String logicDateToRealDate(String _inRealDate){
    	
    	if(_inRealDate.equals(mDateBefYesterday))
    		return SeedsDefinitions.SEEDS_DATE_BEFYESTERDAY;
    	else if(_inRealDate.equals(mDateYesterday))
    		return SeedsDefinitions.SEEDS_DATE_YESTERDAY;
    	else if(_inRealDate.equals(mDateToday))
    		return SeedsDefinitions.SEEDS_DATE_TODAY;
    	else
    		return SeedsGlobalErrorCode.SEEDS_ERROR_WRONGREALDATE;    	
    }
    
    public String realDateToLogicDate(String _inLogicDate){
    	if(_inLogicDate.equals(SeedsDefinitions.SEEDS_DATE_BEFYESTERDAY))
    		return mDateBefYesterday;
    	else if(_inLogicDate.equals(SeedsDefinitions.SEEDS_DATE_YESTERDAY))
    		return mDateYesterday;
    	else if(_inLogicDate.equals(SeedsDefinitions.SEEDS_DATE_TODAY))
    		return mDateToday;
    	else
    		return SeedsGlobalErrorCode.SEEDS_ERROR_WRONGLOGICDATE;    	
    }
	
}
