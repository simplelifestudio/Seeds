package com.simplelife.Seeds;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;

import com.simplelife.Seeds.Utils.Adapter.SeedsAdapter;
import com.simplelife.Seeds.Utils.DBProcess.SeedsDBManager;

public class SeedsListPerDayActivity extends Activity {

	// Let us define some parameters here
	//public static final String KEY_SONG = "song"; // parent node
	//public static final String KEY_ID = "id";
	public static final String KEY_TITLE  = "name";
	public static final String KEY_SIZE   = "size";
	public static final String KEY_FORMAT = "format";
	public static final String KEY_THUMB_URL = "thumb_url";

	private ListView tListView;
	private SeedsAdapter tAdapter;
	protected String tDate;
	protected String tFirstImgUrl;
	protected int tSeedId;
	protected List<Integer> tSeedIdList;
	
	// For log purpose
	private static final String LOGCLASS = "SeedsListPerDay"; 
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		// setTheme(android.R.style.Theme_Translucent_NoTitleBar);
		// Set the list view layout
		setContentView(R.layout.activity_seeds_listperday);
		
		// Retrieve the date info parameter
		Bundle bundle = getIntent().getExtras();
		String tPassinDate = bundle.getString("date");
		
		// Initialize the tSeedIdList
		tSeedIdList = new ArrayList();
		
		Log.i(LOGCLASS, "Working on ListPerDay, passin "+ tPassinDate); 
	    // Judge the current time
		Calendar tCal = Calendar.getInstance();
		if(tPassinDate.equals("befyesterday"))
		{
			// A simple calculation
			tCal.add(Calendar.DATE, -2);
			tDate = new SimpleDateFormat("yyyy-MM-dd").format(tCal.getTime());			
		}else if(tPassinDate.equals("yesterday"))
		{
			tCal.add(Calendar.DATE, -1);
			tDate = new SimpleDateFormat("yyyy-MM-dd").format(tCal.getTime());			
		}else
		{
			tDate = new SimpleDateFormat("yyyy-MM-dd").format(tCal.getTime());
		}
		Log.i(LOGCLASS, "The Date is  "+ tDate); 
		// Start a new thread to get the data
		new Thread(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				Message msg = new Message();
				msg.what = 0;
				
				// Retrieve the seeds list
				msg.obj = getList();
				handler.sendMessage(msg);
			}
		}).start();		
	}
	
	private Handler handler = new Handler(){
		public void handleMessage(Message msg) {
			switch(msg.what){
			case 0 :
				tListView = (ListView)findViewById(R.id.seeds_list);
				
				ArrayList<HashMap<String, String>> seedsList = (ArrayList<HashMap<String, String>>)msg.obj;
				tAdapter = new SeedsAdapter(SeedsListPerDayActivity.this, seedsList);
				tListView.setAdapter(tAdapter);

				// Bund the click listener
				tListView.setOnItemClickListener(new ListViewItemOnClickListener());
				break;
			}
		}
	};
	
	class ListViewItemOnClickListener implements OnItemClickListener {
		@Override
		public void onItemClick(AdapterView<?> parent, View view,
				int position, long id) {
			
			//System.out.println("----->OnClick");
			// TODO:Redirect to the details page
			Intent intent = new Intent(SeedsListPerDayActivity.this, SeedsDetailsActivity.class);
			// Pass the date info
		    Bundle bundle = new Bundle();
		    
		    Log.i(LOGCLASS,"Click event detected, the position is "+position);
		    Log.i(LOGCLASS,"Click event detected, the seedId is "+tSeedIdList.get(position));
		    bundle.putInt("seedid", (Integer) tSeedIdList.get(position));
		    intent.putExtras(bundle);
			startActivity(intent);
		}
	}

	private ArrayList<HashMap<String, String>> getList() {
		ArrayList<HashMap<String, String>> seedsList = new ArrayList<HashMap<String, String>>();

		// Retrieve the DB process handler to get data 
		SeedsDBManager mDBHandler = SeedsDBManager.getManager();
		
		// Put a warning info here in case the DBHandler is null
		SQLiteDatabase tDB = mDBHandler.getDatabase("Seeds_App_Database.db"); 
		
		Log.i(LOGCLASS, "DB instance retrieved, query now");
		// Query the database
		// NOTE: Modify here if the format of publishDate field in db is not string
		/*Cursor tResult = tDB.rawQuery(
				"select seedId,name,size,format,torrentLink from Seed where publishDate=\"?\"",
				new String[]{tDate});*/
		
		tDate = "2013-04-26";
		Cursor tResult = tDB.rawQuery(
				"select seedId,name,size,format,torrentLink from Seed where publishDate=?",
				new String[]{tDate});
				
		/*Cursor tResult = tDB.rawQuery(
				"select name,size,format,torrentLink from Seed",
				null);*/
				
		Log.i(LOGCLASS, "The size of the tResult is  "+ tResult.getCount());
		tResult.moveToFirst(); 
		while (!tResult.isAfterLast()) 
	    { 
			// 0 -- seedId, 1 -- name
			// 2 -- size,   3 -- format
	    	// 4 -- torrentLink (info)
			// First: using the key seedId to query the url link of imgs
			HashMap<String, String> map = new HashMap<String, String>();
			tSeedId = tResult.getInt(tResult.getColumnIndex("seedId"));
			
			// For debug purpose
			Log.i(LOGCLASS, "The SeedID is  "+ tSeedId);
			Log.i(LOGCLASS, "The Title is  "+ tResult.getString(tResult.getColumnIndex(KEY_TITLE)));
			
			Cursor tImgResult = tDB.rawQuery(
					"select pictureLink from SeedPicture where seedId=?",
					new String[]{Integer.toString(tSeedId)});
			
			tImgResult.moveToFirst();
			// Think twice if we really need a while loop here
			if(!tImgResult.isAfterLast())
			{
				// Always get the first image
				tFirstImgUrl = tImgResult.getString(tImgResult.getColumnIndex("pictureLink"));												
			}
			else
			{
				// No resource for this seed
				tFirstImgUrl = "Nothing To Show";
			}

			Log.i(LOGCLASS, "The Image URL is  "+ tFirstImgUrl);
			map.put(KEY_TITLE, tResult.getString(tResult.getColumnIndex(KEY_TITLE)));
			map.put(KEY_SIZE, tResult.getString(tResult.getColumnIndex(KEY_SIZE)));
			map.put(KEY_FORMAT, tResult.getString(tResult.getColumnIndex(KEY_FORMAT)));
			map.put(KEY_THUMB_URL, tFirstImgUrl);
			
			// Add the instance into the array
			seedsList.add(map);
			
			// Record the seedId info
			tSeedIdList.add(tSeedId);
			
			// Move to the next result
	        tResult.moveToNext(); 
	        	       
	    }
		
	    tResult.close(); 
		
		return seedsList;	
	}
		
}
