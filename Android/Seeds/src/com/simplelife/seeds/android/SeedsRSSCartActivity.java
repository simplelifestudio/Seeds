/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsRSSCartActivity.java
 *  Seeds
 */
package com.simplelife.seeds.android;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.HashMap;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.ParseException;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;

import com.simplelife.seeds.android.SeedsListActivity.ModeCallback;
import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;
import com.simplelife.seeds.android.utils.gridview.gridviewui.ImageGridActivity;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.ImageFetcher;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.ImageCache.ImageCacheParams;
import com.simplelife.seeds.android.utils.jsonprocess.SeedsJSONMessage;
import com.simplelife.seeds.android.utils.networkprocess.SeedsNetworkProcess;

import android.annotation.SuppressLint;
import android.app.ActionBar;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.app.AlertDialog.Builder;
import android.content.DialogInterface;
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

public class SeedsRSSCartActivity extends SeedsListActivity{	
			
	private ArrayList<Integer> mSeedIdInCart = new ArrayList<Integer>();
	private static ArrayList<Integer> mSeedLocalIdInCart = new ArrayList<Integer>();
	private static ArrayList<Integer> mBookSuccSeedIdList = new  ArrayList<Integer>();
	private static ArrayList<Integer> mBookExistSeedIdList = new  ArrayList<Integer>();
	private static ArrayList<Integer> mBookFailedSeedIdList = new  ArrayList<Integer>();
	
	private static String mCartId;
	private ProgressDialog mProgressDialog = null; 
	
	// Handler message definition
	final int RSSMESSAGETYPE_GETLIST = 200;
	final int RSSMESSAGETYPE_UPDATEDIALOG = 201;
	final int RSSMESSAGETYPE_DISMISSDIALOG = 202;
	final int RSSMESSAGETYPE_TOAST = 203;
	final int RSSMESSAGETYPE_TOASTTEXT = 204;
	final int RSSMESSAGETYPE_CARTIDPROCESS = 205;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		// Set the list view layout
		setContentView(R.layout.activity_seeds_favlist);
		
		// Set a title for this page
		ActionBar tActionBar = getActionBar();
		tActionBar.setTitle(R.string.seeds_rss_management);					
		
		// Initialize the tSeedIdList
		mSeedIdList = new ArrayList<Integer>();
		
        mImageThumbSize = getResources().getDimensionPixelSize(R.dimen.image_thumbnail_size);

        ImageCacheParams cacheParams = new ImageCacheParams(this, SeedsDefinitions.SEEDS_THUMBS_CACHE_DIR);

        // The ImageFetcher takes care of loading images into our ImageView children asynchronously
        mImageFetcher = new ImageFetcher(this, mImageThumbSize);
        mImageFetcher.setLoadingImage(R.drawable.empty_photo);
        mImageFetcher.addImageCache(this.getSupportFragmentManager(), cacheParams, "RSSTAG");
		
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
		@SuppressWarnings("unchecked")
		public void handleMessage(Message msg) {
			switch(msg.what){
				case RSSMESSAGETYPE_GETLIST :
				{
					mListView = (ListView)findViewById(R.id.seeds_list);
				
					mSeedsListForListView = (ArrayList<SeedsEntity>)msg.obj;
					mAdapter = new SeedsAdapter(SeedsRSSCartActivity.this, mSeedsListForListView);
					mListView.setAdapter(mAdapter);

					// Bond the click listener
					mListView.setOnItemClickListener(new ListViewItemOnClickListener());
					mListView.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE_MODAL);
					mListView.setMultiChoiceModeListener(new ModeCallback());
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
            	case RSSMESSAGETYPE_CARTIDPROCESS:
            	{
            		processCartId(getCartId());
            		break;
            	}
            	default:
            		break;
			}
			
		}
	};
	
	protected void onMultiChosenProcess(final ArrayList<SeedsEntity> _intSeedsSelectedList){
		AlertDialog.Builder builder = new Builder(SeedsRSSCartActivity.this);
		builder.setMessage(getString(R.string.seeds_rsslist_deletedialogmsg));
		builder.setTitle(getString(R.string.seeds_rsslist_deletedialognote));
		builder.setPositiveButton(R.string.seeds_rsslist_deletedialogpos, new DialogInterface.OnClickListener() {
		    @Override
	        public void onClick(DialogInterface dialog, int which) {
			    dialog.dismiss();
	            mProgressDialog = ProgressDialog.show(SeedsRSSCartActivity.this, "Loading...", 
  			          getString(R.string.seeds_rsslist_deletedialoging), true, false);
  	            mProgressDialog.setCanceledOnTouchOutside(true);      	
			    int tSeedsNumInList = _intSeedsSelectedList.size();
			    for(int index=0; index<tSeedsNumInList; index++)
			    {
			        mSeedsEntityList.remove(_intSeedsSelectedList.get(index));
			        mSeedsListForListView.remove(_intSeedsSelectedList.get(index));
			    }
			    mAdapter.notifyDataSetChanged();
			    mProgressDialog.dismiss();
				Toast.makeText(SeedsRSSCartActivity.this, R.string.seeds_rsslist_deletedialogdone, Toast.LENGTH_SHORT).show();

			}				
		});

		builder.setNegativeButton(R.string.seeds_rsslist_deletedialogneg, new DialogInterface.OnClickListener() {
		    @Override
		    public void onClick(DialogInterface dialog, int which) {
		        dialog.dismiss();
		    }
		});

		builder.create().show();							
	}
	
	class ListViewItemOnClickListener implements OnItemClickListener {
		@Override
		public void onItemClick(AdapterView<?> parent, View view,
				int position, long id) {
			
			// Redirect to the details page
			Intent intent = new Intent(SeedsRSSCartActivity.this, ImageGridActivity.class);

			// Pass the seed entity
		    intent.putExtra("seedObj", mSeedsEntityList.get(position));
			startActivity(intent);
		}
	}		
	
	protected void loadSeedsInfo(){
		
		int localId;
		int remoteId;
		SeedsEntity tSeedsEntity;
		
		// Initialize the SeedsEntity List
		mSeedsEntityList.clear(); 
		
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
				tImgResult.close();
				
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
            case R.id.rss_removeall:
            {
            	clearSeedsCart();
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
	
    public static boolean addSeedToCart(int _inSeedLocalId){
    	if(mSeedLocalIdInCart.contains(_inSeedLocalId))
    		return false;
    	else
    		mSeedLocalIdInCart.add(_inSeedLocalId);
    				
    	return true;
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
	
	private void clearSeedsCart(){
		mSeedLocalIdInCart.clear();
		mSeedIdInCart.clear();
		mSeedsEntityList.clear();
		mSeedsListForListView.clear();
		mAdapter.notifyDataSetChanged();		
	}
		
	private void sendRSSBookMessage(){
		
		if(mSeedIdInCart.size() <= 0)
		{
			notifyUserViaToast(R.string.seeds_rss_toast_cartempty);
			return;
		}
		
		mProgressDialog = ProgressDialog.show(SeedsRSSCartActivity.this, "Loading...", 
		          getString(R.string.seeds_rss_dialog_sendingreqmsg), true, false);
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
						mLogger.excep(e);
					} catch (IOException e) {
						mLogger.excep(e);
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
						Message t_MsgListData = new Message();
						t_MsgListData.what = RSSMESSAGETYPE_CARTIDPROCESS;
						handler.sendMessage(t_MsgListData);	
						//processCartId(getCartId());
						//notifyUserViaToast(getString(R.string.seeds_rss_toast_booksuccess)+getCartId());
					} catch (JSONException e) {
						mLogger.excep(e);
					}			
				}
				dismissDialog();		
			}
		}.start();			
	}
	
    private void processCartId(final String _inCartId){	    
		AlertDialog.Builder builder = new Builder(SeedsRSSCartActivity.this);
		builder.setMessage(getString(R.string.seeds_rss_dialog_message)+_inCartId);
		builder.setTitle(getString(R.string.seeds_rss_dialog_note));
		builder.setPositiveButton(R.string.seeds_rss_dialog_btnpos, new DialogInterface.OnClickListener() {
		    @Override
	        public void onClick(DialogInterface dialog, int which) {
			    dialog.dismiss();
	            mProgressDialog = ProgressDialog.show(SeedsRSSCartActivity.this, "Loading...", 
  			          getString(R.string.seeds_rss_dialog_writefile), true, false);
  	            mProgressDialog.setCanceledOnTouchOutside(true);      	
		            new Thread() {  						
			            @Override
			            public void run() {
			            	String tTime = SeedsDateManager.getDateManager().getRealTimeNow();
			            	String tFileName = SeedsDefinitions.getDownloadDestFolder() +"/RSSCart_"+tTime+".txt";
			            	StringBuffer tMessage = new StringBuffer();
			            	tMessage.append("Seeds RSS Cart "+tTime+"\n\n\n");
			            	tMessage.append("Cart ID:  "+_inCartId+"\n");
			            	tMessage.append("RSS Link: "+"http://"+SeedsDefinitions.SEEDS_SERVER_RSS_ADDRESS+_inCartId+"\n");
			            	tMessage.append("===========================================\n");
			            	tMessage.append("Seeds in Cart:\n\n\n");
			            	int tSeedsNum = mSeedsEntityList.size();
			            	for(int index=0; index<tSeedsNum; index++)
			            	{
			            		SeedsEntity tSeedsEntity = mSeedsEntityList.get(index);
			            		tMessage.append(getString(R.string.seedTitle)+": "+tSeedsEntity.getSeedName()+"\n");
			            		tMessage.append(getString(R.string.seedSize)+": "+tSeedsEntity.getSeedSize()+"\n");
			            		tMessage.append(getString(R.string.seedFormat)+": "+tSeedsEntity.getSeedFormat()+"\n");
			            		tMessage.append("-------------------------------------------\n");
			            	}
			            	writeFileSdcard(tFileName, tMessage.toString());
			            	dismissDialog();
			            	notifyUserViaToast(getString(R.string.seeds_rss_dialog_filecreated)
			            			                    +tFileName+".\n"
			            			                    +getString(R.string.seeds_rss_dialog_fileget));
			            }				
		            }.start();
		    }
		});

		builder.setNegativeButton(R.string.seeds_rss_dialog_btnneg, new DialogInterface.OnClickListener() {
		    @Override
		    public void onClick(DialogInterface dialog, int which) {
		        dialog.dismiss();
		    }
		});

		builder.create().show();	
    }
    
    public void writeFileSdcard(String fileName,String message){ 
    	try {
    		File f = new File(fileName);
    		if (!f.exists()) {
    		    f.createNewFile();
    		}
    		OutputStreamWriter write = new OutputStreamWriter(new FileOutputStream(f),"UTF-8");
    		BufferedWriter writer=new BufferedWriter(write);   
    		writer.write(message);
    		writer.close();
    	} catch (Exception e) {
    		mLogger.excep(e);
    	}
    }
}
