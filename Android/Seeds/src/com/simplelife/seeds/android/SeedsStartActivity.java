/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsStartActivity.java
 *  Seeds
 *
 *  Created by Chris Li on 13-5-20. 
 */

package com.simplelife.seeds.android;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;

import com.google.code.microlog4android.config.PropertyConfigurator;
import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;
import com.simplelife.seeds.android.utils.downloadprocess.DownloadManager;
import com.simplelife.seeds.android.utils.downloadprocess.DownloadService;
import com.simplelife.seeds.android.utils.downloadprocess.ui.DownloadList;

public class SeedsStartActivity extends Activity {
	
	private static BroadcastReceiver mReceiver = null;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		final View startView = View.inflate(this,R.layout.activity_seeds_start,null);
		//setContentView(R.layout.activity_seeds_start);
		setContentView(startView);
		
		// Fade in and fade out
		AlphaAnimation fadeShow = new AlphaAnimation(0.3f,1.0f);
		fadeShow.setDuration(1000);
		startView.startAnimation(fadeShow);		
		
		// Start the Logger instance
		PropertyConfigurator.getConfigurator(this).configure();
		
		// Start the date manager
		SeedsDateManager.initDateManager(getApplication());

		// Start the DB process
		SeedsDBAdapter.initAdapter(getApplication());
		
		// Start the Seeds Imgae URL preload thread
		SeedsImageUrlPreloader.initPreloader(getApplication());
		
		// Initialize the download manager
		DownloadManager.initDownloadMgr(getContentResolver(),getPackageName());
		
		// Start the download service
		startDownloadService();
		
		// Stay for a moments and redirect
		fadeShow.setAnimationListener(new AnimationListener()
		{
			@Override
			public void onAnimationEnd(Animation arg0) {
				redirectTo();
			}
			@Override
			public void onAnimationRepeat(Animation animation) {}
			@Override
			public void onAnimationStart(Animation animation) {}			
		});
		
	}
	
	private void redirectTo(){       
		Intent intent = new Intent(this, SeedsPasswordActivity.class);
		startActivity(intent);
		finish();
	}
	
	private void startDownloadService(){
		// Start the download service
		Intent intent = new Intent();
		intent.setClass(this, DownloadService.class);
		startService(intent);
		
	    mReceiver = new BroadcastReceiver() {

	          @Override
	          public void onReceive(Context context, Intent intent) {
		            //showDownloadList();
	        		Intent intent2 = new Intent();
	        		intent2.setClass(context, DownloadList.class);
	        		context.startActivity(intent2);
	          }
	      };

	      registerReceiver(mReceiver, new IntentFilter(DownloadManager.ACTION_NOTIFICATION_CLICKED));		
	}
	
    @Override
    protected void onDestroy() {
	      unregisterReceiver(mReceiver);
	      super.onDestroy();
    }



}