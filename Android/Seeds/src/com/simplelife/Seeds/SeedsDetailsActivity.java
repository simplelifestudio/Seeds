package com.simplelife.Seeds;

import java.util.ArrayList;

import android.app.Activity;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.os.Parcelable;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.simplelife.Seeds.Utils.DBProcess.SeedsDBManager;
import com.simplelife.Seeds.Utils.ImageProcess.SeedsImageLoader;
import com.simplelife.Seeds.Utils.ImageProcess.SeedsSlideImageLayout;

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
	private int tSeedId;
	
	// For log purpose
	private static final String LOGCLASS = "SeedsDetails"; 
	
	// Clarify the ImageLoader
	public SeedsImageLoader tImageLoader;
	
	private int[] slideImages = {
			R.drawable.image01,
			R.drawable.image02,
			R.drawable.image03,
			R.drawable.image04,
			R.drawable.image05,
			R.drawable.image01,
			R.drawable.image02,
			R.drawable.image03,
			R.drawable.image04,
			R.drawable.image05,
			R.drawable.image05};
	
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
				
		// Log the entry
		Log.i(LOGCLASS, "Working on starting the SeedsDetailsActivity!");
		//setTheme(android.R.style.Theme_Translucent_NoTitleBar);
		
		// Retrieve the date info parameter
		Bundle bundle = getIntent().getExtras();
		tSeedId = bundle.getInt("seedid");
		
		// Initialization
		initViews();
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
		
		// Get the images: Retrieve the DB process handler to get data 
		SeedsDBManager mDBHandler = SeedsDBManager.getManager();
		
		// Put a warning info here in case the DBHandler is null
		SQLiteDatabase tDB = mDBHandler.getDatabase("Seeds_App_Database.db"); 
		
		// Query the database
		// NOTE: Modify here if the format of publishDate field in db is not string
		Cursor tImgResult = tDB.rawQuery(
				"select pictureLink from SeedPicture where seedId=?",
				new String[]{Integer.toString(tSeedId)});
		
		// Get the count the result
		int length = tImgResult.getCount();
		Log.i(LOGCLASS,"Image links query done, image count= "+length);
		
		tImgCircleViews = new ImageView[length];
		tImgCircleView  = (ViewGroup) tImgViewGroup.findViewById(R.id.layout_circle_images);		
		tSlideLayout    = new SeedsSlideImageLayout(SeedsDetailsActivity.this);
		tSlideLayout.setCircleImageLayout(length);

		tImgResult.moveToFirst(); 
		int i = 0;
		while (!tImgResult.isAfterLast()) 
	    {
			/*tImageLoader.DisplayImage(seedList.get(SeedsListPerDayActivity.KEY_THUMB_URL),
			thumb_image);*/
	
	        // tImgResult.getString(tImgResult.getColumnIndex("pictureLink"));
	        //Log.i(LOGCLASS,"Working on filling the images inside,the url is  "+tImgResult.getString(tImgResult.getColumnIndex("pictureLink")));
	        tImagePageViews.add(tSlideLayout.getSlideImageLayout(tImgResult.getString(tImgResult.getColumnIndex("pictureLink"))));
	        
			//tImagePageViews.add(tSlideLayout.getSlideImageLayout(slideImages[i]));
			tImgCircleViews[i] = tSlideLayout.getCircleImageLayout(i);
	        tImgCircleView.addView(tSlideLayout.getLinearLayout(tImgCircleViews[i], 10, 10));
			// Move to the next result
			tImgResult.moveToNext();
			i++;
	    }
		
		// Now show the seed info
		// Query out the seed info
		Cursor tSeedInfo = tDB.rawQuery(
				"select name,size,format,torrentLink from Seed where seedId=?",
				new String[]{Integer.toString(tSeedId)});
		tSeedInfo.moveToFirst(); 
		while (!tSeedInfo.isAfterLast()) 
	    {
			seedName   = tSeedInfo.getString(tSeedInfo.getColumnIndex("name"));
			seedSize   = tSeedInfo.getString(tSeedInfo.getColumnIndex("size"));
			seedFormat = tSeedInfo.getString(tSeedInfo.getColumnIndex("format"));
			seedLink   = tSeedInfo.getString(tSeedInfo.getColumnIndex("torrentLink"));
			
			tSeedInfo.moveToNext();			
	    }
		
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

		
}
