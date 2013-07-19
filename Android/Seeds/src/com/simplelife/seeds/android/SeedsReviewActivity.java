/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsReviewActivity.java
 *  Seeds
 *
 *  Created by Chris Li on 13-5-20. 
 */

package com.simplelife.seeds.android;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.Point;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.DisplayMetrics;
import android.util.FloatMath;
import android.util.Log;
import android.view.MotionEvent;
import android.view.Window;
import android.view.animation.TranslateAnimation;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.simplelife.seeds.android.utils.imageprocess.SeedsImageLoader;
import com.simplelife.seeds.android.utils.imageprocess.SeedsImageLoadingDialog;

@SuppressLint("HandlerLeak")
public class SeedsReviewActivity extends Activity {

	private SeedsImageLoadingDialog tDialog;
	// Clarify the class which is used to load the image via url
	protected SeedsImageLoader imageLoader; 
	
	private ImageView tImageView;
	
    private LinearLayout tLayOutViewArea;
    private LinearLayout.LayoutParams tParam;
    private SeedsViewArea tViewArea; 
	

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		// Hide the titles
		requestWindowFeature(Window.FEATURE_NO_TITLE); 
        //getWindow().setFlags(WindowManager.LayoutParams. FLAG_FULLSCREEN, 
        //                     WindowManager.LayoutParams. FLAG_FULLSCREEN); 
		setContentView(R.layout.activity_seeds_details_fullscreen);
		
		// Retrieve the date info parameter
		Bundle bundle = getIntent().getExtras();
		final String tImgUrl = bundle.getString("imgLink");
		
        // Locate the linear layout id
		tLayOutViewArea = (LinearLayout) findViewById(R.id.Seeds_LinearLayout_ViewArea);
		tParam = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 
		                                       LinearLayout.LayoutParams.MATCH_PARENT);
        tViewArea = new SeedsViewArea(SeedsReviewActivity.this,tImgUrl); 
        tLayOutViewArea.addView(tViewArea,tParam); 
		
		tDialog = new SeedsImageLoadingDialog(this);
		// The dialog should be closed when the image loading finished
		tDialog.setCanceledOnTouchOutside(false);
		tDialog.show();
		
		// Set up a thread to re-download the high density image
		new Thread() {
			
			@Override
			public void run() {
				try {
					tLayOutViewArea.addView(tViewArea,tParam); 										
					
				} catch (Exception e) {
					// Show the error message here
					Log.i("SeedsReview","Waring:Fail to display the HD image!");
				}
				Message t_MsgListData = new Message();
				t_MsgListData.what = 0;
				handler.sendMessage(t_MsgListData);					
			}
		}.start();	
				
	}
	
    // Define a handler to process the progress update
	private Handler handler = new Handler(){  
  
        @Override  
        public void handleMessage(Message msg) {  
              
            switch (msg.what) {
            	
            	case 0:
                    //close the ProgressDialog
                	tDialog.dismiss(); 
                    break;
            }
             
        }
    };  
    
    public class SeedsViewArea extends FrameLayout{ 
        
    	private int imgDisplayW;   
        private int imgDisplayH;   
        private int imgW;       
        private int imgH;       
        private SeedsTouchView touchView;
        private DisplayMetrics dm;
        private Point imgPoint;
        
        @SuppressWarnings("deprecation")
		public SeedsViewArea(Context context,String imgUrl) { 
        	
        	super(context);
        	/*dm = new DisplayMetrics();
        	  ((Activity)context).getWindowManager().getDefaultDisplay().getMetrics(dm);
        	  imgDisplayW = dm.widthPixels;
        	  imgDisplayH = dm.heightPixels;*/
        	// Fetch the window size
        	/*imgPoint = new Point();
        	((Activity)context).getWindowManager().getDefaultDisplay().getSize(imgPoint);
        	imgDisplayW = imgPoint.x;
        	imgDisplayH = imgPoint.y;*/
            imgDisplayW = ((Activity)context).getWindowManager().getDefaultDisplay().getWidth();
            imgDisplayH = ((Activity)context).getWindowManager().getDefaultDisplay().getHeight(); 
        	       
        	touchView = new SeedsTouchView(context,imgDisplayW,imgDisplayH);
        	//touchView.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
        	
    		// Locate the image view
    		imageLoader = new SeedsImageLoader(context);
    		imageLoader.DisplayImage(imgUrl,touchView,1);
    		
        	// touchView.setImageResource(resId);
        	// Bitmap img = BitmapFactory.decodeResource(context.getResources(), resId);
        	// Fetch the size of the image
    		imgW = imageLoader.getCurrentImgWidth();
        	imgH = imageLoader.getCurrentImgHeight();
        	        
        	int layout_w = imgW > imgDisplayW ? imgDisplayW : imgW; 
        	int layout_h = imgH > imgDisplayH ? imgDisplayH : imgH;
        	       
        	// OK, let us do a zoom again
        	if(imgW >= imgH) {
        		if(layout_w == imgDisplayW){
        	        layout_h = (int) (imgH*((float)imgDisplayW/imgW));
        	    }
        	}else {
        		if(layout_h == imgDisplayH){
        			layout_w = (int) (imgW*((float)imgDisplayH/imgH));
        	    }
        	}
        	
        	touchView.setLayoutParams(new FrameLayout.LayoutParams(layout_w,layout_h));
        	this.addView(touchView);
        }     	
    }
    
    public class SeedsTouchView extends ImageView {
    	
    	static final int NONE = 0; // No Status
    	static final int DRAG = 1; // Moving
    	static final int ZOOM = 2; // Zooming
    	static final int BIGGER = 3; // Zoom in
    	static final int SMALLER = 4; // Zoom out
    	private int mode = NONE; 

    	// The distance when the first touch
    	private float beforeLenght;
    	// The distance after moving
    	private float afterLenght;
    	// Scale parameter
    	private float scale = 0.04f; 
    	  
    	// The the location of ViewArea
    	private int screenW;
    	private int screenH;
    	   
    	// Position of touch start
    	private int start_x;
    	private int start_y;
    	// Position of touch finished
    	private int stop_x ;
    	private int stop_y ;
    	// Bounce back animation
    	private TranslateAnimation trans; 
    	   
    	public SeedsTouchView(Context context,int w,int h){
    		
    		super(context);
    	    this.setPadding(0, 0, 0, 0);
    	    screenW = w;
    	    screenH = h;
    	}
    	
    	// Calculating the distance of two points
    	private float spacing(MotionEvent event) {
    	    float x = event.getX(0) - event.getX(1);
    	    float y = event.getY(0) - event.getY(1);
    	    return FloatMath.sqrt(x * x + y * y);
    	}
    	
    	@Override
    	public boolean onTouchEvent(MotionEvent event)
    	{   
    	    switch (event.getAction() & MotionEvent.ACTION_MASK) {
    	        
    	        case MotionEvent.ACTION_DOWN:
    	            mode = DRAG;
    	            stop_x = (int) event.getRawX();
    	            stop_y = (int) event.getRawY();
    	            start_x = stop_x - this.getLeft();
    	            start_y = stop_y - this.getTop();
    	               
    	            if(event.getPointerCount() == 2)
    	                beforeLenght = spacing(event);
    	            break;
    	        
    	        case MotionEvent.ACTION_POINTER_DOWN:
    	            if (spacing(event) > 10f) {
    	                mode = ZOOM;
    	                beforeLenght = spacing(event);
    	            }
    	            break;
    	        
    	        case MotionEvent.ACTION_UP:
    	            int disX = 0;
    	            int disY = 0;
    	            if(getHeight() <= screenH )
    	            {
    	                if(this.getTop() < 0 )
    	                {
    	                    disY = getTop();
    	                    // Indicate the position of view
    	                    this.layout(this.getLeft(), 0, this.getRight(), 0 + this.getHeight());
   	                    }
   	                    else if(this.getBottom() >= screenH)
   	                    {
   	                        disY = getHeight()- screenH+getTop();
   	                        this.layout(this.getLeft(), screenH-getHeight(), this.getRight(), screenH);
   	                    }
   	                }else{
   	                    int Y1 = getTop();
   	                    int Y2 = getHeight()- screenH+getTop();
 	                    if(Y1 > 0)
    	                {
    	                    disY= Y1;
    	                    this.layout(this.getLeft(), 0, this.getRight(), 0 + this.getHeight());
    	                }else if(Y2 < 0){
    	                    disY = Y2;
    	                    this.layout(this.getLeft(), screenH-getHeight(), this.getRight(), screenH);
    	                }
    	            }
    	            
    	            if(getWidth() <= screenW)
    	            {
    	                if(this.getLeft() < 0)
    	                {
    	                    disX = getLeft();
    	                    this.layout(0, this.getTop(), 0+getWidth(), this.getBottom());
    	                }
    	                else if(this.getRight() > screenW)
    	                {
    	                    disX = getWidth() - screenW + getLeft();
    	                    this.layout(screenW-getWidth(), this.getTop(), screenW, this.getBottom());
    	                }
    	            }else {
    	                int X1 = getLeft();
    	                int X2 = getWidth()-screenW+getLeft();
    	                if(X1 > 0) {
    	                    disX = X1;
    	                    this.layout(0, this.getTop(), 0+getWidth(), this.getBottom());
    	                }else if(X2<0) {
    	                    disX = X2;
    	                    this.layout(screenW-getWidth(), this.getTop(), screenW, this.getBottom());
    	                }
    	                
    	            }
    	                
    	            while(getHeight()<100||getWidth()<100) {
    	                setScale(scale,BIGGER);
    	            }
    	
    	            // Bounce animation, using 200ms
    	            if(disX!=0 || disY!=0)
    	            {
    	                trans = new TranslateAnimation(disX, 0, disY, 0);
    	                trans.setDuration(200);
    	                this.startAnimation(trans);
    	            }
    	            mode = NONE;
    	            break;
    	        
    	        case MotionEvent.ACTION_POINTER_UP:
    	            mode = NONE;
    	            break;
    	        
    	        case MotionEvent.ACTION_MOVE:
    	            if (mode == DRAG) {    	
    	            	// Change the position of imageView to fulfill the drag animation
    	                this.setPosition(stop_x - start_x, stop_y - start_y, stop_x + this.getWidth() - start_x, stop_y - start_y + this.getHeight());              
    	                stop_x = (int) event.getRawX();
    	                stop_y = (int) event.getRawY();
    	                       
    	            } else if (mode == ZOOM) {
    	                if(spacing(event)>10f)
    	                {
    	                    afterLenght = spacing(event);
    	                    float gapLenght = afterLenght - beforeLenght;                    
    	                    if(gapLenght == 0) { 
    	                        break;
    	                    }
    	                    // Can zoom only when the width is larger than 70
    	                    else if(Math.abs(gapLenght)>5f&&getWidth()>70)
    	                    {
    	                        if(gapLenght>0) {
    	                            this.setScale(scale,BIGGER);  
    	                        }else { 
    	                            this.setScale(scale,SMALLER);  
    	                        }                            
    	                        beforeLenght = afterLenght; 
    	                    }
    	                }
    	            }
    	            break;
    	        }
    	        return true;   
    	    }
    	   
    	    private void setScale(float temp,int flag) {  
    	       
    	        if(flag==BIGGER) {    	
    	        	// Use setFrame(left , top, right,bottom) to change the view size
    	            this.setFrame(this.getLeft()-(int)(temp*this.getWidth()),   
    	                          this.getTop()-(int)(temp*this.getHeight()),   
    	                          this.getRight()+(int)(temp*this.getWidth()),   
    	                          this.getBottom()+(int)(temp*this.getHeight()));     
    	        }else if(flag==SMALLER){  
    	            this.setFrame(this.getLeft()+(int)(temp*this.getWidth()),   
    	                          this.getTop()+(int)(temp*this.getHeight()),   
    	                          this.getRight()-(int)(temp*this.getWidth()),   
    	                          this.getBottom()-(int)(temp*this.getHeight()));  
    	        }  
    	    }
    	   
    	    private void setPosition(int left,int top,int right,int bottom) { 
    	        this.layout(left,top,right,bottom);              
    	    }     	   	
    }

}

