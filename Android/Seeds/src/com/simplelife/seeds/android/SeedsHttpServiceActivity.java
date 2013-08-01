/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsHttpServiceActivity.java
 *  Seeds 
 */

package com.simplelife.seeds.android;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.ArrayList;
import java.util.Enumeration;

import com.simplelife.seeds.android.utils.httpserver.http.Server;
import com.simplelife.seeds.android.utils.httpserver.http.events.ServerEventListener;
import com.simplelife.seeds.android.utils.httpserver.utils.Logger;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Context;
import android.content.res.AssetManager;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Vibrator;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.Spinner;

public class SeedsHttpServiceActivity extends Activity {

	/** System vibration */
	private Vibrator mVibration;
	
	private Server mHttpServer;
	private Thread mServerThread;

	private InetAddress mInterface;
	
	private Spinner mAddressSpinner;

	
	/** Handler for server event reporting */
	private Handler mUpdateHandler = new Handler();
	private class EventMessage implements Runnable {
		private String mMessage;
		public EventMessage(String pMessage) {mMessage = pMessage;}
		public void run() {updateStatus(mMessage);}
	}
	
	/** Handler for address spinner select */
	private class AddressSelectedListener implements OnItemSelectedListener {

	    public void onItemSelected(AdapterView<?> pParent, View pView, int pPos, long pId) {
	    	mInterface = (InetAddress) pParent.getItemAtPosition(pPos);	
	    }

	    public void onNothingSelected(AdapterView<?> parent) {}
	}
	
	private ServerEventListener mServerEvents = new ServerEventListener() {
		
		@Override
		public void onServerReady(String pAddress, int pPort) {			
			mUpdateHandler.post(new EventMessage(getString(R.string.seeds_http_eventserverready) + pAddress + ":" + String.valueOf(pPort)));
		}
		
		@Override
		public void onRequestServed(String pResource) {
			mUpdateHandler.post(new EventMessage(getString(R.string.seeds_http_eventserve) + pResource));
		}
		
		@Override
		public void onRequestError(String pResource) {
			mUpdateHandler.post(new EventMessage(getString(R.string.seeds_http_eventserveerror) + pResource));
		}
	};
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);      
        
        //requestWindowFeature(Window.FEATURE_NO_TITLE);
        
		setContentView(R.layout.activity_seeds_httpserver);
		
		// Set a title for this page
		ActionBar tActionBar = getActionBar();
		tActionBar.setTitle(R.string.seeds_http_title);
		tActionBar.setDisplayHomeAsUpEnabled(true);
		
		// Setup the css files for web review
		new CopyUtil(this).assetsCopy();
        
		// start button
		findViewById(R.id.start).setOnClickListener(new View.OnClickListener() {
		    public void onClick(View v) {       
		    	vibrate();
		    	startServer();
		    }
		});
		        
		// stop button
		findViewById(R.id.stop).setOnClickListener(new View.OnClickListener() {
		    public void onClick(View v) {       
		    	vibrate();
		    	stopServer();
		    }
		});
		
		// address spinner		
    	getInterfaces();    	
		
    	mVibration = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
    	updateStatus(getString(R.string.seeds_http_taptostart));
		       
    }
    
    private void vibrate() {
    	mVibration.vibrate(35);
    }
    
    private void updateStatus(String pMessage) {
    	
    	((EditText)findViewById(R.id.status)).append(pMessage +"\n");

    }
    
    private void startServer() {
    	
    	mAddressSpinner.setEnabled(false);
    	Log.i("Testing", SeedsDefinitions.getDownloadDestFolder());
    	mHttpServer = new Server(mInterface, 8080, SeedsDefinitions.getDownloadDestFolder());
		mHttpServer.setRequestListener(mServerEvents);
		mServerThread = new Thread(mHttpServer);
		mServerThread.start();
    }
    

    private void stopServer() {
    	updateStatus(getString(R.string.seeds_http_stopserver));
    	if (mHttpServer != null) {
    		mHttpServer.stop();
    	}
    	if (mServerThread != null) {
    		mServerThread.interrupt();
    	}
    	mAddressSpinner.setEnabled(true);
		updateStatus(getString(R.string.seeds_http_serverstopped));
    }
    
    public void onStop() {
    	stopServer();
    	super.onStop();
    }
   

	private void getInterfaces() {
		try {
			ArrayList<InetAddress> addresses = new ArrayList<InetAddress>();
			for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements();) {
								
				NetworkInterface intf = en.nextElement();
				
				for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements();) {
					InetAddress inetAddress = enumIpAddr.nextElement();
					if (!inetAddress.isLoopbackAddress()  && inetAddress instanceof Inet4Address) {
						addresses.add(inetAddress);						
					}
				}
			}
			
			mAddressSpinner = (Spinner) findViewById(R.id.address);
			ArrayAdapter adapter = new ArrayAdapter(this, android.R.layout.simple_spinner_item, addresses.toArray());
			mAddressSpinner.setAdapter(adapter);
			mAddressSpinner.setOnItemSelectedListener(new AddressSelectedListener());
			mAddressSpinner.setEnabled(true);
			
		} catch (SocketException e) {
			Logger.error("Problem enumerating network interfaces");
		}
	}
	
	public class CopyUtil {

		private AssetManager manager;

		public CopyUtil(Context context) {
			manager = context.getAssets();
		}

		public boolean assetsCopy() {
			try {
				assetsCopy("SeedsWebService", Environment.getExternalStorageDirectory()
						+ "/.SeedsWebService"); 
			} catch (IOException e) {
				e.printStackTrace();
				return false;
			}
			return true;
		}

		public void assetsCopy(String assetsPath, String dirPath)
				throws IOException {
			String[] list = manager.list(assetsPath);
			if (list.length == 0) {
				InputStream in = manager.open(assetsPath);
				File file = new File(dirPath);
				file.getParentFile().mkdirs();
				file.createNewFile();
				FileOutputStream fout = new FileOutputStream(file);
				byte[] buf = new byte[1024];
				int count;
				while ((count = in.read(buf)) != -1) {
					fout.write(buf, 0, count);
					fout.flush();
				}

				in.close();
				fout.close();
			} else { 
				for (String path : list) {
					assetsCopy(assetsPath + "/" + path, dirPath + "/" + path);
				}
			}
		}

	}
	
}
