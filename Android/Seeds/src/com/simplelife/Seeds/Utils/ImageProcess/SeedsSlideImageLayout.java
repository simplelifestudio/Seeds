package com.simplelife.Seeds.Utils.ImageProcess;

import java.util.ArrayList;

import android.app.Activity;
import android.app.AlertDialog;
import android.graphics.Matrix;
import android.graphics.PointF;
import android.util.FloatMath;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnTouchListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout;

import com.simplelife.Seeds.R;

/**
 * Generate Image slide layout
 */
public class SeedsSlideImageLayout {
	// ArrayList for the images
	private ArrayList<ImageView> imageList = null;
	private Activity activity = null;
	// Group for the dots 
	private ImageView[] imageViews = null; 
	private ImageView imageView = null;
	
	// To indicate the current image
	private int pageIndex = 0;
	
	public SeedsImageLoader imageLoader; 
	
	public SeedsSlideImageLayout(Activity activity) {

		this.activity = activity;
		
		// Initialize the image list
		imageList = new ArrayList<ImageView>();
		
		imageLoader = new SeedsImageLoader(activity.getApplicationContext());
	}
	
	public View getSlideImageLayout(String imageUrl){
	//public View getSlideImageLayout(int index){
		LinearLayout imageLinerLayout = new LinearLayout(activity);
		LinearLayout.LayoutParams imageLinerLayoutParames = new LinearLayout.LayoutParams(
				LinearLayout.LayoutParams.WRAP_CONTENT, 
				LinearLayout.LayoutParams.WRAP_CONTENT,
				Gravity.CENTER);
		
		ImageView iv = new ImageView(activity);
		//iv.setBackgroundResource(index);		
		imageLoader.DisplayImage(imageUrl,iv,1);
		
		iv.setOnClickListener(new ImageOnClickListener(imageUrl));
		//iv.setOnTouchListener(new ImageOnTouchListener());
		imageLinerLayout.setGravity(Gravity.CENTER);
		//iv.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
		imageLinerLayout.addView(iv,imageLinerLayoutParames);		
		imageList.add(iv);
		
		return imageLinerLayout;
	}
	
	public View getLinearLayout(View view,int width,int height){
		LinearLayout linerLayout = new LinearLayout(activity);
		LinearLayout.LayoutParams linerLayoutParames = new LinearLayout.LayoutParams(
				width, 
				height,
				1);
		
		linerLayout.setPadding(10, 0, 10, 0);
		linerLayout.addView(view, linerLayoutParames);
		
		return linerLayout;
	}
	
	/**
	 * Set the dots with a specified number
	 * @param size
	 */
	public void setCircleImageLayout(int size){
		imageViews = new ImageView[size];
	}
	
	public ImageView getCircleImageLayout(int index){
		imageView = new ImageView(activity);  
		imageView.setLayoutParams(new LayoutParams(10,10));
        imageView.setScaleType(ScaleType.FIT_XY);
        
        imageViews[index] = imageView;
         
        if (index == 0) {  
            imageViews[index].setBackgroundResource(R.drawable.dot_selected);  
        } else {  
            imageViews[index].setBackgroundResource(R.drawable.dot_none);  
        }  
         
        return imageViews[index];
	}
	
	/**
	 * Set the index for the current image
	 * @param index
	 */
	public void setPageIndex(int index){
		pageIndex = index;
	}
	
	// Page Image click event
    private class ImageOnClickListener implements OnClickListener{
    	
    	private String mImageUrl = null;
    	private ImageView myImageView;
    	
    	public ImageOnClickListener(String imageUrl) {
			// TODO Auto-generated constructor stub
    		mImageUrl = imageUrl;
		}
    	
    	@Override
    	public void onClick(View v) {
    		// TODO Auto-generated method stub
    		//Toast.makeText(activity, "Excellent Image!!", Toast.LENGTH_SHORT).show();
    		Log.i("SeedsImageLoader: ","Image Clicking Event!");
    		myImageView = new ImageView(activity);
    		imageLoader.DisplayImage(mImageUrl,myImageView,1);
    		myImageView.setOnTouchListener(new ImageOnTouchListener());
    		final AlertDialog dialog = new AlertDialog.Builder(activity).create();

            dialog.setView(myImageView); 
            dialog.show();
    		    		
    	}
    }
    
    private class ImageOnTouchListener implements OnTouchListener {
    	// Zoom in and out
    	Matrix matrix = new Matrix();
    	Matrix savedMatrix = new Matrix();

    	PointF start = new PointF();
    	PointF mid = new PointF();
    	float oldDist;

    	private ImageView myImageView;

    	// Touch Mode
    	static final int NONE = 0;
    	static final int DRAG = 1;
    	static final int ZOOM = 2;
    	int mode = NONE;

    	@Override
    	public boolean onTouch(View v, MotionEvent event) {
    		ImageView myImageView = (ImageView) v;
    		switch (event.getAction() & MotionEvent.ACTION_MASK) {

    		case MotionEvent.ACTION_DOWN:
    			Log.i("SeedsImageLoader: ","MotionEvent: Action_Down!");
    			matrix.set(myImageView.getImageMatrix());
    			savedMatrix.set(matrix);
    			start.set(event.getX(), event.getY());
    			mode = DRAG;
    			break;
    		case MotionEvent.ACTION_UP:
    			Log.i("SeedsImageLoader: ","MotionEvent: Action_Up!");
    		case MotionEvent.ACTION_POINTER_UP:
    			Log.i("SeedsImageLoader: ","MotionEvent: Action_PointerUp!");
    			mode = NONE;
    			break;

    		// MultiTouch
    		case MotionEvent.ACTION_POINTER_DOWN:
    			Log.i("SeedsImageLoader: ","MotionEvent: Action_PointerDown!");
    			oldDist = spacing(event);
    			if (oldDist > 10f) {
    				savedMatrix.set(matrix);
    				midPoint(mid, event);
    				mode = ZOOM;
    			}
    			break;

    		case MotionEvent.ACTION_MOVE:
    			Log.i("SeedsImageLoader: ","MotionEvent: Action_Move!");
    			if (mode == DRAG) {
    				matrix.set(savedMatrix);
    				matrix.postTranslate(event.getX() - start.x, event.getY()
    						- start.y);
    			}

    			else if (mode == ZOOM) {
    				float newDist = spacing(event);
    				if (newDist > 10f) {
    					matrix.set(savedMatrix);
    					float scale = newDist / oldDist;

    					matrix.postScale(scale, scale, mid.x, mid.y);
    				}
    			}
    			break;
    		}
    		myImageView.setImageMatrix(matrix);
    		return true;
    	}

    	private float spacing(MotionEvent event) {
    		float x = event.getX(0) - event.getX(1);
    		float y = event.getY(0) - event.getY(1);
    		return FloatMath.sqrt(x * x + y * y);
    	}

    	private void midPoint(PointF point, MotionEvent event) {
    		float x = event.getX(0) + event.getX(1);
    		float y = event.getY(0) + event.getY(1);
    		point.set(x / 2, y / 2);
    	}
    }
    
}

