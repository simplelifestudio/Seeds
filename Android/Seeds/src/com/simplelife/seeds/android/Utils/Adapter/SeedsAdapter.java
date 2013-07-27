/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsAdapter.java
 *  Seeds
 */
/*
package com.simplelife.seeds.android.utils.adapter;

import java.util.ArrayList;
import java.util.HashMap;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.simplelife.seeds.android.R;
import com.simplelife.seeds.android.SeedsListPerDayActivity;
import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;
import com.simplelife.seeds.android.utils.gridview.gridviewprovider.Images;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.ImageFetcher;
import com.simplelife.seeds.android.utils.imageprocess.SeedsImageLoader;

public class SeedsAdapter extends BaseAdapter {

	private Activity activity;
	private ArrayList<HashMap<String, String>> data;
	private static LayoutInflater inflater = null;
    private int mImageThumbSize;
    private ImageFetcher mImageFetcher;
	
	// Clarify the class which is used to load the image via url
	//public SeedsImageLoader imageLoader; 

	public SeedsAdapter(Activity a, ArrayList<HashMap<String, String>> d) {
		activity = a;
		data     = d;
		inflater = (LayoutInflater) activity.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		mImageThumbSize = a.getResources().getDimensionPixelSize(R.dimen.image_thumbnail_size);
		//imageLoader = new SeedsImageLoader(activity.getApplicationContext());
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

		HashMap<String, String> seedList = new HashMap<String, String>();
		seedList = data.get(position);

		// Set the values for the list view
		title.setText(seedList.get(SeedsDBAdapter.KEY_NAME));
		size.setText(seedList.get(SeedsDBAdapter.KEY_SIZE));
		format.setText(seedList.get(SeedsDBAdapter.KEY_FORMAT));
		mosaic.setText(seedList.get(SeedsDBAdapter.KEY_MOSAIC));
		mImageFetcher.loadImage(seedList.get(SeedsListPerDayActivity.KEY_THUMB_URL), thumb_image);
		//imageLoader.DisplayImage(seedList.get(SeedsListPerDayActivity.KEY_THUMB_URL),
		//		thumb_image,0);
		return vi;
	}
}*/