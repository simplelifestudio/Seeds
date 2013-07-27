/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsListPerDayActivity.java
 *  Seeds
 */

package com.simplelife.seeds.android;

import java.util.ArrayList;
import java.util.HashMap;

import android.annotation.SuppressLint;
import android.app.ActionBar;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.AdapterView.OnItemClickListener;

import com.simplelife.seeds.android.SeedsFavListActivity.ListViewItemOnClickListener;
import com.simplelife.seeds.android.SeedsListActivity.SeedsAdapter;
import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;
import com.simplelife.seeds.android.utils.gridview.gridviewui.ImageGridActivity;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.ImageFetcher;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.ImageCache.ImageCacheParams;

public class SeedsListPerDayActivity extends SeedsListActivity {
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		// setTheme(android.R.style.Theme_Translucent_NoTitleBar);
		// Set the list view layout
		setContentView(R.layout.activity_seeds_listperday);
				
		// Retrieve the date info parameter
		Bundle bundle = getIntent().getExtras();
		//String tPassinDate = bundle.getString("date");
		mDate = bundle.getString("date");
		
		// Set a title for this page
		ActionBar tActionBar = getActionBar();
		tActionBar.setTitle(getString(R.string.seeds_listperday_title) + " " + mDate);
		
		// Initialize the tSeedIdList
		mSeedIdList = new ArrayList<Integer>();
		
        mImageThumbSize = getResources().getDimensionPixelSize(R.dimen.image_thumbnail_size);

        ImageCacheParams cacheParams = new ImageCacheParams(this, SeedsDefinitions.SEEDS_THUMBS_CACHE_DIR);

        // The ImageFetcher takes care of loading images into our ImageView children asynchronously
        mImageFetcher = new ImageFetcher(this, mImageThumbSize);
        mImageFetcher.setLoadingImage(R.drawable.empty_photo);
        mImageFetcher.addImageCache(this.getSupportFragmentManager(), cacheParams);
		
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
	
	@SuppressLint("HandlerLeak")
	protected Handler handler = new Handler(){
		public void handleMessage(Message msg) {
			switch(msg.what){
			case 0 :
				mListView = (ListView)findViewById(R.id.seeds_list);
				
				ArrayList<HashMap<String, String>> seedsList = (ArrayList<HashMap<String, String>>)msg.obj;
				mAdapter = new SeedsAdapter(SeedsListPerDayActivity.this, seedsList);
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
			
			Intent intent = new Intent(SeedsListPerDayActivity.this, SeedsDetailsActivity.class);
			// Pass the seed entity
		    intent.putExtra("seedObj", mSeedsEntityList.get(position));
			startActivity(intent);
		}
	}
	
	protected void loadSeedsInfo(){
		
		int localId;
		SeedsEntity tSeedsEntity;
		
		// Initialize the SeedsEntity List
		mSeedsEntityList = new ArrayList<SeedsEntity>(); 
		
		// Retrieve the DB process handler to get data 
		SeedsDBAdapter tDBAdapter = SeedsDBAdapter.getAdapter();
		
		// Query the Seed table first
		Cursor tResult = tDBAdapter.getSeedEntryViaPublishDate(mDate);		
		
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
			tSeedsEntity.setSeedPublishDate(mDate);
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
			Cursor tImgResult = tDBAdapter.getSeedPicFirstEntryViaLocalId(localId);
			
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
			tImgResult.close();
			
			// Add into the seedsEntity list
			mSeedsEntityList.add(tSeedsEntity);
			
			// Move to the next result
	        tResult.moveToNext();	        
	    }		
		tResult.close(); 
	}	
		
}
