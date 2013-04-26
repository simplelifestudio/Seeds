package com.simplelife.Seeds;

import java.util.ArrayList;

import com.simplelife.Seeds.Utils.DBProcess.SeedsDBManager;
import com.simplelife.Seeds.Utils.ImageProcess.SeedsSlideImageLayout;

import android.app.Activity;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.os.Parcelable;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.ViewGroup.LayoutParams;
import android.widget.ImageView;

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
	
	
	// The info about the Seed
	private int tSeedId = 0;
	
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
				
		setTheme(android.R.style.Theme_Translucent_NoTitleBar);
		
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
		
		tImgCircleViews = new ImageView[length];
		tImgCircleView  = (ViewGroup) tImgViewGroup.findViewById(R.id.layout_circle_images);		
		tSlideLayout    = new SeedsSlideImageLayout(SeedsDetailsActivity.this);
		tSlideLayout.setCircleImageLayout(length);

		for(int i = 0;i < length;i++){
			
			tImgResult.getString(tImgResult.getColumnIndex("pictureLink"));
			
			//tImagePageViews.add(tSlideLayout.getSlideImageLayout(parser.getSlideImages()[i]));
			tImgCircleViews[i] = tSlideLayout.getCircleImageLayout(i);
			tImgCircleView.addView(tSlideLayout.getLinearLayout(tImgCircleViews[i], 10, 10));
		}
				
		setContentView(R.layout.activity_seeds_details);
		
		
		// ÉèÖÃViewPager
		//tViewPager.setAdapter(new SeedsSlideImageAdapter());  
		//tViewPager.setOnPageChangeListener(new ImagePageChangeListener());
	}
		
		
}
