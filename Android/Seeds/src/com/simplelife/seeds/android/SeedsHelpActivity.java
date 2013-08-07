/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsHelpActivity.java
 *  Seeds 
 */
package com.simplelife.seeds.android;

import java.util.ArrayList;
import android.app.Activity;
import android.os.Bundle;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.PagerTitleStrip;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.ImageView;

public class SeedsHelpActivity extends Activity {

	private ViewPager mViewPager;
	
	private ImageView mPage0;
	private ImageView mPage1;
	private ImageView mPage2;
	private ImageView mPage3;
	private ImageView mPage4;
	private ImageView mPage5;
	private ImageView mPage6;	
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	requestWindowFeature(Window.FEATURE_NO_TITLE);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_seeds_help_main);        
        mViewPager = (ViewPager)findViewById(R.id.whatsnew_viewpager);        
        
        mViewPager.setOnPageChangeListener(new MyOnPageChangeListener());        
        mPage0 = (ImageView)findViewById(R.id.page0);
        mPage1 = (ImageView)findViewById(R.id.page1);
        mPage2 = (ImageView)findViewById(R.id.page2);
        mPage3 = (ImageView)findViewById(R.id.page3);
        mPage4 = (ImageView)findViewById(R.id.page4);
        mPage5 = (ImageView)findViewById(R.id.page5);
        mPage6 = (ImageView)findViewById(R.id.page6);
               
        LayoutInflater mLi = LayoutInflater.from(this);
        /*
        View view1 = mLi.inflate(R.layout.whats_news_gallery_one, null);
        View view2 = mLi.inflate(R.layout.whats_news_gallery_two, null);
        View view3 = mLi.inflate(R.layout.whats_news_gallery_three, null);
        View view4 = mLi.inflate(R.layout.whats_news_gallery_four, null);
        View view5 = mLi.inflate(R.layout.whats_news_gallery_five, null);
        View view6 = mLi.inflate(R.layout.whats_news_gallery_six, null);
        View view7 = mLi.inflate(R.layout.whats_news_gallery_seven, null);

        final ArrayList<View> views = new ArrayList<View>();
        views.add(view1);
        views.add(view2);
        views.add(view3);
        views.add(view4);
        views.add(view5);
        views.add(view6);   
        views.add(view7); */
                
        final ArrayList<String> titles = new ArrayList<String>();
        titles.add("tab1");
        titles.add("tab2");
        titles.add("tab3");
        titles.add("tab4");
        titles.add("tab5");
        titles.add("tab6");
        titles.add("tab7");
        
        //MyPagerAdapter mPagerAdapter = new MyPagerAdapter(views,titles);
		//mViewPager.setAdapter(mPagerAdapter);
    }        

    public class MyOnPageChangeListener implements OnPageChangeListener {
    	    	
		public void onPageSelected(int page) {
			
			switch (page) {
			case 0:				
				mPage0.setImageDrawable(getResources().getDrawable(R.drawable.page_now));
				mPage1.setImageDrawable(getResources().getDrawable(R.drawable.page));
				break;
			case 1:
				mPage1.setImageDrawable(getResources().getDrawable(R.drawable.page_now));
				mPage0.setImageDrawable(getResources().getDrawable(R.drawable.page));
				mPage2.setImageDrawable(getResources().getDrawable(R.drawable.page));
				break;
			case 2:
				mPage2.setImageDrawable(getResources().getDrawable(R.drawable.page_now));
				mPage1.setImageDrawable(getResources().getDrawable(R.drawable.page));
				mPage3.setImageDrawable(getResources().getDrawable(R.drawable.page));
				break;
			case 3:
				mPage3.setImageDrawable(getResources().getDrawable(R.drawable.page_now));
				mPage4.setImageDrawable(getResources().getDrawable(R.drawable.page));
				mPage2.setImageDrawable(getResources().getDrawable(R.drawable.page));
				break;
			case 4:
				mPage4.setImageDrawable(getResources().getDrawable(R.drawable.page_now));
				mPage3.setImageDrawable(getResources().getDrawable(R.drawable.page));
				mPage5.setImageDrawable(getResources().getDrawable(R.drawable.page));
				break;
			case 5:
				mPage5.setImageDrawable(getResources().getDrawable(R.drawable.page_now));
				mPage4.setImageDrawable(getResources().getDrawable(R.drawable.page));
				mPage6.setImageDrawable(getResources().getDrawable(R.drawable.page));
				break;
			case 6:
				mPage6.setImageDrawable(getResources().getDrawable(R.drawable.page_now));
				mPage5.setImageDrawable(getResources().getDrawable(R.drawable.page));
				break;
			}
		}
		
		public void onPageScrolled(int arg0, float arg1, int arg2) {
		}

		
		public void onPageScrollStateChanged(int arg0) {
		}
	}
    
    public class MyPagerAdapter extends PagerAdapter{
    	
    	private ArrayList<View> views;
    	private ArrayList<String> titles;    	
    	
    	public MyPagerAdapter(ArrayList<View> views,ArrayList<String> titles){    		
    		this.views = views;
    		this.titles = titles;
    	}
    	
    	@Override
    	public int getCount() {
    		return this.views.size();
    	}

    	@Override
    	public boolean isViewFromObject(View arg0, Object arg1) {
    		return arg0 == arg1;
    	}
    	
    	public void destroyItem(View container, int position, Object object) {
    		((ViewPager)container).removeView(views.get(position));
    	}
    	
    	public Object instantiateItem(View container, int position) {
    		((ViewPager)container).addView(views.get(position));
    		return views.get(position);
    	}
    }
    
}
