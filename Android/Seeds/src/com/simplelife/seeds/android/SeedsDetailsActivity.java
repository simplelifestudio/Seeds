/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsDetailsActivity.java
 *  Seeds
 *
 *  Created by Chris Li on 13-5-20. 
 */

package com.simplelife.seeds.android;

import java.util.ArrayList;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.Parcelable;
import android.support.v4.app.NavUtils;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;
import com.simplelife.seeds.android.utils.downloadprocess.DownloadManager;
import com.simplelife.seeds.android.utils.downloadprocess.ui.DownloadList;
import com.simplelife.seeds.android.utils.gridview.gridviewui.ImageGridActivity;
import com.simplelife.seeds.android.utils.imageprocess.SeedsImageLoader;
import com.simplelife.seeds.android.utils.imageprocess.SeedsSlideImageLayout;

public class SeedsDetailsActivity extends Activity{
	
	// The array to show the images
	private ArrayList<View> tImagePageViews = null;
	private ViewGroup tImgViewGroup = null;
	private ViewPager tViewPager = null;
	
	// The dot which perform as the indicators
	private ViewGroup tImgCircleView = null;
	private ImageView[] tImgCircleViews = null;
	
	// For the layout setting
	private SeedsSlideImageLayout tSlideLayout = null;
	
	private int tPageIndex = 0; 
	
	// The info about the Seed
	private int mSeedLocalId;
	
	// For log purpose
	private static final String LOGCLASS = "SeedsDetails"; 
	
	// Clarify the ImageLoader
	public SeedsImageLoader tImageLoader;
	
	// Button to save to favorites
	private Button myFavoriteBtn;
	
	// Image view to change to gridview
	private ImageView mGotoGridView;
	
	// Image view to download the seeds
	private ImageView mDownloadView;
	
	// Database adapter
	private SeedsDBAdapter mDBAdapter;
	
	// Progress dialog for setting as favorite operation
	private ProgressDialog tProgressDialog = null;
	
	// SeedsEntity for internal use
	private SeedsEntity mSeedsEntity;
	
	// Favorite tag
	private boolean tFavTag = false;
	
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
				
		// Log the entry
		Log.i(LOGCLASS, "Working on starting the SeedsDetailsActivity!");
		//setTheme(android.R.style.Theme_Translucent_NoTitleBar);
				
		// Load the seeds info
		mSeedsEntity = (SeedsEntity) getIntent().getSerializableExtra("seedObj");
		mSeedLocalId = mSeedsEntity.getSeedLocalId(); 
		
		// Retrieve the adapter instance
		mDBAdapter = SeedsDBAdapter.getAdapter();
		
		// Initialization
		initViews();
		
		// Retrieve the favorite button
		myFavoriteBtn = (Button) findViewById(R.id.favorite_btn);
		
		// Check if this seed has already been saved to favorite
		if(mDBAdapter.isSeedSaveToFavorite(mSeedLocalId))
		{
			myFavoriteBtn.setText(R.string.seeds_UnFavorite);
		}
		
		// Listen on the favorite button
		myFavoriteBtn.setOnClickListener(myFavoriteBtnListener);
		
		// Retrieve the gotoGrid option
		mGotoGridView = (ImageView) findViewById(R.id.gotoGrid);
		mGotoGridView.setOnClickListener(myGotoGridViewListener);
		
		// Retrieve the download seeds option
		mDownloadView = (ImageView) findViewById(R.id.seeds_download);
		mDownloadView.setOnClickListener(myDownloadViewListener);		
	}	
	
	private void initViews(){
		// The area of the images
		tImagePageViews = new ArrayList<View>();
		LayoutInflater inflater = getLayoutInflater();  
		tImgViewGroup = (ViewGroup)inflater.inflate(R.layout.activity_seeds_details, null);
		tViewPager = (ViewPager) tImgViewGroup.findViewById(R.id.image_slide_page);  
		String seedName = null;
		String seedSize = null;
		String seedFormat = null;
		String seedLink = null;
		
		// Create a image loader
		tImageLoader = new SeedsImageLoader(this.getApplicationContext());
				
		// Get the count the result
		int length = mSeedsEntity.getPicLinks().size();
		
		tImgCircleViews = new ImageView[length];
		tImgCircleView  = (ViewGroup) tImgViewGroup.findViewById(R.id.layout_circle_images);		
		tSlideLayout    = new SeedsSlideImageLayout(SeedsDetailsActivity.this);
		tSlideLayout.setCircleImageLayout(length);

		for(int index=0; index<length; index++)
		{
			/*tImageLoader.DisplayImage(seedList.get(SeedsListPerDayActivity.KEY_THUMB_URL),
			thumb_image);*/
	
	        //Log.i(LOGCLASS,"Working on filling the images inside,the url is  "+tImgResult.getString(tImgResult.getColumnIndex("pictureLink")));
	        tImagePageViews.add(tSlideLayout.getSlideImageLayout(mSeedsEntity.getPicLinks().get(index)));
	        
			//tImagePageViews.add(tSlideLayout.getSlideImageLayout(slideImages[i]));
			tImgCircleViews[index] = tSlideLayout.getCircleImageLayout(index);
	        tImgCircleView.addView(tSlideLayout.getLinearLayout(tImgCircleViews[index], 10, 10));
		}
		
		// Prepare the seeds text info
		seedName   = mSeedsEntity.getSeedName(); 
		seedSize   = mSeedsEntity.getSeedSize(); 
		seedFormat = mSeedsEntity.getSeedFormat(); 
		seedLink   = mSeedsEntity.getSeedTorrentLink(); 
		
		setContentView(tImgViewGroup);		
		
		// Show the details info of the seed
		TextView tTextViewName   = (TextView)findViewById(R.id.seed_info_name);
		TextView tTextViewFormat = (TextView)findViewById(R.id.seed_info_format);
		TextView tTextViewSize   = (TextView)findViewById(R.id.seed_info_size);
		TextView tTextViewLink   = (TextView)findViewById(R.id.seed_info_link);
		if(null != seedName)
			  tTextViewName.setText("Name:   "+seedName);
		if(null != seedFormat)
			tTextViewFormat.setText("Format: "+seedFormat);
		if(null != seedSize)
			  tTextViewSize.setText("Size:      "+seedSize);
		if(null != seedLink)
			  tTextViewLink.setText("Torrent: "+seedLink);
		
		// Setup ViewPager
		tViewPager.setAdapter(new SeedsSlideImageAdapter());  
		tViewPager.setOnPageChangeListener(new ImagePageChangeListener());
	}

    private class SeedsSlideImageAdapter extends PagerAdapter {  
        @Override  
        public int getCount() { 
            return tImagePageViews.size();  
        }  
  
        @Override  
        public boolean isViewFromObject(View arg0, Object arg1) {  
            return arg0 == arg1;  
        }  
  
        @Override  
        public int getItemPosition(Object object) {  
            // TODO Auto-generated method stub  
            return super.getItemPosition(object);  
        }  
  
        @Override  
        public void destroyItem(View arg0, int arg1, Object arg2) {  
            // TODO Auto-generated method stub  
            ((ViewPager) arg0).removeView(tImagePageViews.get(arg1));  
        }  
  
        @Override  
        public Object instantiateItem(View arg0, int arg1) {  
            // TODO Auto-generated method stub  
        	((ViewPager) arg0).addView(tImagePageViews.get(arg1));
            
            return tImagePageViews.get(arg1);  
        }  
  
        @Override  
        public void restoreState(Parcelable arg0, ClassLoader arg1) {  
            // TODO Auto-generated method stub  
  
        }  
  
        @Override  
        public Parcelable saveState() {  
            // TODO Auto-generated method stub  
            return null;  
        }  
  
        @Override  
        public void startUpdate(View arg0) {  
            // TODO Auto-generated method stub  
  
        }  
  
        @Override  
        public void finishUpdate(View arg0) {  
            // TODO Auto-generated method stub  
  
        }  
    }
    
    private class ImagePageChangeListener implements OnPageChangeListener {
        @Override  
        public void onPageScrollStateChanged(int arg0) {  
            // TODO Auto-generated method stub  
  
        }  
  
        @Override  
        public void onPageScrolled(int arg0, float arg1, int arg2) {  
            // TODO Auto-generated method stub  
  
        }  
  
        @Override  
        public void onPageSelected(int index) {  
        	tPageIndex = index;
        	tSlideLayout.setPageIndex(index);
        	//tvSlideTitle.setText(parser.getSlideTitles()[index]);
        	
            for (int i = 0; i < tImgCircleViews.length; i++) {  
            	tImgCircleViews[index].setBackgroundResource(R.drawable.dot_selected);
                
                if (index != i) {  
                	tImgCircleViews[i].setBackgroundResource(R.drawable.dot_none);  
                }  
            }
        }  
    }
    
	private View.OnClickListener myFavoriteBtnListener = new View.OnClickListener() {

		@Override
		public void onClick(View v) {
			
			if(mDBAdapter.isSeedSaveToFavorite(mSeedLocalId))
			{
				tFavTag = true;
				tProgressDialog = ProgressDialog.show(SeedsDetailsActivity.this, "Adding to Favorites...", "Please wait...", true, false);
			}
			else
			{
				tFavTag = false;
				tProgressDialog = ProgressDialog.show(SeedsDetailsActivity.this, "Cancelling Favorites...", "Please wait...", true, false);
			}
			
			// Set up a thread to operate with the database
			new Thread() {				
				@Override
				public void run() {
					try {
						// Get the DB adapter instance
						SeedsDBAdapter mDBAdapter = SeedsDBAdapter.getAdapter();
						
						// Set the favorite key 
						if (tFavTag)
						{
							mDBAdapter.updateSeedEntryFav(mSeedLocalId,false);
							tFavTag = false;
							tProgressDialog = ProgressDialog.show(SeedsDetailsActivity.this, "Cancelling Favorites...", "Done!", true, false);
						    //TODO
							// Remove the entry if this seed is out of date
						}
						else
						{
							mDBAdapter.updateSeedEntryFav(mSeedLocalId,true);
							tFavTag = true;
							tProgressDialog = ProgressDialog.show(SeedsDetailsActivity.this, "Adding to Favorites...", "Done!", true, false);							
						}
	            		
	            		// Hang on for a moment
	            		Thread.sleep(2000);
						
					} catch (Exception e) {
						// Show the error message here
					}

					Message t_MsgListData = new Message();
					t_MsgListData.what = 1;
					handler.sendMessage(t_MsgListData);					
				}
			}.start();
		}
	};
	
	private View.OnClickListener myGotoGridViewListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
		    // Redirect to the new page
		    Intent intent = new Intent(SeedsDetailsActivity.this, ImageGridActivity.class);
		    intent.putExtra("seedObj", mSeedsEntity);
		    startActivity(intent);
		}
	};
	
	private View.OnClickListener myDownloadViewListener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
        	// Fetch the download manager to start the download
        	DownloadManager tDownloadMgr = DownloadManager.getDownloadMgr();
        	tDownloadMgr.startDownload(mSeedsEntity.getSeedTorrentLink());            	
        	
    		Toast toast = Toast.makeText(getApplicationContext(),
    				R.string.seeds_download_added, Toast.LENGTH_SHORT);
    	    toast.setGravity(Gravity.CENTER, 0, 0);
    	    toast.show();
            
        	Intent intent = new Intent();
        	intent.setClass(SeedsDetailsActivity.this, DownloadList.class);
        	startActivity(intent);

		}
	};
	
    // Define a handler to process the progress update
	private Handler handler = new Handler(){  
  
        @Override  
        public void handleMessage(Message msg) {  
              
            switch (msg.what) {
            	
            	case 1:
            		// Check if this seed has already been saved to favorite
            		if(mDBAdapter.isSeedSaveToFavorite(mSeedLocalId))
            		{
            			myFavoriteBtn.setText(R.string.seeds_UnFavorite);
            			
                		Toast toast = Toast.makeText(getApplicationContext(),
                				R.string.seeds_fav_done, Toast.LENGTH_SHORT);
                	    toast.setGravity(Gravity.CENTER, 0, 0);
                	    toast.show();
            		}
            		else
            		{
            			myFavoriteBtn.setText(R.string.seeds_Favorite);
            			
                		Toast toast = Toast.makeText(getApplicationContext(),
                				R.string.seeds_unfav_done, Toast.LENGTH_SHORT);
                	    toast.setGravity(Gravity.CENTER, 0, 0);
                	    toast.show();
            		}
            		//close the ProgressDialog
                    tProgressDialog.dismiss(); 

                    break;
                // Or try something here
            }
             
        }
    }; 
    
    
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.seeds_download_management, menu);
		return true;
	}
	
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
            {
                NavUtils.navigateUpFromSameTask(this);
                return true;
            }
            case R.id.download_seed:
            {
            	// Fetch the download manager to start the download
            	DownloadManager tDownloadMgr = DownloadManager.getDownloadMgr();
            	tDownloadMgr.startDownload(mSeedsEntity.getSeedTorrentLink());            	
            	
        		Toast toast = Toast.makeText(getApplicationContext(),
        				R.string.seeds_download_added, Toast.LENGTH_SHORT);
        	    toast.setGravity(Gravity.CENTER, 0, 0);
        	    toast.show();
                return true;
            }
            case R.id.download_mgt:
            {
            	Intent intent = new Intent();
            	intent.setClass(this, DownloadList.class);
            	startActivity(intent);
            	return true;
            }
        }
        return super.onOptionsItemSelected(item);
    }

		
}
