package com.simplelife.Seeds.Utils.ImageProcess;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Collections;
import java.util.Map;
import java.util.WeakHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.util.Log;
import android.widget.ImageView;

import com.simplelife.Seeds.R;

public class SeedsImageLoader {

	SeedsMemoryCache tMemoryCache = new SeedsMemoryCache();
	SeedsFileCache tFileCache;
	private Map<ImageView, String> imageViews = Collections
			.synchronizedMap(new WeakHashMap<ImageView, String>());
	ExecutorService executorService;
	
	private static String tag = "ImageLoader"; // for LogCat

	public SeedsImageLoader(Context context) {
		tFileCache = new SeedsFileCache(context);
		executorService = Executors.newFixedThreadPool(5);
	}

	// Change a image, I do not like black one...
	final int stub_id = R.drawable.no_image;
	
	public void DisplayImage(String url, ImageView imageView, int type) {
		Log.i(tag,"Trying to display the image, url=" + url);
		
		if(url == "Nothing To Show")
		{
			// Nothing to show here
			Log.i(tag,"Nothing to show inside this view!");
			imageView.setImageResource(stub_id);
			return;
		}
		
		imageViews.put(imageView, url);
		Bitmap bitmap = tMemoryCache.get(url);
		Bitmap bitmapToShow;
		if (bitmap != null)
		{
			Log.i(tag,"Bitmap already exists, Resize the bitmapurl=" + url);
			bitmapToShow = resizeBitmap(bitmap,type);
			imageView.setImageBitmap(bitmapToShow);
		}
		else {
			//Log.i(tag,"Dowload the image, url=" + url);
			queuePhoto(url, imageView);
			imageView.setImageResource(stub_id);
		}
	}
	
	private Bitmap resizeBitmap(Bitmap origBitmap, int type) {
		Bitmap resizedBitmap = null;
		// New to modify here
		//int newWidth = 640;
		float newWidth = 540;
		
		if(0 == type)
		{
			resizedBitmap = origBitmap;
		}
		else if(1 == type)
		{
			int width  = origBitmap.getWidth();
			int height = origBitmap.getHeight();
			float temp = ((float)height)/((float)width);
			int newHeight = (int)((newWidth)*temp);
			if(newHeight > 960)
			{
				newHeight = 960;
				newWidth  = newHeight / temp;				
			}
			Log.i(tag,"Resizing bitmap, width="+width+" height="+height);
			Log.i(tag,"Resizing bitmap, newWidth="+newWidth+" newHeight="+newHeight);
			
			float scaleWidth = ((float)newWidth)/width;
			float scaleHeight = ((float)newHeight)/height;
			Log.i(tag,"Resizing bitmap, scaleWidth="+scaleWidth+"scaleHeight="+scaleHeight);
			Matrix matrix = new Matrix();
			matrix.postScale(scaleWidth, scaleHeight);
			//resizedBitmap = Bitmap.createBitmap(origBitmap,0,0,width,height,matrix,true);
			try {  
		    	 resizedBitmap = Bitmap.createBitmap(origBitmap,0,0,width,height,matrix,true);
		     } catch (OutOfMemoryError e) {  
		         while(resizedBitmap == null) {  
		             System.gc();  
		             System.runFinalization();  
		             resizedBitmap = Bitmap.createBitmap(origBitmap,0,0,width,height,matrix,true); 
		         }  
		     } 
			// origBitmap.recycle();
			// Is it correct
			//origBitmap= resizedBitmap;
			
		}
		
		return resizedBitmap;
	}
	
	/*
	public int FetchImage(String url) {
		Bitmap bitmap = tMemoryCache.get(url);
		if (bitmap != null)
		{
			return bitmap;
		}
		else
		{
			queuePhoto(url, imageView);
			imageView.setImageResource(stub_id);			
		}
		
	}*/

	private void queuePhoto(String url, ImageView imageView) {
		PhotoToLoad p = new PhotoToLoad(url, imageView);
		executorService.submit(new PhotosLoader(p));
	}

	private Bitmap getBitmap(String url) {
		File f = tFileCache.getFile(url);

		// If it has already been downloaded, the get it from SD card
		Bitmap b = decodeFile(f);
		if (b != null)
			return b;

		// If new, download from Internet 
		try {
			Bitmap bitmap = null;
			URL imageUrl = new URL(url);
			Log.i(tag,"Working on fetching the image from internet,url=" + imageUrl);
			HttpURLConnection conn = (HttpURLConnection) imageUrl
					.openConnection();
			conn.setConnectTimeout(30000);
			conn.setReadTimeout(30000);
			conn.setInstanceFollowRedirects(true);
			InputStream is = conn.getInputStream();
			OutputStream os = new FileOutputStream(f);
			//Log.i(tag,"Working on fetching the image InputStream=" + is);
			copyStream(is, os);
			
			//os.close();
			bitmap = decodeFile(f);
			return bitmap;
		} catch (Exception ex) {
			ex.printStackTrace();
			return null;
		}
	}

	// Decode the image to save the memory
	private Bitmap decodeFile(File f) {
		try {

			int scale = 1;
			BitmapFactory.Options o = new BitmapFactory.Options();
			o.inJustDecodeBounds = true;
			BitmapFactory.decodeStream(new FileInputStream(f), null, o);
			
			//final int REQUIRED_SIZE = 70;		
			final int REQUIRED_SIZE = 280;
			int width_tmp = o.outWidth, height_tmp = o.outHeight;
			//Log.i(tag,"Decoding bitmap, widthtmp="+width_tmp+"heightmp="+height_tmp);
			while (true) {
				if (width_tmp / 2 < REQUIRED_SIZE
						|| height_tmp / 2 < REQUIRED_SIZE)
					break;
				width_tmp /= 2;
				height_tmp /= 2;
				scale *= 2;
			}

			BitmapFactory.Options o2 = new BitmapFactory.Options();
			o2.inSampleSize = scale;
			return BitmapFactory.decodeStream(new FileInputStream(f), null, o2);
			//return BitmapFactory.decodeStream(
			//		new BufferedInputStream(new FileInputStream(f), 32*1024),
			//		null,o2);
		} catch (FileNotFoundException e) {
		}
		return null;
	}

	private class PhotoToLoad {
		public String url;
		public ImageView imageView;

		public PhotoToLoad(String u, ImageView i) {
			url = u;
			imageView = i;
		}
	}

	class PhotosLoader implements Runnable {
		PhotoToLoad photoToLoad;

		PhotosLoader(PhotoToLoad photoToLoad) {
			this.photoToLoad = photoToLoad;
		}

		@Override
		public void run() {
			if (imageViewReused(photoToLoad))
				return;
			Bitmap bmp = getBitmap(photoToLoad.url);
			tMemoryCache.put(photoToLoad.url, bmp);
			if (imageViewReused(photoToLoad))
				return;
			BitmapDisplayer bd = new BitmapDisplayer(bmp, photoToLoad);
			Activity a = (Activity) photoToLoad.imageView.getContext();
			a.runOnUiThread(bd);
		}
	}

	boolean imageViewReused(PhotoToLoad photoToLoad) {
		String tag = imageViews.get(photoToLoad.imageView);
		if (tag == null || !tag.equals(photoToLoad.url))
			return true;
		return false;
	}


	class BitmapDisplayer implements Runnable {
		Bitmap bitmap;
		PhotoToLoad photoToLoad;

		public BitmapDisplayer(Bitmap b, PhotoToLoad p) {
			bitmap = b;
			photoToLoad = p;
		}

		public void run() {
			if (imageViewReused(photoToLoad))
				return;
			if (bitmap != null)
				//bitmapToShow = resizeBitmap(bitmap,type);
				//photoToLoad.imageView.setImageBitmap(bitmap);
				photoToLoad.imageView.setImageBitmap(resizeBitmap(bitmap,1));
			else
				photoToLoad.imageView.setImageResource(stub_id);
		}
	}
	
    public static void copyStream(InputStream in, OutputStream out) throws IOException {
	    // Transfer bytes from in to out
	    byte[] buf = new byte[1024];
	    int len;
	    while ((len = in.read(buf)) > 0) {
	        out.write(buf, 0, len);
	    }
	    in.close();
	    out.close();
	}

	public void clearCache() {
		tMemoryCache.clear();
		tFileCache.clear();
	}
}