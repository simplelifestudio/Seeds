/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsFavListActivity.java
 *  Seeds
 */

package com.simplelife.seeds.android;

import java.util.ArrayList;
import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;
import com.simplelife.seeds.android.utils.gridview.gridviewui.ImageGridActivity;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.ImageFetcher;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.ImageCache.ImageCacheParams;

import android.annotation.SuppressLint;
import android.app.ActionBar;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.app.AlertDialog.Builder;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.Toast;
import android.widget.AdapterView.OnItemClickListener;

public class SeedsFavListActivity extends SeedsListActivity{
	
	private ProgressDialog mProgressDialog = null;
	protected final int MESSAGE_LOAD_ADAPTER  = 300;
	protected final int MESSAGE_LOAD_DISMISSDIALOG  = 301;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		// setTheme(android.R.style.Theme_Translucent_NoTitleBar);
		// Set the list view layout
		setContentView(R.layout.activity_seeds_favlist);				
				
		// Set a title for this page
		ActionBar tActionBar = getActionBar();
		tActionBar.setTitle(getString(R.string.seeds_datelist_favoritelist));
		
		// Initialize the tSeedIdList
		mSeedIdList = new ArrayList<Integer>();
		
        mImageThumbSize = getResources().getDimensionPixelSize(R.dimen.image_thumbnail_size);

        ImageCacheParams cacheParams = new ImageCacheParams(this, SeedsDefinitions.SEEDS_THUMBS_CACHE_DIR);

        // The ImageFetcher takes care of loading images into our ImageView children asynchronously
        mImageFetcher = new ImageFetcher(this, mImageThumbSize);
        mImageFetcher.setLoadingImage(R.drawable.empty_photo);
        mImageFetcher.addImageCache(this.getSupportFragmentManager(), cacheParams, "FAVTAG");			
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		// Start a new thread to get the data
		new Thread(new Runnable() {
			@Override
			public void run() {
				Message msg = new Message();
				msg.what = MESSAGE_LOAD_ADAPTER;
				
				// Retrieve the seeds list
				msg.obj = getList();
				handler.sendMessage(msg);
			}
		}).start();	
	}
	
	@SuppressLint("HandlerLeak")
	protected Handler handler = new Handler(){
		@SuppressWarnings("unchecked")
		public void handleMessage(Message msg) {
			switch(msg.what){
			case MESSAGE_LOAD_ADAPTER:
			{
				mListView = (ListView)findViewById(R.id.seeds_list);
				
				mSeedsListForListView = (ArrayList<SeedsEntity>)msg.obj;
				mAdapter = new SeedsAdapter(SeedsFavListActivity.this, mSeedsListForListView);
				mListView.setAdapter(mAdapter);

				// Bond the click listener
				mListView.setOnItemClickListener(new ListViewItemOnClickListener());
				mListView.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE_MODAL);
				mListView.setMultiChoiceModeListener(new ModeCallback());				
				break;				
			}
			case MESSAGE_LOAD_DISMISSDIALOG:
			{
				mProgressDialog.dismiss();
				Toast.makeText(SeedsFavListActivity.this, R.string.seeds_favlist_deletedialogdone, Toast.LENGTH_SHORT).show();				
			}

			}
		}
	};
	
    private void setAsUnFavorite(final int _inLocalId){
    	// Get the DB adapter instance
		SeedsDBAdapter mDBAdapter = SeedsDBAdapter.getAdapter();					
		mDBAdapter.updateSeedEntryFav(_inLocalId,false);           							
	}
	
	protected void onMultiChosenProcess(final ArrayList<SeedsEntity> _intSeedsSelectedList){
		AlertDialog.Builder builder = new Builder(SeedsFavListActivity.this);
		builder.setMessage(getString(R.string.seeds_favlist_deletedialogmsg));
		builder.setTitle(getString(R.string.seeds_favlist_deletedialognote));
		builder.setPositiveButton(R.string.seeds_favlist_deletedialogpos, new DialogInterface.OnClickListener() {
		    @Override
	        public void onClick(DialogInterface dialog, int which) {
			    dialog.dismiss();
	            mProgressDialog = ProgressDialog.show(SeedsFavListActivity.this, "Loading...", 
  			          getString(R.string.seeds_favlist_deletedialoging), true, false);
  	            mProgressDialog.setCanceledOnTouchOutside(true);      	
			    int tSeedsNumInList = _intSeedsSelectedList.size();
			    for(int index=0; index<tSeedsNumInList; index++)
			    {
			        setAsUnFavorite(_intSeedsSelectedList.get(index).getSeedLocalId());
			        mSeedsEntityList.remove(_intSeedsSelectedList.get(index));
			        mSeedsListForListView.remove(_intSeedsSelectedList.get(index));
			    }
			    mAdapter.notifyDataSetChanged();
			    mProgressDialog.dismiss();
				Toast.makeText(SeedsFavListActivity.this, R.string.seeds_favlist_deletedialogdone, Toast.LENGTH_SHORT).show();

			}				
		});

		builder.setNegativeButton(R.string.seeds_favlist_deletedialogneg, new DialogInterface.OnClickListener() {
		    @Override
		    public void onClick(DialogInterface dialog, int which) {
		        dialog.dismiss();
		    }
		});

		builder.create().show();							
	}
	
	class ListViewItemOnClickListener implements OnItemClickListener {
		@Override
		public void onItemClick(AdapterView<?> parent, View view,
				int position, long id) {
			// Redirect to the details page
			Intent intent = new Intent(SeedsFavListActivity.this, ImageGridActivity.class);

			// Pass the seed entity
		    intent.putExtra("seedObj", mSeedsEntityList.get(position));
			startActivity(intent);
		}
	}		
	
	protected void loadSeedsInfo(){
		
		int localId;
		SeedsEntity tSeedsEntity;
		
		mSeedsEntityList.clear();
		
		// Retrieve the DB process handler to get data 
		SeedsDBAdapter tDBAdapter = SeedsDBAdapter.getAdapter();
		
		// Get the seeds entries according to the favorite tag
		Cursor tResult = tDBAdapter.getSeedEntryViaFavTag();	
		
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
			tSeedsEntity.setSeedPublishDate(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_PUBLISHDATE)));
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
