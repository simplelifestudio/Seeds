/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsRSSCartActivity.java
 *  Seeds
 *
 *  Created by Chris Li on 13-7-19. 
 */
package com.simplelife.seeds.android;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.ParseException;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;
import com.simplelife.seeds.android.utils.adapter.SeedsAdapter;
import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;
import com.simplelife.seeds.android.utils.jsonprocess.SeedsJSONMessage;
import com.simplelife.seeds.android.utils.networkprocess.SeedsNetworkProcess;
import com.simplelife.seeds.android.utils.seedslogger.SeedsLoggerUtil;

import android.annotation.SuppressLint;
import android.app.ActionBar;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.NavUtils;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.Toast;
import android.widget.AdapterView.OnItemClickListener;

public class SeedsRSSCartActivity extends Activity{
	
	public static final String KEY_THUMB_URL = "thumb_url";
	
	private static ArrayList<Integer> mSeedLocalIdInCart = new ArrayList<Integer>();;
	private ArrayList<Integer> mSeedIdInCart;
	private ListView mListView;
	private SeedsAdapter mAdapter;
	private String mDate;
	private ArrayList<SeedsEntity> mSeedsEntityList;
	private static ArrayList<Integer> mBookSuccSeedIdList = new  ArrayList<Integer>();
	private static ArrayList<Integer> mBookExistSeedIdList = new  ArrayList<Integer>();
	private static ArrayList<Integer> mBookFailedSeedIdList = new  ArrayList<Integer>();
	private static String mCartId;
	private ProgressDialog mProgressDialog = null; 
	
	private SeedsLoggerUtil mLogger = SeedsLoggerUtil.getSeedsLogger();
	
	// Handler message definition
	final int RSSMESSAGETYPE_GETLIST = 200;
	final int RSSMESSAGETYPE_UPDATEDIALOG = 201;
	final int RSSMESSAGETYPE_DISMISSDIALOG = 202;
	final int RSSMESSAGETYPE_TOAST = 203;
	final int RSSMESSAGETYPE_TOASTTEXT = 204;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		// Set the list view layout
		setContentView(R.layout.activity_seeds_favlist);
		
		// Set a title for this page
		ActionBar tActionBar = getActionBar();
		tActionBar.setTitle(R.string.seeds_rss_management);	
				
		// Initialize the mSeedIdInCart
		mSeedIdInCart = new ArrayList<Integer>();
		
		// Start a new thread to get the data
		new Thread(new Runnable() {
			@Override
			public void run() {
				Message msg = new Message();
				msg.what = RSSMESSAGETYPE_GETLIST;
				
				// Retrieve the seeds list
				msg.obj = getList();
				handler.sendMessage(msg);
			}
		}).start();		
	}	
	
	@SuppressLint("HandlerLeak")
	private Handler handler = new Handler(){
		public void handleMessage(Message msg) {
			switch(msg.what){
				case RSSMESSAGETYPE_GETLIST :
				{
					mListView = (ListView)findViewById(R.id.seeds_list);
				
					ArrayList<HashMap<String, String>> seedsList = (ArrayList<HashMap<String, String>>)msg.obj;
					mAdapter = new SeedsAdapter(SeedsRSSCartActivity.this, seedsList);
					mListView.setAdapter(mAdapter);

					// Bond the click listener
					mListView.setOnItemClickListener(new ListViewItemOnClickListener());
					break;
				}
				case RSSMESSAGETYPE_UPDATEDIALOG:
				{
					// Retrieve the date info parameter
					Bundle bundle = msg.getData();             				
					String tStatus = bundle.getString("status");        		
					mProgressDialog.setMessage(tStatus);
					break;
				}
				case RSSMESSAGETYPE_DISMISSDIALOG:
				{       		
					mProgressDialog.dismiss();
					break;
				}
            	case RSSMESSAGETYPE_TOAST:
            	{
            		Bundle bundle = msg.getData();             				
            		int tResId  = bundle.getInt("resId");
            		Toast toast = Toast.makeText(getApplicationContext(), tResId, Toast.LENGTH_SHORT);
            	    toast.setGravity(Gravity.CENTER, 0, 0);
            	    toast.show();
            	    break;
            	}
            	case RSSMESSAGETYPE_TOASTTEXT:
            	{
            		Bundle bundle = msg.getData();             				
            		String tText  = bundle.getString("text");
            		Toast toast = Toast.makeText(getApplicationContext(), tText, Toast.LENGTH_LONG);
            	    toast.setGravity(Gravity.CENTER, 0, 0);
            	    toast.show();
            	    break;
            	}
            	default:
            		break;
			}
			
		}
	};
	
	class ListViewItemOnClickListener implements OnItemClickListener {
		@Override
		public void onItemClick(AdapterView<?> parent, View view,
				int position, long id) {
			
			// Redirect to the details page
			Intent intent = new Intent(SeedsRSSCartActivity.this, SeedsDetailsActivity.class);

			// Pass the seed entity
		    intent.putExtra("seedObj", mSeedsEntityList.get(position));
			startActivity(intent);
		}
	}	
	
	private ArrayList<HashMap<String, String>> getList() {
		
		ArrayList<HashMap<String, String>> seedsList = new ArrayList<HashMap<String, String>>();
		String tFirstImgUrl;
		
		// Load all the seeds info
		loadSeedsInfo();
		
		// Walk through the SeedsEntity List
		int tListSize = mSeedsEntityList.size();
		for (int index = 0; index < tListSize; index++)
		{
			SeedsEntity tSeedsEntity = mSeedsEntityList.get(index);
					
			if(tSeedsEntity.getSeedIsPicAvail())
				tFirstImgUrl = tSeedsEntity.getPicLinks().get(0);
			else
				tFirstImgUrl = "Nothing To Show";
			
			HashMap<String, String> map = new HashMap<String, String>();
			map.put(SeedsDBAdapter.KEY_NAME, tSeedsEntity.getSeedName());
			map.put(SeedsDBAdapter.KEY_SIZE, tSeedsEntity.getSeedSize());
			map.put(SeedsDBAdapter.KEY_FORMAT, tSeedsEntity.getSeedFormat());
			String tMosaic = (tSeedsEntity.getSeedMosaic())
					       ? getString(R.string.seeds_listperday_withmosaic)
					       : getString(R.string.seeds_listperday_withoutmosaic);
			map.put(SeedsDBAdapter.KEY_MOSAIC, tMosaic);
			map.put(KEY_THUMB_URL, tFirstImgUrl);
			
			// Add the instance into the array
			seedsList.add(map);			
		}
		
		return seedsList;	
	}
	
	private void loadSeedsInfo(){
		
		int localId;
		int remoteId;
		SeedsEntity tSeedsEntity;
		
		// Initialize the SeedsEntity List
		mSeedsEntityList = new ArrayList<SeedsEntity>(); 
		
		// Retrieve the DB process handler to get data 
		SeedsDBAdapter mDBAdapter = SeedsDBAdapter.getAdapter();
		
		int tSeedLocalIdSize = mSeedLocalIdInCart.size();
		for(int index = 0; index < tSeedLocalIdSize; index++)
		{
			int tSeedLocalId = mSeedLocalIdInCart.get(index);
			
			// Get the seeds entries according to the favorite tag
			Cursor tResult = mDBAdapter.getSeedEntryViaLocalId(tSeedLocalId);
			if (!tResult.isAfterLast()) 
		    {
				localId  = tResult.getInt(tResult.getColumnIndex(SeedsDBAdapter.KEY_ID_SEED));
				remoteId = tResult.getInt(tResult.getColumnIndex(SeedsDBAdapter.KEY_SEEDID));
				// Construct seeds entity
				tSeedsEntity = new SeedsEntity();
				tSeedsEntity.setLocalId(localId);
				tSeedsEntity.setSeedId(remoteId);
				tSeedsEntity.setSeedType(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_TYPE)));
				tSeedsEntity.setSeedSource(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_SOURCE)));
				tSeedsEntity.setSeedPublishDate(mDate);
				tSeedsEntity.setSeedName(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_NAME)));
				tSeedsEntity.setSeedSize(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_SIZE)));
				tSeedsEntity.setSeedFormat(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_FORMAT)));
				tSeedsEntity.setSeedTorrentLink(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_TORRENTLINK)));
				tSeedsEntity.setSeedHash(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_HASH)));
				if(1 == tResult.getInt(tResult.getColumnIndex(SeedsDBAdapter.KEY_MOSAIC)))
					tSeedsEntity.setSeedMosaic(true);
				else
					tSeedsEntity.setSeedMosaic(false);
				if(1 == tResult.getInt(tResult.getColumnIndex(SeedsDBAdapter.KEY_FAVORITE)))
					tSeedsEntity.setSeedFavorite(true);
				else
					tSeedsEntity.setSeedFavorite(false);
				
				// Query the seedPic table
				Cursor tImgResult = mDBAdapter.getSeedPicFirstEntryViaLocalId(localId);
				
				if(tImgResult.getCount()<=0)
				{
					tSeedsEntity.setSeedIsPicAvail(false);
				}
				else{
					tImgResult.moveToFirst();
					// Think twice if we really need a while loop here
					while(!tImgResult.isAfterLast())
					{
						String tPicUrl = tImgResult.getString(tImgResult.getColumnIndex(SeedsDBAdapter.KEY_PICTURELINK));
						tSeedsEntity.addPicLink(tPicUrl);
						
						// Move to the next result
						tImgResult.moveToNext(); 
					}
					tSeedsEntity.setSeedIsPicAvail(true);											
				}						
				
				// Add into the seedsEntity list
				mSeedsEntityList.add(tSeedsEntity);
				// Add the remote SeedId into the list
				mSeedIdInCart.add(remoteId);
		    }
			tResult.close();
		}
	 
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_seeds_rss_management, menu);
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
            case R.id.rss_sendreqmsg:
            {
            	sendRSSBookMessage();
    		    return true;
            }
        }
        return super.onOptionsItemSelected(item);
    }
	
	private void updateDialogStatus(String inContents){
		
		Message t_MsgListData = new Message();
		t_MsgListData.what = RSSMESSAGETYPE_UPDATEDIALOG;
		
	    Bundle bundle = new Bundle();
	    bundle.putString("status", inContents);	    
		t_MsgListData.setData(bundle);
		handler.sendMessage(t_MsgListData);							
	}
	
	
    private void notifyUserViaToast(int _inResId){
	    
		Message t_MsgListData = new Message();
		t_MsgListData.what = RSSMESSAGETYPE_TOAST;
		
	    Bundle bundle = new Bundle();
	    bundle.putInt("resId", _inResId);    
		t_MsgListData.setData(bundle);
		handler.sendMessage(t_MsgListData);		
    }
    
    private void notifyUserViaToast(String _inText){
	    
		Message t_MsgListData = new Message();
		t_MsgListData.what = RSSMESSAGETYPE_TOASTTEXT;
		
	    Bundle bundle = new Bundle();
	    bundle.putString("text", _inText);    
		t_MsgListData.setData(bundle);
		handler.sendMessage(t_MsgListData);		
    } 
	
	private void dismissDialog(){
		
		Message t_MsgListData = new Message();
		t_MsgListData.what = RSSMESSAGETYPE_DISMISSDIALOG;
		handler.sendMessage(t_MsgListData);							
	}
	
    public static void addSeedToCart(int _inSeedLocalId){
		mSeedLocalIdInCart.add(_inSeedLocalId);
	}
	
	public static void setBookSuccSeedIdList(ArrayList<Integer> _inSuccList){
		mBookSuccSeedIdList = _inSuccList;
	}
	
	public static void setBookExistSeedIdList(ArrayList<Integer> _inExistList){
		mBookExistSeedIdList = _inExistList;
	}
	
	public static void setBookFailedSeedIdList(ArrayList<Integer> _inFailedList){
		mBookFailedSeedIdList = _inFailedList;
	}	
	
	public static void setCartId(String _inCartId){
		mCartId = _inCartId;
	}
	
	public static String getCartId(){
		return mCartId;
	}
		
	private void sendRSSBookMessage(){
		
		mProgressDialog = ProgressDialog.show(SeedsRSSCartActivity.this, "Loading...", 
		          getString(R.string.seeds_rss_dialof_sendingreqmsg), true, false);
		mProgressDialog.setCanceledOnTouchOutside(true);
		
		// Set up a thread to communicate with server
		new Thread() {				
			@Override
			public void run() {
				boolean tProcessFlag = true;
				HttpResponse tMsgResp = null;
				String tSeedsToCartResp = null;
				
				try {
					tMsgResp = SeedsNetworkProcess.sendSeedsToCartReqMsg(mSeedIdInCart);
				} catch (ClientProtocolException e) {
					tProcessFlag = false;
					mLogger.excep(e);			
				} catch (JSONException e) {
					tProcessFlag = false;
					mLogger.excep(e);
				} catch (IOException e) {
					tProcessFlag = false;
					mLogger.excep(e);
				}
				
				if(false == tProcessFlag)
				{
					dismissDialog();
					notifyUserViaToast(R.string.seeds_rss_toast_sendreqfailed);
					return;
				}
				
		        // Check the response context
				if (tMsgResp.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
		            
					try {
						tSeedsToCartResp = EntityUtils.toString(tMsgResp.getEntity());
					} catch (ParseException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
		            mLogger.debug("Receive response msg: "+ tSeedsToCartResp);
		            // String strsResult = strResult.replace("\r", "");            
		        } else {
		        	mLogger.warn("SeedsToCartReq Message Sending Failed! Status Code: "
		                         + tMsgResp.getStatusLine().getStatusCode());
		        	dismissDialog();
		        	notifyUserViaToast(R.string.seeds_datelist_updatestatuscommerror);        	
		        	return;           
		        }
				
				if (null == tSeedsToCartResp)
				{
					dismissDialog();
					notifyUserViaToast(R.string.seeds_rss_toast_emptycartresp); 
					mLogger.error("Receiving empty SeedsToCartResp message!");
					return;
				}
				else
				{
					try {
						SeedsJSONMessage.parseSeedsToCartRespMsg(tSeedsToCartResp);
						notifyUserViaToast(getString(R.string.seeds_rss_toast_booksuccess)+getCartId());
					} catch (JSONException e) {
						mLogger.excep(e);
					}			
				}
				dismissDialog();		
			}
		}.start();	
		
	}
	

}
