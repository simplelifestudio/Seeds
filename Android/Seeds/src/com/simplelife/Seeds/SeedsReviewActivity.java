package com.simplelife.Seeds;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.graphics.PointF;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.FloatMath;
import android.util.Log;
import android.view.MotionEvent;
import android.view.Window;
import android.widget.ImageView;

import com.simplelife.Seeds.Utils.ImageProcess.SeedsImageLoader;
import com.simplelife.Seeds.Utils.ImageProcess.SeedsImageLoadingDialog;

@SuppressLint("HandlerLeak")
public class SeedsReviewActivity extends Activity {

	private SeedsImageLoadingDialog tDialog;
	// Clarify the class which is used to load the image via url
	protected SeedsImageLoader imageLoader; 
	
	private ImageView tImageView;
	
	// Zoom in and out
	Matrix matrix = new Matrix();
	Matrix savedMatrix = new Matrix();

	PointF start = new PointF();
	PointF mid = new PointF();
	float oldDist;

	// Touch Mode
	static final int NONE = 0;
	static final int DRAG = 1;
	static final int ZOOM = 2;
	int mode = NONE;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE); 
		setContentView(R.layout.activity_seeds_details_fullscreen);
		
		// Retrieve the date info parameter
		Bundle bundle = getIntent().getExtras();
		final String tImgUrl = bundle.getString("imgLink");

		// Locate the image view
		tImageView = (ImageView)findViewById(R.id.Seeds_Review);
		imageLoader = new SeedsImageLoader(this.getApplicationContext());
		
		tDialog = new SeedsImageLoadingDialog(this);
		// The dialog should be closed when the image loading finished
		tDialog.setCanceledOnTouchOutside(false);
		tDialog.show();
		
		// Set up a thread to re-download the high density image
		new Thread() {
			
			@Override
			public void run() {
				try {
					imageLoader.DisplayImage(tImgUrl,tImageView,1);					
					
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
     
	@Override
	public boolean onTouchEvent(MotionEvent event) {

		switch (event.getAction() & MotionEvent.ACTION_MASK) {

		case MotionEvent.ACTION_DOWN:
			Log.i("SeedsImageLoader: ","MotionEvent: Action_Down!");
			matrix.set(tImageView.getImageMatrix());
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
		tImageView.setImageMatrix(matrix);
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

