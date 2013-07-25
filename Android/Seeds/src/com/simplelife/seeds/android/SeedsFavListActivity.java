/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsFavListActivity.java
 *  Seeds
 *
 *  Created by Chris Li on 13-5-20. 
 */

package com.simplelife.seeds.android;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.simplelife.seeds.android.utils.adapter.SeedsAdapter;
import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.AdapterView.OnItemClickListener;

public class SeedsFavListActivity extends Activity{

	public static final String KEY_THUMB_URL = "thumb_url";

	private ListView tListView;
	private SeedsAdapter tAdapter;
	protected String tDate;
	protected String tFirstImgUrl;
	protected int tSeedLocalId;
	protected List<Integer> tSeedIdList;
	private ArrayList<SeedsEntity> mSeedsEntityList;
	
	// For log purpose
	private static final String LOGCLASS = "SeedsFavList"; 
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		// setTheme(android.R.style.Theme_Translucent_NoTitleBar);
		// Set the list view layout
		setContentView(R.layout.activity_seeds_favlist);
				
		// Initialize the tSeedIdList
		tSeedIdList = new ArrayList();
		
		// Start a new thread to get the data
		new Thread(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				Message msg = new Message();
				msg.what = 0;
				
				// Retrieve the seeds list
				msg.obj = getList();
				handler.sendMessage(msg);
			}
		}).start();		
	}
	
	private Handler handler = new Handler(){
		public void handleMessage(Message msg) {
			switch(msg.what){
			case 0 :
				tListView = (ListView)findViewById(R.id.seeds_list);
				
				ArrayList<HashMap<String, String>> seedsList = (ArrayList<HashMap<String, String>>)msg.obj;
				tAdapter = new SeedsAdapter(SeedsFavListActivity.this, seedsList);
				tListView.setAdapter(tAdapter);

				// Bond the click listener
				tListView.setOnItemClickListener(new ListViewItemOnClickListener());
				break;
			}
		}
	};
	
	class ListViewItemOnClickListener implements OnItemClickListener {
		@Override
		public void onItemClick(AdapterView<?> parent, View view,
				int position, long id) {
			
			// Redirect to the details page
			Intent intent = new Intent(SeedsFavListActivity.this, SeedsDetailsActivity.class);

			// Pass the seed entity
		    intent.putExtra("seedObj", mSeedsEntityList.get(position));
			startActivity(intent);
		}
	}	
	
	private ArrayList<HashMap<String, String>> getList() {
		
		ArrayList<HashMap<String, String>> seedsList = new ArrayList<HashMap<String, String>>();
		String tFirstImgUrl;
		
		// Load all the seeds info
		loadSeedsInfo();
		
		// Walk through the SeedsEntity List
		int tListSize = mSeedsEntityList.size();
		for (int index = 0; index < tListSize; index++)
		{
			SeedsEntity tSeedsEntity = mSeedsEntityList.get(index);
					
			if(tSeedsEntity.getSeedIsPicAvail())
				tFirstImgUrl = tSeedsEntity.getPicLinks().get(0);
			else
				tFirstImgUrl = "Nothing To Show";
			
			HashMap<String, String> map = new HashMap<String, String>();
			map.put(SeedsDBAdapter.KEY_NAME, tSeedsEntity.getSeedName());
			map.put(SeedsDBAdapter.KEY_SIZE, tSeedsEntity.getSeedSize());
			map.put(SeedsDBAdapter.KEY_FORMAT, tSeedsEntity.getSeedFormat());
			String tMosaic = (tSeedsEntity.getSeedMosaic())
					       ? getString(R.string.seeds_listperday_withmosaic)
					       : getString(R.string.seeds_listperday_withoutmosaic);
			map.put(SeedsDBAdapter.KEY_MOSAIC, tMosaic);
			map.put(KEY_THUMB_URL, tFirstImgUrl);
			
			// Add the instance into the array
			seedsList.add(map);
			
			// Record the seedId info
			tSeedIdList.add(tSeedsEntity.getSeedId());
		}
		
		return seedsList;	
	}
	
	private void loadSeedsInfo(){
		
		int localId;
		SeedsEntity tSeedsEntity;
		
		// Initialize the SeedsEntity List
		mSeedsEntityList = new ArrayList<SeedsEntity>(); 
		
		// Retrieve the DB process handler to get data 
		SeedsDBAdapter mDBAdapter = SeedsDBAdapter.getAdapter();
		
		// Get the seeds entries according to the favorite tag
		Cursor tResult = mDBAdapter.getSeedEntryViaFavTag();	
		
		Log.i(LOGCLASS, "The size of the tResult is  "+ tResult.getCount());
		tResult.moveToFirst(); 
		while (!tResult.isAfterLast()) 
	    {
			localId = tResult.getInt(tResult.getColumnIndex(SeedsDBAdapter.KEY_ID_SEED));
			// Construct seeds entity
			tSeedsEntity = new SeedsEntity();
			tSeedsEntity.setLocalId(localId);
			tSeedsEntity.setSeedId(tResult.getInt(tResult.getColumnIndex(SeedsDBAdapter.KEY_SEEDID)));
			tSeedsEntity.setSeedType(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_TYPE)));
			tSeedsEntity.setSeedSource(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_SOURCE)));
			tSeedsEntity.setSeedPublishDate(tDate);
			tSeedsEntity.setSeedName(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_NAME)));
			tSeedsEntity.setSeedSize(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_SIZE)));
			tSeedsEntity.setSeedFormat(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_FORMAT)));
			tSeedsEntity.setSeedTorrentLink(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_TORRENTLINK)));
			tSeedsEntity.setSeedHash(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_HASH)));
			if(1 == tResult.getInt(tResult.getColumnIndex(SeedsDBAdapter.KEY_MOSAIC)))
				tSeedsEntity.setSeedMosaic(true);
			else
				tSeedsEntity.setSeedMosaic(false);
			if(1 == tResult.getInt(tResult.getColumnIndex(SeedsDBAdapter.KEY_FAVORITE)))
				tSeedsEntity.setSeedFavorite(true);
			else
				tSeedsEntity.setSeedFavorite(false);
			
			// Query the seedPic table
			Cursor tImgResult = mDBAdapter.getSeedPicFirstEntryViaLocalId(localId);
			
			if(tImgResult.getCount()<=0)
			{
				tSeedsEntity.setSeedIsPicAvail(false);
			}
			else{
				tImgResult.moveToFirst();
				// Think twice if we really need a while loop here
				while(!tImgResult.isAfterLast())
				{
					String tPicUrl = tImgResult.getString(tImgResult.getColumnIndex(SeedsDBAdapter.KEY_PICTURELINK));
					tSeedsEntity.addPicLink(tPicUrl);
					
					// Move to the next result
					tImgResult.moveToNext(); 
				}
				tSeedsEntity.setSeedIsPicAvail(true);											
			}						
			
			// Add into the seedsEntity list
			mSeedsEntityList.add(tSeedsEntity);
			
			// Move to the next result
	        tResult.moveToNext();	        
	    }		
		tResult.close(); 
	}

}
