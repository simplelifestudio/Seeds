/*
 * Copyright (C) 2012 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.simplelife.seeds.android.utils.gridview.gridviewui;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.ActionBar;
import android.app.ActivityOptions;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.ViewTreeObserver;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;
import com.simplelife.seeds.android.utils.downloadprocess.DownloadManager;
import com.simplelife.seeds.android.utils.downloadprocess.ui.DownloadList;
import com.simplelife.seeds.android.utils.gridview.gridviewprovider.Images;
import com.simplelife.seeds.android.utils.gridview.gridviewui.ImageDetailActivity;
import com.simplelife.seeds.android.BuildConfig;
import com.simplelife.seeds.android.R;
import com.simplelife.seeds.android.SeedsDateManager;
import com.simplelife.seeds.android.SeedsDefinitions;
import com.simplelife.seeds.android.SeedsPullToRefreshView;
import com.simplelife.seeds.android.SeedsPullToRefreshView.OnHeaderRefreshListener;
import com.simplelife.seeds.android.SeedsRSSCartActivity;
import com.simplelife.seeds.android.SeedsRSSCartActivity.SeedsRSSList;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.ImageCache.ImageCacheParams;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.ImageFetcher;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.Utils;

/**
 * The main fragment that powers the ImageGridActivity screen. Fairly straight forward GridView
 * implementation with the key addition being the ImageWorker class w/ImageCache to load children
 * asynchronously, keeping the UI nice and smooth and caching thumbnails for quick retrieval. The
 * cache is retained over configuration changes like orientation change so the images are populated
 * quickly if, for example, the user rotates the device.
 */
public class ImageGridFragment extends Fragment implements AdapterView.OnItemClickListener, OnHeaderRefreshListener {
    private static final String TAG = "ImageGridFragment";
    //private static final String IMAGE_CACHE_DIR = "thumbs";

    private int mImageThumbSize;
    private int mImageThumbSpacing;
    private ImageAdapter mAdapter;
    private ImageFetcher mImageFetcher;
    private SeedsPullToRefreshView mPullToRefreshView;
    
	// The menuItem favorite
	private MenuItem mFavItem = null;
	
	// Favorite tag
	private boolean mFavTag = false;
	
	// Seed local id
	private int mSeedLocalId = Images.getSeedLocalId();
	
	// Database adapter
	private SeedsDBAdapter mDBAdapter;

    /**
     * Empty constructor as per the Fragment documentation
     */
    public ImageGridFragment() {}

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);

        mImageThumbSize = getResources().getDimensionPixelSize(R.dimen.image_thumbnail_size);
        mImageThumbSpacing = getResources().getDimensionPixelSize(R.dimen.image_thumbnail_spacing);

        mAdapter = new ImageAdapter(getActivity());        
		
		// Retrieve the adapter instance
		mDBAdapter = SeedsDBAdapter.getAdapter(getActivity());

        ImageCacheParams cacheParams = new ImageCacheParams(getActivity(), SeedsDefinitions.SEEDS_THUMBS_CACHE_DIR);

        cacheParams.setMemCacheSizePercent(0.25f); // Set memory cache to 25% of app memory

        // The ImageFetcher takes care of loading images into our ImageView children asynchronously
        mImageFetcher = new ImageFetcher(getActivity(), mImageThumbSize);
        mImageFetcher.setLoadingImage(R.drawable.empty_photo);
        mImageFetcher.addImageCache(getActivity().getSupportFragmentManager(), cacheParams,"GRIDTAG");
    }

    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        final View v = inflater.inflate(R.layout.activity_seeds_gridview_gridfragment, container, false);
        final GridView mGridView = (GridView) v.findViewById(R.id.gridView);
        mPullToRefreshView = (SeedsPullToRefreshView)v.findViewById(R.id.main_pull_refresh_view_grid);
        mGridView.setAdapter(mAdapter);
        mGridView.setOnItemClickListener(this);
        mPullToRefreshView.setOnHeaderRefreshListener(this);
        mGridView.setOnScrollListener(new AbsListView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(AbsListView absListView, int scrollState) {
                // Pause fetcher to ensure smoother scrolling when flinging
                if (scrollState == AbsListView.OnScrollListener.SCROLL_STATE_FLING) {
                    mImageFetcher.setPauseWork(true);
                } else {
                    mImageFetcher.setPauseWork(false);
                }
            }

            @Override
            public void onScroll(AbsListView absListView, int firstVisibleItem,
                    int visibleItemCount, int totalItemCount) {
            }
        });

        // This listener is used to get the final width of the GridView and then calculate the
        // number of columns and the width of each column. The width of each column is variable
        // as the GridView has stretchMode=columnWidth. The column width is used to set the height
        // of each view so we get nice square thumbnails.
        mGridView.getViewTreeObserver().addOnGlobalLayoutListener(
                new ViewTreeObserver.OnGlobalLayoutListener() {
                    @Override
                    public void onGlobalLayout() {
                        if (mAdapter.getNumColumns() == 0) {
                            final int numColumns = (int) Math.floor(
                                    mGridView.getWidth() / (mImageThumbSize + mImageThumbSpacing));
                            if (numColumns > 0) {
                                final int columnWidth =
                                        (mGridView.getWidth() / numColumns) - mImageThumbSpacing;
                                mAdapter.setNumColumns(numColumns);
                                mAdapter.setItemHeight(columnWidth);
                                if (BuildConfig.DEBUG) {
                                    Log.d(TAG, "onCreateView - numColumns set to " + numColumns);
                                }
                            }
                        }
                    }
                });

		// Set a title for this page
		ActionBar tActionBar = getActivity().getActionBar();
		tActionBar.setTitle(R.string.seeds_details_top);
		
		// Show the details info of the seed
		// Prepare the seeds text info
		String tSeedName   = Images.getSeedsEntity().getSeedName(); 
		String tSeedSize   = Images.getSeedsEntity().getSeedSize(); 
		String tSeedFormat = Images.getSeedsEntity().getSeedFormat(); 
		String tSeedMosaic = (Images.getSeedsEntity().getSeedMosaic())
			               ? getString(R.string.seeds_listperday_withmosaic)
			               : getString(R.string.seeds_listperday_withoutmosaic);
		TextView tTextViewName   = (TextView)v.findViewById(R.id.seed_grid_info_name);
		TextView tTextViewFormat = (TextView)v.findViewById(R.id.seed_grid_info_format);
		TextView tTextViewSize   = (TextView)v.findViewById(R.id.seed_grid_info_size);
		TextView tTextViewMosaic = (TextView)v.findViewById(R.id.seed_grid_info_mosaic);

		if(null != tSeedName)
			  tTextViewName.setText(getString(R.string.seedTitle)+": "+tSeedName);
		if(null != tSeedFormat)
			tTextViewFormat.setText(getString(R.string.seedFormat)+": "+tSeedFormat);
		if(null != tSeedSize)
			  tTextViewSize.setText(getString(R.string.seedSize)+": "+tSeedSize);
		if(null != tSeedMosaic)
			tTextViewMosaic.setText(getString(R.string.seeds_listperday_mosaic)+": "+tSeedMosaic);
        
        return v;
    }
    
	@Override
	public void onHeaderRefresh(SeedsPullToRefreshView view) {
		mPullToRefreshView.postDelayed(new Runnable() {
			
			@Override
			public void run() {
				SeedsDateManager tDateMgr = SeedsDateManager.getDateManager();
				mPullToRefreshView.onHeaderRefreshComplete(getString(R.string.pull_to_refresh_footer_refreshing_date) 
						                                  +tDateMgr.getRealTimeNow2());
				//mPullToRefreshView.onHeaderRefreshComplete();
			}
		},1000);
		
	}

    @Override
    public void onResume() {
        super.onResume();
        mImageFetcher.setExitTasksEarly(false);
        mAdapter.notifyDataSetChanged();
    }

    @Override
    public void onPause() {
        super.onPause();
        mImageFetcher.setPauseWork(false);
        mImageFetcher.setExitTasksEarly(true);
        mImageFetcher.flushCache();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mImageFetcher.closeCache();
    }

    @TargetApi(16)
    @Override
    public void onItemClick(AdapterView<?> parent, View v, int position, long id) {
        final Intent i = new Intent(getActivity(), ImageDetailActivity.class);
        i.putExtra(ImageDetailActivity.EXTRA_IMAGE, (int) id);
        if (Utils.hasJellyBean()) {
            // makeThumbnailScaleUpAnimation() looks kind of ugly here as the loading spinner may
            // show plus the thumbnail image in GridView is cropped. so using
            // makeScaleUpAnimation() instead.
            ActivityOptions options =
                    ActivityOptions.makeScaleUpAnimation(v, 0, 0, v.getWidth(), v.getHeight());
            getActivity().startActivity(i, options.toBundle());
        } else {
            startActivity(i);
        }
    }
    
    private void addOrCancelFromFavList(MenuItem item){
    	
		if(mDBAdapter.isSeedSaveToFavorite(mSeedLocalId))
		{
			mFavTag = true;
		}
		else
		{
			mFavTag = false;
		}
		
		// Set up a thread to operate with the database
		new Thread() {				
			@Override
			public void run() {
				try {
					// Get the DB adapter instance
					SeedsDBAdapter mDBAdapter = SeedsDBAdapter.getAdapter(getActivity());
					
					// Set the favorite key 
					if (mFavTag)
					{
						mDBAdapter.updateSeedEntryFav(mSeedLocalId,false);
						mFavTag = false;
						ProgressDialog.show(getActivity(), "Cancelling Favorites...", "Done!", true, false);
					}
					else
					{
						mDBAdapter.updateSeedEntryFav(mSeedLocalId,true);
						mFavTag = true;
						
						ProgressDialog.show(getActivity(), "Adding to Favorites...", "Done!", true, false);							
					}            		
					
				} catch (Exception e) {
					// Show the error message here
				}

				Message t_MsgListData = new Message();
				t_MsgListData.what = 1;
				handler.sendMessage(t_MsgListData);					
			}
		}.start();
	}
    
    // Define a handler to process the progress update
	@SuppressLint("HandlerLeak")
	private Handler handler = new Handler(){  
  
        @Override  
        public void handleMessage(Message msg) {  
              
            switch (msg.what) {
            	
            	case 1:
            		// Check if this seed has already been saved to favorite
            		if(mDBAdapter.isSeedSaveToFavorite(mSeedLocalId))
            		{
            			if (null != mFavItem)
            				mFavItem.setIcon(R.drawable.rating_not_important_large);
            			
                		Toast toast = Toast.makeText(getActivity(),
                				R.string.seeds_fav_done, Toast.LENGTH_SHORT);
                	    toast.setGravity(Gravity.CENTER, 0, 0);
                	    toast.show();
            		}
            		else
            		{
            			if (null != mFavItem)
            				mFavItem.setIcon(R.drawable.rating_important_large);
            			
                		Toast toast = Toast.makeText(getActivity(),
                				R.string.seeds_unfav_done, Toast.LENGTH_SHORT);
                	    toast.setGravity(Gravity.CENTER, 0, 0);
                	    toast.show();
            		}

                    break;
                // Or try something here
            }
             
        }
    }; 

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        inflater.inflate(R.menu.activity_seeds_gridview_menu, menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
        case R.id.menu_addto_fav:
        {
        	mFavItem = item;
        	addOrCancelFromFavList(item);            	
		    return true;
        }
        case R.id.rss_addtocart:
        {
        	int tShowId;
        	if(!SeedsRSSList.addSeedToCart(mSeedLocalId))
        		tShowId = R.string.seeds_rss_toast_addtocartnonecc;
        	else
        		tShowId = R.string.seeds_rss_toast_addtocartdone;

    		Toast toast = Toast.makeText(getActivity(),
    				tShowId, Toast.LENGTH_SHORT);
    	    toast.setGravity(Gravity.CENTER, 0, 0);
    	    toast.show();
        	return true;
        }
        case R.id.rss_management:
        {
		    Intent intent = new Intent(getActivity(), SeedsRSSCartActivity.class);
		    startActivity(intent);
        	return true;
        }
        case R.id.download_seed:
        {
        	// Fetch the download manager to start the download
        	DownloadManager tDownloadMgr = DownloadManager.getDownloadMgr(getActivity().getContentResolver(),
        			                                                      getActivity().getPackageName());
        	tDownloadMgr.startDownload(Images.getSeedsEntity().getSeedTorrentLink(),
        			                   Images.getSeedsEntity().getSeedPublishDate(),
        			                   Images.getSeedsEntity().getSeedName());            	
        	
    		Toast toast = Toast.makeText(getActivity(),
    				R.string.seeds_download_added, Toast.LENGTH_SHORT);
    	    toast.setGravity(Gravity.CENTER, 0, 0);
    	    toast.show();
            return true;
        }
        case R.id.download_mgt:
        {
        	Intent intent = new Intent(getActivity(), DownloadList.class);
        	startActivity(intent);
        	return true;
        }    
        case R.id.clear_cache:
        {
            mImageFetcher.clearCache();
            Toast.makeText(getActivity(), R.string.clear_cache_complete_toast,
                  Toast.LENGTH_SHORT).show();
            return true;
        }
    }
		return true;
    }
    
    @Override 
    public void onPrepareOptionsMenu(Menu menu){ 
     
        super.onPrepareOptionsMenu(menu); 
     
        MenuItem tFavItem = menu.findItem(R.id.menu_addto_fav); 
     
	    // Check if this seed has already been saved to favorite
	    if(mDBAdapter.isSeedSaveToFavorite(mSeedLocalId))
	    {
            if(null != tFavItem)
                tFavItem.setIcon(R.drawable.rating_not_important_large);
        }     
        return;      
    } 

    /**
     * The main adapter that backs the GridView. This is fairly standard except the number of
     * columns in the GridView is used to create a fake top row of empty views as we use a
     * transparent ActionBar and don't want the real top row of images to start off covered by it.
     */
    private class ImageAdapter extends BaseAdapter {

        private final Context mContext;
        private int mItemHeight = 0;
        private int mNumColumns = 0;
        private int mActionBarHeight = 0;
        private GridView.LayoutParams mImageViewLayoutParams;

        public ImageAdapter(Context context) {
            super();
            mContext = context;
            mImageViewLayoutParams = new GridView.LayoutParams(
                    LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
            // Calculate ActionBar height
            TypedValue tv = new TypedValue();
            if (context.getTheme().resolveAttribute(
                    android.R.attr.actionBarSize, tv, true)) {
            	/*mActionBarHeight = TypedValue.complexToDimensionPixelSize(
                        tv.data, context.getResources().getDisplayMetrics());*/
            }
        }

        @Override
        public int getCount() {
            // Size + number of columns for top empty row
            //return Images.imageThumbUrls.length + mNumColumns;
        	return Images.getSeedsEntity().getPicLinks().size() + mNumColumns;
        }

        @Override
        public Object getItem(int position) {
            return position < mNumColumns ?
                    null : Images.getSeedsEntity().getPicLinks().get(position - mNumColumns);
        }

        @Override
        public long getItemId(int position) {
            return position < mNumColumns ? 0 : position - mNumColumns;
        }

        @Override
        public int getViewTypeCount() {
            // Two types of views, the normal ImageView and the top row of empty views
            return 2;
        }

        @Override
        public int getItemViewType(int position) {
            return (position < mNumColumns) ? 1 : 0;
        }

        @Override
        public boolean hasStableIds() {
            return true;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup container) {
            // First check if this is the top row
            if (position < mNumColumns) {
                if (convertView == null) {
                    convertView = new View(mContext);
                }
                // Set empty view with height of ActionBar
                convertView.setLayoutParams(new AbsListView.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT, mActionBarHeight));
                return convertView;
            }

            // Now handle the main ImageView thumbnails
            ImageView imageView;
            if (convertView == null) { // if it's not recycled, instantiate and initialize
                imageView = new RecyclingImageView(mContext);
                imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
                imageView.setLayoutParams(mImageViewLayoutParams);
            } else { // Otherwise re-use the converted view
                imageView = (ImageView) convertView;
            }

            // Check the height matches our calculated column width
            if (imageView.getLayoutParams().height != mItemHeight) {
                imageView.setLayoutParams(mImageViewLayoutParams);
            }

            // Finally load the image asynchronously into the ImageView, this also takes care of
            // setting a placeholder image while the background thread runs
            //mImageFetcher.loadImage(Images.imageThumbUrls[position - mNumColumns], imageView);
            mImageFetcher.loadImage(Images.getSeedsEntity().getPicLinks().get(position - mNumColumns), imageView);
            return imageView;
        }

        /**
         * Sets the item height. Useful for when we know the column width so the height can be set
         * to match.
         *
         * @param height
         */
        public void setItemHeight(int height) {
            if (height == mItemHeight) {
                return;
            }
            mItemHeight = height;
            mImageViewLayoutParams =
                    new GridView.LayoutParams(LayoutParams.MATCH_PARENT, mItemHeight);
            mImageFetcher.setImageSize(height);
            notifyDataSetChanged();
        }

        public void setNumColumns(int numColumns) {
            mNumColumns = numColumns;
        }

        public int getNumColumns() {
            return mNumColumns;
        }
    }
}
