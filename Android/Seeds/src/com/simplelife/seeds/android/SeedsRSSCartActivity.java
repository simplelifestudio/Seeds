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
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.ParseException;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;

import com.simplelife.seeds.android.SeedsDefinitions.SeedsGlobalNOTECode;
import com.simplelife.seeds.android.SeedsListActivity.SeedsAdapter;
import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;
import com.simplelife.seeds.android.utils.gridview.gridviewui.ImageGridActivity;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.ImageFetcher;
import com.simplelife.seeds.android.utils.gridview.gridviewutil.ImageCache.ImageCacheParams;
import com.simplelife.seeds.android.utils.jsonprocess.SeedsJSONMessage;
import com.simplelife.seeds.android.utils.networkprocess.SeedsNetworkProcess;
import com.simplelife.seeds.android.utils.seedslogger.SeedsLoggerUtil;
//import com.simplelife.seeds.android.utils.slidingmenu.lib.SlidingMenu;

import android.annotation.SuppressLint;
import android.app.ActionBar;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.FragmentTransaction;
import android.app.ProgressDialog;
import android.app.AlertDialog.Builder;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.app.NavUtils;
import android.support.v4.view.ViewPager;
import android.view.ActionMode;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.AdapterView.OnItemClickListener;

public class SeedsRSSCartActivity extends FragmentActivity implements ActionBar.TabListener{
	
    AppSectionsPagerAdapter mAppSectionsPagerAdapter;
    ViewPager mViewPager;
    
    protected int mImageThumbSize;
    protected static ImageFetcher mImageFetcher;
    
	// For log purpose
    protected static SeedsLoggerUtil mLogger; 
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_seeds_rssid_main);

        mLogger = SeedsLoggerUtil.getSeedsLogger(SeedsRSSCartActivity.this);
        // Create the adapter that will return a fragment for each of the three primary sections
        // of the app.
        mAppSectionsPagerAdapter = new AppSectionsPagerAdapter(getSupportFragmentManager());
        
        // Set a title for this page
        final ActionBar tActionBar = getActionBar();
        tActionBar.setTitle(R.string.seeds_rss_management);
        tActionBar.setHomeButtonEnabled(false);
        tActionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_TABS);
        
        mViewPager = (ViewPager) findViewById(R.id.rss_pager);
        mViewPager.setAdapter(mAppSectionsPagerAdapter);
        mViewPager.setOnPageChangeListener(new ViewPager.SimpleOnPageChangeListener() {
            @Override
            public void onPageSelected(int position) {
                // When swiping between different app sections, select the corresponding tab.
                // We can also use ActionBar.Tab#select() to do this if we have a reference to the
                // Tab.
            	tActionBar.setSelectedNavigationItem(position);
            }
        });

        // For each of the sections in the app, add a tab to the action bar.
        for (int i = 0; i < mAppSectionsPagerAdapter.getCount(); i++) {
            // Create a tab with text corresponding to the page title defined by the adapter.
            // Also specify this Activity object, which implements the TabListener interface, as the
            // listener for when this tab is selected.
        	tActionBar.addTab(
        			tActionBar.newTab()
                            .setText(mAppSectionsPagerAdapter.getPageTitle(i))
                            .setTabListener(this));
        }
        
        mImageThumbSize = getResources().getDimensionPixelSize(R.dimen.image_thumbnail_size);

        ImageCacheParams cacheParams = new ImageCacheParams(this, SeedsDefinitions.SEEDS_THUMBS_CACHE_DIR);

        // The ImageFetcher takes care of loading images into our ImageView children asynchronously
        mImageFetcher = new ImageFetcher(this, mImageThumbSize);
        mImageFetcher.setLoadingImage(R.drawable.empty_photo);
        mImageFetcher.addImageCache(this.getSupportFragmentManager(), cacheParams, "RSSTAG");
    }
    
    @Override
    public void onTabUnselected(ActionBar.Tab tab, FragmentTransaction fragmentTransaction) {
    }

    @Override
    public void onTabSelected(ActionBar.Tab tab, FragmentTransaction fragmentTransaction) {
        // When the given tab is selected, switch to the corresponding page in the ViewPager.
        mViewPager.setCurrentItem(tab.getPosition());
    }

    @Override
    public void onTabReselected(ActionBar.Tab tab, FragmentTransaction fragmentTransaction) {
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
            	//sendRSSBookMessage();
    		    return true;
            }
            case R.id.rss_removeall:
            {
            	//clearSeedsCart();
            	return true;
            }
        }
        return super.onOptionsItemSelected(item);
    }
    
    public static class AppSectionsPagerAdapter extends FragmentPagerAdapter {

        public AppSectionsPagerAdapter(FragmentManager fm) {
            super(fm);
        }

        @Override
        public Fragment getItem(int i) {
            switch (i) {
                case 0:
                    // The first section of the app is the most interesting -- it offers
                    // a launchpad into the other demonstrations in this example application.
                    return new SeedsRSSList();

                default:
                    // The other sections of the app are dummy placeholders.
                    Fragment fragment = new SeedsRSSCartIDMgt();
                    return fragment;
            }
        }

        @Override
        public int getCount() {
            return 3;
        }

        @Override
        public CharSequence getPageTitle(int position) {
            return "Section " + (position + 1);
        }
    }


	public static class SeedsRSSList extends Fragment {		
		private ArrayList<Integer> mSeedIdInCart = new ArrayList<Integer>();
		private static ArrayList<Integer> mSeedLocalIdInCart = new ArrayList<Integer>();
		private static ArrayList<Integer> mBookSuccSeedIdList = new  ArrayList<Integer>();
		private static ArrayList<Integer> mBookExistSeedIdList = new  ArrayList<Integer>();
		private static ArrayList<Integer> mBookFailedSeedIdList = new  ArrayList<Integer>();
		protected List<Integer> mSeedIdList;
		
	    protected ArrayList<SeedsEntity> mSeedsEntityList;
	    protected ArrayList<SeedsEntity> mSeedsEntityChosen;
	    protected ArrayList<SeedsEntity> mSeedsEntityChosenToDel;
	    protected ArrayList<View> mSeedsViewsChosen;
	    protected ArrayList<ImageView> mImageViewList;
	    protected ArrayList<SeedsEntity> mSeedsListForListView;
	    
	    protected ArrayList<Integer> mSelectedList; 
		protected ListView mListView;
		protected SeedsAdapter mAdapter;
					
		private static String mCartId;
		private ProgressDialog mProgressDialog = null; 
		private TextView mEmptyView;
	
		// Handler message definition
		final int RSSMESSAGETYPE_GETLIST = 200;
		final int RSSMESSAGETYPE_UPDATEDIALOG = 201;
		final int RSSMESSAGETYPE_DISMISSDIALOG = 202;
		final int RSSMESSAGETYPE_TOAST = 203;
		final int RSSMESSAGETYPE_TOASTTEXT = 204;
		final int RSSMESSAGETYPE_CARTIDPROCESS = 205;
	
		@Override
		public void onCreate(Bundle savedInstanceState) {
			super.onCreate(savedInstanceState);
				
			// Initialize the SeedsEntity List
			mSeedsEntityList = new ArrayList<SeedsEntity>();
			mSeedsListForListView = new ArrayList<SeedsEntity>();
			mSeedsEntityChosen = new ArrayList<SeedsEntity>();
			mSeedsEntityChosenToDel = new ArrayList<SeedsEntity>();
			mSeedsViewsChosen  = new  ArrayList<View>();
			mImageViewList = new ArrayList<ImageView>();
			mSelectedList  = new ArrayList<Integer>();
		
			// Initialize the tSeedIdList
			mSeedIdList = new ArrayList<Integer>();
				
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
		
		protected ArrayList<SeedsEntity> getList() {
			loadSeedsInfo();				
			return mSeedsEntityList;	
		}
		
        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container,
                Bundle savedInstanceState) {
            View rootView = inflater.inflate(R.layout.activity_seeds_favlist, container, false);
            
            mEmptyView = (TextView)rootView.findViewById(R.id.favlist_empty);
    		mEmptyView.setText(R.string.seeds_rsslist_empty);
    		mListView = (ListView)rootView.findViewById(R.id.seeds_list);
    		    		
            Bundle args = getArguments();
            return rootView;
        }        
	
        @SuppressLint("HandlerLeak")
        private Handler handler = new Handler(){
        	@SuppressWarnings("unchecked")
        	public void handleMessage(Message msg) {
        		switch(msg.what){
					case RSSMESSAGETYPE_GETLIST :
					{										
						mSeedsListForListView = (ArrayList<SeedsEntity>)msg.obj;
						if (mSeedsListForListView.size() <= 0) {						
							mEmptyView.setVisibility(View.VISIBLE);
						} else {
							mEmptyView.setVisibility(View.GONE);
						}
						mAdapter = new SeedsAdapter(getActivity(), mSeedsListForListView);
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
						Toast toast = Toast.makeText(getActivity(), tResId, Toast.LENGTH_SHORT);
						toast.setGravity(Gravity.CENTER, 0, 0);
						toast.show();
						break;
					}
					case RSSMESSAGETYPE_TOASTTEXT:
					{
						Bundle bundle = msg.getData();             				
						String tText  = bundle.getString("text");
						Toast toast = Toast.makeText(getActivity(), tText, Toast.LENGTH_LONG);
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
			AlertDialog.Builder builder = new Builder(getActivity());
			builder.setMessage(getString(R.string.seeds_rsslist_deletedialogmsg));
			builder.setTitle(getString(R.string.seeds_rsslist_deletedialognote));
			builder.setPositiveButton(R.string.seeds_rsslist_deletedialogpos, new DialogInterface.OnClickListener() {
				@Override
				public void onClick(DialogInterface dialog, int which) {
					dialog.dismiss();
					mProgressDialog = ProgressDialog.show(getActivity(), "Loading...", 
							getString(R.string.seeds_rsslist_deletedialoging), true, false);
					mProgressDialog.setCanceledOnTouchOutside(true);      	
					int tSeedsNumInList = _intSeedsSelectedList.size();
					for(int index=0; index<tSeedsNumInList; index++)
					{
						mSeedLocalIdInCart.remove((Integer)_intSeedsSelectedList.get(index).getSeedLocalId());
						mSeedIdInCart.remove((Integer)_intSeedsSelectedList.get(index).getSeedId());
						mSeedsEntityList.remove(_intSeedsSelectedList.get(index));
						mSeedsListForListView.remove(_intSeedsSelectedList.get(index));
					}
					if (mSeedsListForListView.size() <= 0) 						
						mEmptyView.setVisibility(View.VISIBLE);
					mAdapter.notifyDataSetChanged();
					mProgressDialog.dismiss();
					Toast.makeText(getActivity(), R.string.seeds_rsslist_deletedialogdone, Toast.LENGTH_SHORT).show();
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
				Intent intent = new Intent(getActivity(), ImageGridActivity.class);

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
			SeedsDBAdapter mDBAdapter = SeedsDBAdapter.getAdapter(getActivity());
		
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
					tSeedsEntity.setSeedPublishDate(tResult.getString(tResult.getColumnIndex(SeedsDBAdapter.KEY_PUBLISHDATE)));
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
			mEmptyView.setVisibility(View.VISIBLE);
		}
		
		private void sendRSSBookMessage(){
			
			if(mSeedIdInCart.size() <= 0)
			{
				notifyUserViaToast(R.string.seeds_rss_toast_cartempty);
				return;
			}
		
			mProgressDialog = ProgressDialog.show(getActivity(), "Loading...", 
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
			AlertDialog.Builder builder = new Builder(getActivity());
			builder.setMessage(getString(R.string.seeds_rss_dialog_message)+_inCartId);
			builder.setTitle(getString(R.string.seeds_rss_dialog_note));
			builder.setPositiveButton(R.string.seeds_rss_dialog_btnpos, new DialogInterface.OnClickListener() {
			    @Override
		        public void onClick(DialogInterface dialog, int which) {
				    dialog.dismiss();
		            mProgressDialog = ProgressDialog.show(getActivity(), "Loading...", 
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
    
	    protected class ModeCallback implements ListView.MultiChoiceModeListener{
        
			public boolean onCreateActionMode(ActionMode mode, Menu menu) {
	            MenuInflater inflater = getActivity().getMenuInflater();
	            mSeedsEntityChosen.clear();
	            mSeedsEntityChosenToDel.clear();
	            mSeedsViewsChosen.clear();
	            inflater.inflate(R.menu.activity_seeds_list_contextualmenu, menu);
	            mode.setTitle(getString(R.string.seeds_list_contextualtitle));
	            setSubtitle(mode);
	            return true;
	        }
	
	        public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
	            return true;
	        }
	
	        public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
	            switch (item.getItemId()) {
	            case R.id.seedslist_del:
	            	onMultiChosenProcess(mSeedsEntityChosenToDel);
	                mode.finish();
	            break;
	            default:
	            break;
	            }
	            return true;
	        }
	
	        public void onDestroyActionMode(ActionMode mode) {        	
	        	int tNumOfView = mSeedsViewsChosen.size();
	        	mLogger.debug("Destroying the action mode, list size:" + tNumOfView);
	        	for(int index=0; index<tNumOfView; index++)
	        	{
	        		mLogger.debug("Setting back the backgound");
	        		mSeedsViewsChosen.get(index).setBackgroundResource(R.drawable.seedslist_selector);
	        	    mSeedsViewsChosen.get(index).setPadding(8, 8, 8, 8);
	        	}
	        	mSeedsViewsChosen.clear();
	        	mSeedsEntityChosen.clear();
	        }
	
	        public void onItemCheckedStateChanged(ActionMode mode,
	            int position, long id, boolean checked) {
	        	View tItemSelected = mListView.getChildAt(position - mListView.getFirstVisiblePosition());
	        	if (checked)
	        	{
	        		mLogger.debug("Seeds added to list " + mSeedsEntityList.get(position).getSeedLocalId());
	        		mSeedsEntityChosen.add(mSeedsEntityList.get(position));
	        		mSeedsEntityChosenToDel.add(mSeedsEntityList.get(position));
	        		mSeedsViewsChosen.add(tItemSelected);
	        		tItemSelected.setBackgroundResource(R.drawable.seedsgradient_bg_hover);
	        	}
	        	else
	        	{
	        		mLogger.debug("Remove seeds " + mSeedsEntityList.get(position).getSeedLocalId());
	        		mSeedsEntityChosen.remove(mSeedsEntityList.get(position));
	        		mSeedsEntityChosenToDel.remove(mSeedsEntityList.get(position));
	        		mSeedsViewsChosen.remove(tItemSelected);
	        		tItemSelected.setBackgroundResource(R.drawable.seedslist_selector);
	        		tItemSelected.setPadding(8, 8, 8, 8);
	        	}
	            setSubtitle(mode);
	        }
	
	        private void setSubtitle(ActionMode mode) {
	            final int checkedCount = mListView.getCheckedItemCount();
	            switch (checkedCount) {
	            case 0:
	                mode.setSubtitle(null);
	                break;
	            case 1:
	                mode.setSubtitle(getString(R.string.seeds_list_contextualsubtitle1)
	                		       +"1"
	                		       +getString(R.string.seeds_list_contextualsubtitle2));
	                break;
	            default:
	                mode.setSubtitle(getString(R.string.seeds_list_contextualsubtitle1)
	                		        +checkedCount
	                		        +getString(R.string.seeds_list_contextualsubtitle2));
	                break;
	            }
	        }
		}	
		
		public class SeedsAdapter extends BaseAdapter {
	
			protected Activity activity;
			protected ArrayList<SeedsEntity> data;
			protected LayoutInflater inflater = null;		
	
			public SeedsAdapter(Activity a, ArrayList<SeedsEntity> d) {
				activity = a;
				data     = d;
				inflater = (LayoutInflater) activity.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			}
	
			public int getCount() {
				return data.size();
			}
	
			public Object getItem(int position) {
				return position;
			}
	
			public long getItemId(int position) {
				return position;
			}
	
			public View getView(int position, View convertView, ViewGroup parent) {
				View vi = convertView;
				String tFirstImgUrl;
				if (convertView == null)
					vi = inflater.inflate(R.layout.activity_seeds_listperday_row, null);							
					
				TextView title  = (TextView) vi.findViewById(R.id.seeds_title); 
				TextView size   = (TextView) vi.findViewById(R.id.seeds_size); 
				TextView format = (TextView) vi.findViewById(R.id.seeds_format);
				TextView mosaic = (TextView) vi.findViewById(R.id.seeds_mosaic);
				ImageView thumb_image = (ImageView) vi.findViewById(R.id.list_image);						
				
				thumb_image.setScaleType(ImageView.ScaleType.CENTER_CROP);
	
				SeedsEntity seedList = data.get(position);
				
				if(mSeedsEntityChosen.contains(seedList))
				{
					vi.setBackgroundResource(R.drawable.seedsgradient_bg_hover);
				}
				else
				{
					vi.setBackgroundResource(R.drawable.seedslist_selector);
					vi.setPadding(8, 8, 8, 8);
				}
	
				// Set the values for the list view
				title.setText(seedList.getSeedName());
				size.setText(seedList.getSeedSize()+" / "
					        +seedList.getPicLinks().size()
					        +getString(R.string.seeds_listperday_seedspics));
				format.setText(seedList.getSeedFormat());
				mosaic.setText((seedList.getSeedMosaic())
						       ? getString(R.string.seeds_listperday_withmosaic)
						       : getString(R.string.seeds_listperday_withoutmosaic));
				if(seedList.getSeedIsPicAvail())
					tFirstImgUrl = seedList.getPicLinks().get(0);
				else
					tFirstImgUrl = SeedsGlobalNOTECode.SEEDS_NOTE_NO_IMAGE;
				mImageFetcher.loadImage(tFirstImgUrl, thumb_image);
				mImageViewList.add(thumb_image);			

				return vi;
			}

		}
	}    
   
    public static class SeedsRSSCartIDMgt extends Fragment {
        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container,
                Bundle savedInstanceState) {
        	
            View rootView = inflater.inflate(R.layout.activity_seeds_rssid_management, container, false);            
    		    		
            Bundle args = getArguments();
            return rootView;
        	
        }    	
    }
}
