/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsRSSCartActivity.java
 *  Seeds
 *
 *  Created by Chris Li on 13-7-19. 
 */
package com.simplelife.seeds.android;

import java.util.ArrayList;
import java.util.HashMap;
import com.simplelife.seeds.android.utils.adapter.SeedsAdapter;
import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.AdapterView.OnItemClickListener;

public class SeedsRSSCartActivity extends Activity{
	
	public static final String KEY_TITLE  = "name";
	public static final String KEY_SIZE   = "size";
	public static final String KEY_FORMAT = "format";
	public static final String KEY_THUMB_URL = "thumb_url";
	
	private static ArrayList<Integer> mSeedLocalIdInCart;
	private ArrayList<Integer> mSeedIdInCart;
	private ListView mListView;
	private SeedsAdapter mAdapter;
	private String mDate;
	private ArrayList<SeedsEntity> mSeedsEntityList;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		// setTheme(android.R.style.Theme_Translucent_NoTitleBar);
		// Set the list view layout
		setContentView(R.layout.activity_seeds_favlist);
				
		// Initialize the mSeedIdInCart
		mSeedLocalIdInCart = new ArrayList();
		mSeedIdInCart = new ArrayList();
		
		// Start a new thread to get the data
		new Thread(new Runnable() {
			@Override
			public void run() {
				Message msg = new Message();
				msg.what = 0;
				
				// Retrieve the seeds list
				msg.obj = getList();
				handler.sendMessage(msg);
			}
		}).start();		
	}
	
	@SuppressLint("HandlerLeak")
	private Handler handler = new Handler(){
		public void handleMessage(Message msg) {
			switch(msg.what){
			case 0 :
				mListView = (ListView)findViewById(R.id.seeds_list);
				
				ArrayList<HashMap<String, String>> seedsList = (ArrayList<HashMap<String, String>>)msg.obj;
				mAdapter = new SeedsAdapter(SeedsRSSCartActivity.this, seedsList);
				mListView.setAdapter(mAdapter);

				// Bond the click listener
				mListView.setOnItemClickListener(new ListViewItemOnClickListener());
				break;
			}
		}
	};
	
	class ListViewItemOnClickListener implements OnItemClickListener {
		@Override
		public void onItemClick(AdapterView<?> parent, View view,
				int position, long id) {
			
			// Redirect to the details page
			Intent intent = new Intent(SeedsRSSCartActivity.this, SeedsDetailsActivity.class);

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
			map.put(KEY_TITLE, tSeedsEntity.getSeedName());
			map.put(KEY_SIZE, tSeedsEntity.getSeedSize());
			map.put(KEY_FORMAT, tSeedsEntity.getSeedFormat());
			map.put(KEY_THUMB_URL, tFirstImgUrl);
			
			// Add the instance into the array
			seedsList.add(map);			
		}
		
		return seedsList;	
	}
	
	private void loadSeedsInfo(){
		
		int localId;
		int remoteId;
		SeedsEntity tSeedsEntity;
		
		// Initialize the SeedsEntity List
		mSeedsEntityList = new ArrayList<SeedsEntity>(); 
		
		// Retrieve the DB process handler to get data 
		SeedsDBAdapter mDBAdapter = SeedsDBAdapter.getAdapter();
		
		int tSeedLocalIdSize = mSeedLocalIdInCart.size();
		for(int index = 0; index < tSeedLocalIdSize; index++)
		{
			int tSeedLocalId = mSeedLocalIdInCart.get(index);
			
			// Get the seeds entries according to the favorite tag
			Cursor tResult = mDBAdapter.getSeedEntryViaLocalId(tSeedLocalId);
			if (!tResult.isAfterLast()) 
		    {
				localId  = tResult.getInt(tResult.getColumnIndex(SeedsDBAdapter.KEY_ID_SEED));
				remoteId = tResult.getInt(tResult.getColumnIndex(SeedsDBAdapter.KEY_SEEDID));
				// Construct seeds entity
				tSeedsEntity = new SeedsEntity();
				tSeedsEntity.setLocalId(localId);
				tSeedsEntity.setSeedId(remoteId);
				tSeedsEntity.setSeedType(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_TYPE)));
				tSeedsEntity.setSeedSource(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_SOURCE)));
				tSeedsEntity.setSeedPublishDate(mDate);
				tSeedsEntity.setSeedName(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_NAME)));
				tSeedsEntity.setSeedSize(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_SIZE)));
				tSeedsEntity.setSeedFormat(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_FORMAT)));
				tSeedsEntity.setSeedTorrentLink(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_TORRENTLINK)));
				tSeedsEntity.setSeedHash(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_HASH)));
				tSeedsEntity.setSeedMosaic(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_MOSAIC)));
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
				// Add the remote SeedId into the list
				mSeedIdInCart.add(remoteId);
		    }
			tResult.close();
		}
	 
	}
	
	public static void addSeedToCart(int _inSeedLocalId){
		mSeedLocalIdInCart.add(_inSeedLocalId);
	}
	
	private void sendRSSBookMessage(){
		
	}
}
