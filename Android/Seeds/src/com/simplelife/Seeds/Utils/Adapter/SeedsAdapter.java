package com.simplelife.Seeds.Utils.Adapter;

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

import com.simplelife.Seeds.R;
import com.simplelife.Seeds.SeedsListPerDayActivity;
import com.simplelife.Seeds.Utils.ImageProcess.SeedsImageLoader;

public class SeedsAdapter extends BaseAdapter {

	private Activity activity;
	private ArrayList<HashMap<String, String>> data;
	private static LayoutInflater inflater = null;
	
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
		ImageView thumb_image = (ImageView) vi.findViewById(R.id.list_image);

		HashMap<String, String> seedList = new HashMap<String, String>();
		seedList = data.get(position);

		// 设置ListView的相关值
		title.setText(seedList.get(SeedsListPerDayActivity.KEY_TITLE));
		size.setText(seedList.get(SeedsListPerDayActivity.KEY_SIZE));
		format.setText(seedList.get(SeedsListPerDayActivity.KEY_FORMAT));
		imageLoader.DisplayImage(seedList.get(SeedsListPerDayActivity.KEY_THUMB_URL),
				thumb_image);
		return vi;
	}
}