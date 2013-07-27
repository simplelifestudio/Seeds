/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsListActivity.java
 *  Seeds 
 */

package com.simplelife.seeds.android;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.ListView;

import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;
import com.simplelife.seeds.android.utils.gridview.gridviewui.RecyclingImageView;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.ImageFetcher;
import com.simplelife.seeds.android.utils.imageprocess.SeedsImageLoader;
import com.simplelife.seeds.android.utils.seedslogger.SeedsLoggerUtil;

public abstract class SeedsListActivity extends FragmentActivity {

	public static final String KEY_THUMB_URL = "thumb_url";

	protected ListView mListView;
	protected SeedsAdapter mAdapter;
	protected String mDate;
	protected int mSeedId;
	protected List<Integer> mSeedIdList;
	
    protected int mImageThumbSize;
    protected ImageFetcher mImageFetcher;
	
    protected ArrayList<SeedsEntity> mSeedsEntityList;
	
	// For log purpose
    protected SeedsLoggerUtil mLogger = SeedsLoggerUtil.getSeedsLogger(); 
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
	}
	
    @Override
    public void onResume() {
        super.onResume();
        //mImageFetcher.setExitTasksEarly(false);
    }

    @Override
    public void onPause() {
        super.onPause();
        //mImageFetcher.setPauseWork(false);
        //mImageFetcher.setExitTasksEarly(true);
        //mImageFetcher.flushCache();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        //mImageFetcher.closeCache();
    }	

	protected ArrayList<HashMap<String, String>> getList() {
		
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
			map.put(SeedsDBAdapter.KEY_SIZE, 
					tSeedsEntity.getSeedSize()+" / "
			       +tSeedsEntity.getPicLinks().size()
			       +getString(R.string.seeds_listperday_seedspics));
			map.put(SeedsDBAdapter.KEY_FORMAT, tSeedsEntity.getSeedFormat());
			String tMosaic = (tSeedsEntity.getSeedMosaic())
					       ? getString(R.string.seeds_listperday_withmosaic)
					       : getString(R.string.seeds_listperday_withoutmosaic);
			map.put(SeedsDBAdapter.KEY_MOSAIC, tMosaic);
			map.put(KEY_THUMB_URL, tFirstImgUrl);
			
			// Add the instance into the array
			seedsList.add(map);
			
			// Record the seedId info
			mSeedIdList.add(tSeedsEntity.getSeedId());
		}
		
		return seedsList;	
	}
	
	abstract protected void loadSeedsInfo();
	
	public class SeedsAdapter extends BaseAdapter {

		protected Activity activity;
		protected ArrayList<HashMap<String, String>> data;
		protected LayoutInflater inflater = null;
		
		// Clarify the class which is used to load the image via url
		public SeedsImageLoader imageLoader; 

		public SeedsAdapter(Activity a, ArrayList<HashMap<String, String>> d) {
			activity = a;
			data     = d;
			inflater = (LayoutInflater) activity.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			imageLoader = new SeedsImageLoader(activity.getApplicationContext());
		}

		public int getCount() {
			return data.size();
		}

		public Object getItem(int position) {
			return position;
		}

		public long getItemId(int position) {
			return position;
		}

		public View getView(int position, View convertView, ViewGroup parent) {
			View vi = convertView;
			if (convertView == null)
				vi = inflater.inflate(R.layout.activity_seeds_listperday_row, null);

			TextView title  = (TextView) vi.findViewById(R.id.seeds_title); 
			TextView size   = (TextView) vi.findViewById(R.id.seeds_size); 
			TextView format = (TextView) vi.findViewById(R.id.seeds_format);
			TextView mosaic = (TextView) vi.findViewById(R.id.seeds_mosaic);
			ImageView thumb_image = (ImageView) vi.findViewById(R.id.list_image);			
			
			/*int width  = 75; //thumb_image.getMaxWidth();
			int height = 75; //thumb_image.getMaxHeight();
			mImageFetcher.setImageSize(width, height);
			Log.i("ListActivity", "width = "+width+" height="+height);
			*/
			
			thumb_image.setScaleType(ImageView.ScaleType.CENTER_CROP);

			HashMap<String, String> seedList = new HashMap<String, String>();
			seedList = data.get(position);

			// Set the values for the list view
			title.setText(seedList.get(SeedsDBAdapter.KEY_NAME));
			size.setText(seedList.get(SeedsDBAdapter.KEY_SIZE));
			format.setText(seedList.get(SeedsDBAdapter.KEY_FORMAT));
			mosaic.setText(seedList.get(SeedsDBAdapter.KEY_MOSAIC));
			mImageFetcher.loadImage(seedList.get(SeedsListPerDayActivity.KEY_THUMB_URL), thumb_image);
			/*imageLoader.DisplayImage(seedList.get(SeedsListPerDayActivity.KEY_THUMB_URL),
					thumb_image,0);*/
			return vi;
		}
		
        /*
		public void setItemHeight(int height) {
            if (height == mItemHeight) {
                return;
            }
            mItemHeight = height;
            mImageFetcher.setImageSize(height);
            notifyDataSetChanged();
        }*/
	}
		
}
