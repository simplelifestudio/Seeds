/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsImagesPreload.java
 *  Seeds
 *
 *  Created by Chris Li on 13-5-20. 
 */

package com.simplelife.seeds.android;

import java.util.ArrayList;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

public class SeedsImageUrlPreloader {

	// The lists which stores the image urls
	public static ArrayList<String> mImageUrlsOfBef;
	public static ArrayList<String> mImageUrlsOfYes;
	public static ArrayList<String> mImageUrlsOfTod;
	
 	// Context of the application using the database.  
 	private final Context context;
 	
 	// Use SharedPref to record the preload status
 	private static SharedPreferences mSharedPref;
 	
    // Singleton Pattern  
    private static SeedsImageUrlPreloader mInstance = null;  
	
 	public SeedsImageUrlPreloader (Context _context) { 		
 		context = _context;
 		
 		// Initialize the lists
 		mImageUrlsOfBef = new ArrayList<String>();
 		mImageUrlsOfYes = new ArrayList<String>();
 		mImageUrlsOfTod = new ArrayList<String>();
 	}  
	
    public static SeedsImageUrlPreloader getPreloader(){  
        return mInstance;  
    } 
    
    public static void initPreloader(Context _context){  
    	Log.i("SeedsDBAdapter", "Initialize the Image Preloader!");
    	if(mInstance == null){  
    		mInstance = new SeedsImageUrlPreloader(_context);  
        } 
    	
		// Get the shared preference file instance
		//mSharedPref = getSharedPreferences(
		//        getString(R.string.seeds_preffilename), Context.MODE_PRIVATE);
    }
    

	public void addToBefImageList(String _inUrl){
    	mImageUrlsOfBef.add(_inUrl);
    }
    
    public void addToYestImageList(String _inUrl){
    	mImageUrlsOfYes.add(_inUrl);
    }
    
    public void addToTodImageList(String _inUrl){
    	mImageUrlsOfTod.add(_inUrl);
    }
	
    public void clearBefImageList(){
    	mImageUrlsOfBef.clear();
    }
    
    public void clearYestImageList(){
    	mImageUrlsOfYes.clear();
    }
    
    public void clearTodImageList(){
    	mImageUrlsOfTod.clear();
    }
    
    public void clearAllImageList(){
    	clearBefImageList();
    	clearYestImageList();
    	clearTodImageList();
    }
    
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
    
    private void loadImageUrls(String _inRealDate){
    	
    }	
}
