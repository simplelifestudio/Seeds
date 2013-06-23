package com.simplelife.seeds.android.utils.jsonprocess;

import java.util.ArrayList;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.simplelife.seeds.android.SeedsEntity;
import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;

import android.util.Log;

public class SeedsJSONMessage {
	
	// Message Types between app and server
	public static String AlohaRequest  = "AlohaRequest";
	public static String AlohaResponse = "AlohaResponse";
	public static String UpdateStatusRequest  = "SeedsUpdateStatusByDatesRequest";
	public static String UpdateStatusRespons  = "SeedsUpdateStatusByDatesResponse";
	public static String SeedsByDatesRequest  = "SeedsByDatesRequest";
	public static String SeedsByDatesResponse = "SeedsByDatesResponse";
	
	public SeedsJSONMessage(){
		
	}
	
	public static JSONObject SeedsConstructMsg(String MsgType, JSONObject paramList){
		
		JSONObject SeedsMsg = new JSONObject();
		try {    		    
		    // Put in command and its value
			SeedsMsg.put("id", MsgType);
		    
		    if (paramList != null)
		    {
		        // Put in the paramList
		    	SeedsMsg.put("body",paramList);
		    }
		    		  
		} catch (JSONException ex) {    
		    throw new RuntimeException(ex);  
		}
		
		return SeedsMsg;	
	}
	
	public static HashMap<String, String> parseUpdateStatusRespMsg(ArrayList<String> inDateList, String inStringMsg) throws JSONException{
	
		HashMap<String, String> respMap = new HashMap<String, String>();		
		
		// Convert the String to JSON object
		JSONObject tMsgInJSON = new JSONObject(inStringMsg);  
		String msgType = (String) tMsgInJSON.get("id");
		Log.i("SeedsJSONMessage","Parsing msg " + msgType);
	    
		// Parse the paramList part
		JSONObject tParamList = tMsgInJSON.getJSONObject("body");
		int numOfDate = inDateList.size();
		for (int index = 0; index < numOfDate; index++)
		{
			Log.i("SeedsJSONMessage","Date: " + inDateList.get(index));
			Log.i("SeedsJSONMessage","Status: " + tParamList.getString(inDateList.get(index)));
			if (SeedsStatusByDate.isValidSeedsStatusByDate(tParamList.getString(inDateList.get(index))))
			{
				respMap.put(inDateList.get(index), tParamList.getString(inDateList.get(index)));
			}			
		}
		
		return respMap;
	}
	
	public static ArrayList<SeedsEntity> parseSeedsByDatesRespMsg(ArrayList<String> inDateList, String inStringMsg) throws JSONException{
		
		// Convert the String to JSON object
		JSONObject tMsgInJSON = new JSONObject(inStringMsg);  
		String msgType = (String) tMsgInJSON.get("id");
		Log.i("SeedsJSONMessage","Parsing msg " + msgType);
		
		// Prepare the return Seeds List
		ArrayList<SeedsEntity> retSeedsList = new ArrayList<SeedsEntity>();
				
		// Parse the paramList part
		JSONObject tParamList = tMsgInJSON.getJSONObject("body");
		int numOfDate = inDateList.size();
		for (int index = 0; index < numOfDate; index++)
		{
			String tDate = inDateList.get(index);
			Log.i("SeedsJSONMessage","Date to get: " + tDate);
			JSONArray tSeedsArray = tParamList.getJSONArray(tDate);
			
			int numOfSeeds = tSeedsArray.length();
			Log.i("SeedsJSONMessage","The size of the seedsArray is " + numOfSeeds);
			for (int index2 = 0; index2 < numOfSeeds; index2++)
			{
				// Construct single seed info
				JSONObject tSeedsInfo = tSeedsArray.optJSONObject(index2);
				SeedsEntity tSeedsEntity = new SeedsEntity();
				if (tSeedsInfo.has(SeedsDBAdapter.KEY_SEEDID))
					tSeedsEntity.setSeedId(tSeedsInfo.getInt(SeedsDBAdapter.KEY_SEEDID));
				if (tSeedsInfo.has(SeedsDBAdapter.KEY_TYPE))
					tSeedsEntity.setSeedType(tSeedsInfo.getString(SeedsDBAdapter.KEY_TYPE));
				if (tSeedsInfo.has(SeedsDBAdapter.KEY_SOURCE))
					tSeedsEntity.setSeedSource(tSeedsInfo.getString(SeedsDBAdapter.KEY_SOURCE));
				if (tSeedsInfo.has(SeedsDBAdapter.KEY_PUBLISHDATE))
					tSeedsEntity.setSeedPublishDate(tSeedsInfo.getString(SeedsDBAdapter.KEY_PUBLISHDATE));
				if (tSeedsInfo.has(SeedsDBAdapter.KEY_NAME))
					tSeedsEntity.setSeedName(tSeedsInfo.getString(SeedsDBAdapter.KEY_NAME));
				if (tSeedsInfo.has(SeedsDBAdapter.KEY_SIZE))
					tSeedsEntity.setSeedSize(tSeedsInfo.getString(SeedsDBAdapter.KEY_SIZE));
				if (tSeedsInfo.has(SeedsDBAdapter.KEY_FORMAT))
					tSeedsEntity.setSeedFormat(tSeedsInfo.getString(SeedsDBAdapter.KEY_FORMAT));
				if (tSeedsInfo.has(SeedsDBAdapter.KEY_TORRENTLINK))
					tSeedsEntity.setSeedTorrentLink(tSeedsInfo.getString(SeedsDBAdapter.KEY_TORRENTLINK));
				if (tSeedsInfo.has(SeedsDBAdapter.KEY_MOSAIC))
					tSeedsEntity.setSeedMosaic(tSeedsInfo.getString(SeedsDBAdapter.KEY_MOSAIC));
				
				tSeedsEntity.setSeedFavorite(false);
				// Parse picture links
				JSONArray tPicList  = tSeedsInfo.getJSONArray(SeedsDBAdapter.KEY_PICLINKS);
				int numOfPicLinks = tPicList.length();
				Log.i("SeedsJSONMessage","The size of the picArray is " + numOfPicLinks);
				for (int index3 = 0; index3 < numOfPicLinks; index3++)
				{
					Log.i("SeedsJSONMessage","Pic link: " + tPicList.getString(index3));
					tSeedsEntity.addPicLink(tPicList.getString(index3));
					Log.i("SeedsJSONMessage","Pic link parse done! ");
				}
				retSeedsList.add(tSeedsEntity);	
				
				// Temp solution to prevent too many seeds received
				if(retSeedsList.size() >= 100)
				{
					break;
				}
			}
		}
		
		return retSeedsList;		
	}
	
	public static class SeedsStatusByDate {
		
		// The three seeds status by date 
		public static String mReady = "READY";
		public static String mNotReady = "NOT_READY";
		public static String mNoUpdate = "NO_UPDATE";
		
		public SeedsStatusByDate(){
			
		}
		
		public static boolean isValidSeedsStatusByDate(String inStatus){
			if(inStatus.equals(mReady))
				return true;
			else if(inStatus.equals(mNotReady))
				return true;
			else if(inStatus.equals(mNoUpdate))
				return true;
			else
				// Report a error log here and a error number
				return false;
		}
		
		public static boolean isSeedsByDateReady(String inStatus){
			return inStatus.equals(mReady);
		}
		
		public static boolean isSeedsByDateNotReady(String inStatus){
			return inStatus.equals(mNotReady);
		}
		
		public static boolean isSeedsByDateNoUpdate(String inStatus){
			return inStatus.equals(mNoUpdate);
		}
		
	}

}
