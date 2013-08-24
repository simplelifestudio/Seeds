/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsListActivity.java
 *  Seeds 
 */

package com.simplelife.seeds.android;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.ActionMode;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.ListView;

import com.simplelife.seeds.android.SeedsDefinitions.SeedsGlobalNOTECode;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.ImageFetcher;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.ImageWorker;
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
    protected ArrayList<SeedsEntity> mSeedsEntityChosen;
    protected ArrayList<SeedsEntity> mSeedsEntityChosenToDel;
    protected ArrayList<View> mSeedsViewsChosen;
    protected ArrayList<ImageView> mImageViewList;
    protected ArrayList<SeedsEntity> mSeedsListForListView;
    
    protected ArrayList<Integer> mSelectedList; 
	
	// For log purpose
    protected SeedsLoggerUtil mLogger; 
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		mLogger = SeedsLoggerUtil.getSeedsLogger(SeedsListActivity.this);
		
		// Initialize the SeedsEntity List
		mSeedsEntityList = new ArrayList<SeedsEntity>();
		mSeedsListForListView = new ArrayList<SeedsEntity>();
		mSeedsEntityChosen = new ArrayList<SeedsEntity>();
		mSeedsEntityChosenToDel = new ArrayList<SeedsEntity>();
		mSeedsViewsChosen  = new  ArrayList<View>();
		mImageViewList = new ArrayList<ImageView>();
		mSelectedList  = new ArrayList<Integer>();
	}
	
    @Override
    protected void onResume() {
        super.onResume();
        mImageFetcher.setExitTasksEarly(false);
    }

    @Override
    protected void onPause() {
        super.onPause();
        mImageFetcher.setPauseWork(false);
        mImageFetcher.setExitTasksEarly(true);
        mImageFetcher.flushCache();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mLogger.debug("Destroying image views!");
        int tImageViewSize = mImageViewList.size();
        for(int index=0; index<tImageViewSize; index++)
        {
        	ImageView tImageView = mImageViewList.get(index);
            if (tImageView != null) {
                // Cancel any pending image work
                ImageWorker.cancelWork(tImageView);
                tImageView.setImageDrawable(null);
            }
        }

        mImageFetcher.closeCache();
    }	

	protected ArrayList<SeedsEntity> getList() {
		loadSeedsInfo();				
		return mSeedsEntityList;	
	}
	
	abstract protected void loadSeedsInfo();
	
	protected void onMultiChosenProcess(ArrayList<SeedsEntity> _intSeedsSelectedList){		
	}
	
	protected class ModeCallback implements ListView.MultiChoiceModeListener{
        
		public boolean onCreateActionMode(ActionMode mode, Menu menu) {
            MenuInflater inflater = SeedsListActivity.this.getMenuInflater();
            mSeedsEntityChosen.clear();
            mSeedsEntityChosenToDel.clear();
            mSeedsViewsChosen.clear();
            inflater.inflate(R.menu.activity_seeds_list_contextualmenu, menu);
            mode.setTitle(getString(R.string.seeds_list_contextualtitle));
            setSubtitle(mode);
            return true;
        }

        public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
            return true;
        }

        public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
            switch (item.getItemId()) {
            case R.id.seedslist_del:
            	onMultiChosenProcess(mSeedsEntityChosenToDel);
                mode.finish();
            break;
            default:
            break;
            }
            return true;
        }

        public void onDestroyActionMode(ActionMode mode) {        	
        	int tNumOfView = mSeedsViewsChosen.size();
        	mLogger.debug("Destroying the action mode, list size:" + tNumOfView);
        	for(int index=0; index<tNumOfView; index++)
        	{
        		mLogger.debug("Setting back the backgound");
        		mSeedsViewsChosen.get(index).setBackgroundResource(R.drawable.seedslist_selector);
        	    mSeedsViewsChosen.get(index).setPadding(8, 8, 8, 8);
        	}
        	mSeedsViewsChosen.clear();
        	mSeedsEntityChosen.clear();
        }

        public void onItemCheckedStateChanged(ActionMode mode,
            int position, long id, boolean checked) {
        	View tItemSelected = mListView.getChildAt(position - mListView.getFirstVisiblePosition());
        	if (checked)
        	{
        		mLogger.debug("Seeds added to list " + mSeedsEntityList.get(position).getSeedLocalId());
        		mSeedsEntityChosen.add(mSeedsEntityList.get(position));
        		mSeedsEntityChosenToDel.add(mSeedsEntityList.get(position));
        		mSeedsViewsChosen.add(tItemSelected);
        		tItemSelected.setBackgroundResource(R.drawable.seedsgradient_bg_hover);
        	}
        	else
        	{
        		mLogger.debug("Remove seeds " + mSeedsEntityList.get(position).getSeedLocalId());
        		mSeedsEntityChosen.remove(mSeedsEntityList.get(position));
        		mSeedsEntityChosenToDel.remove(mSeedsEntityList.get(position));
        		mSeedsViewsChosen.remove(tItemSelected);
        		tItemSelected.setBackgroundResource(R.drawable.seedslist_selector);
        		tItemSelected.setPadding(8, 8, 8, 8);
        	}
            setSubtitle(mode);
        }

        private void setSubtitle(ActionMode mode) {
            final int checkedCount = mListView.getCheckedItemCount();
            switch (checkedCount) {
            case 0:
                mode.setSubtitle(null);
                break;
            case 1:
                mode.setSubtitle(getString(R.string.seeds_list_contextualsubtitle1)
                		       +"1"
                		       +getString(R.string.seeds_list_contextualsubtitle2));
                break;
            default:
                mode.setSubtitle(getString(R.string.seeds_list_contextualsubtitle1)
                		        +checkedCount
                		        +getString(R.string.seeds_list_contextualsubtitle2));
                break;
            }
        }
	}	
	
	public class SeedsAdapter extends BaseAdapter {

		protected Activity activity;
		protected ArrayList<SeedsEntity> data;
		protected LayoutInflater inflater = null;		

		public SeedsAdapter(Activity a, ArrayList<SeedsEntity> d) {
			activity = a;
			data     = d;
			inflater = (LayoutInflater) activity.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
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
			String tFirstImgUrl;
			if (convertView == null)
				vi = inflater.inflate(R.layout.activity_seeds_listperday_row, null);							
				
			TextView title  = (TextView) vi.findViewById(R.id.seeds_title); 
			TextView size   = (TextView) vi.findViewById(R.id.seeds_size); 
			TextView format = (TextView) vi.findViewById(R.id.seeds_format);
			TextView mosaic = (TextView) vi.findViewById(R.id.seeds_mosaic);
			ImageView thumb_image = (ImageView) vi.findViewById(R.id.list_image);						
			
			thumb_image.setScaleType(ImageView.ScaleType.CENTER_CROP);

			SeedsEntity seedList = data.get(position);
			
			if(mSeedsEntityChosen.contains(seedList))
			{
				vi.setBackgroundResource(R.drawable.seedsgradient_bg_hover);
			}
			else
			{
				vi.setBackgroundResource(R.drawable.seedslist_selector);
				vi.setPadding(8, 8, 8, 8);
			}

			// Set the values for the list view
			title.setText(seedList.getSeedName());
			size.setText(seedList.getSeedSize()+" / "
				        +seedList.getPicLinks().size()
				        +getString(R.string.seeds_listperday_seedspics));
			format.setText(seedList.getSeedFormat());
			mosaic.setText((seedList.getSeedMosaic())
					       ? getString(R.string.seeds_listperday_withmosaic)
					       : getString(R.string.seeds_listperday_withoutmosaic));
			if(seedList.getSeedIsPicAvail())
				tFirstImgUrl = seedList.getPicLinks().get(0);
			else
				tFirstImgUrl = SeedsGlobalNOTECode.SEEDS_NOTE_NO_IMAGE;
			mImageFetcher.loadImage(tFirstImgUrl, thumb_image);
			mImageViewList.add(thumb_image);			
				
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
