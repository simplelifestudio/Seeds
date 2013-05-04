package com.simplelife.Seeds.Utils.ImageProcess;

import java.util.ArrayList;

import com.simplelife.Seeds.R;
import com.simplelife.Seeds.SeedsListPerDayActivity;

import android.app.Activity;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;
import android.widget.ImageView.ScaleType;

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
		
		iv.setOnClickListener(new ImageOnClickListener());
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
	
	// 滑动页面点击事件监听器
    private class ImageOnClickListener implements OnClickListener{
    	@Override
    	public void onClick(View v) {
    		// TODO Auto-generated method stub
    		//Toast.makeText(activity, parser.getSlideTitles()[pageIndex], Toast.LENGTH_SHORT).show();
    		//Toast.makeText(activity, parser.getSlideUrls()[pageIndex], Toast.LENGTH_SHORT).show();
    	}
    }
}

