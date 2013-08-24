package com.simplelife.seeds.android.utils.jsonprocess;

import java.util.ArrayList;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.simplelife.seeds.android.R;
import com.simplelife.seeds.android.SeedsDefinitions;
import com.simplelife.seeds.android.SeedsEntity;
import com.simplelife.seeds.android.SeedsRSSCartActivity;
import com.simplelife.seeds.android.SeedsRSSCartActivity.SeedsRSSList;
import com.simplelife.seeds.android.utils.dbprocess.SeedsDBAdapter;
import com.simplelife.seeds.android.utils.seedslogger.SeedsLoggerUtil;

import android.content.Context;
import android.util.Log;

public class SeedsJSONMessage {
	
	// Message Types between app and server
	public static String AlohaRequest  = "AlohaRequest";
	public static String AlohaResponse = "AlohaResponse";
	public static String UpdateStatusRequest  = "SeedsUpdateStatusByDatesRequest";
	public static String UpdateStatusRespons  = "SeedsUpdateStatusByDatesResponse";
	public static String SeedsByDatesRequest  = "SeedsByDatesRequest";
	public static String SeedsByDatesResponse = "SeedsByDatesResponse";
	public static String SeedsToCartRequest   = "SeedsToCartRequest";
	public static String SeedsToCartResponse  = "SeedsToCartResponse";
	
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
	
	public static HashMap<String, String> parseUpdateStatusRespMsg(String inDate, String inStringMsg) throws JSONException{
		
		HashMap<String, String> respMap = new HashMap<String, String>();		
		
		// Convert the String to JSON object
		JSONObject tMsgInJSON = new JSONObject(inStringMsg);  
		String msgType = (String) tMsgInJSON.get("id");
	    
		// Parse the paramList part
		JSONObject tParamList = tMsgInJSON.getJSONObject("body");

		if (SeedsStatusByDate.isValidSeedsStatusByDate(tParamList.getString(inDate)))
		{
			respMap.put(inDate, tParamList.getString(inDate));
		}					
		return respMap;
	}
	
	public static ArrayList<SeedsEntity> parseSeedsByDatesRespMsg(ArrayList<String> inDateList, String inStringMsg, Context inContext) throws JSONException{
		
		// Convert the String to JSON object
		JSONObject tMsgInJSON = new JSONObject(inStringMsg);  
		String msgType = (String) tMsgInJSON.get("id");
		Log.i("SeedsJSONMessage","Parsing msg " + msgType);
		Log.i("SeedsJSONMessage", inStringMsg);
		
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
				{
					if(isSeedsWithMosaic(inContext, tSeedsInfo.getString(SeedsDBAdapter.KEY_MOSAIC)))
						tSeedsEntity.setSeedMosaic(true);
					else
						tSeedsEntity.setSeedMosaic(false);
				}
				
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
	
	public static ArrayList<SeedsEntity> parseSeedsByDatesRespMsg(String inDate, String inStringMsg, Context inContext) throws JSONException{
		
		// Convert the String to JSON object
		JSONObject tMsgInJSON = new JSONObject(inStringMsg);  
		String msgType = (String) tMsgInJSON.get("id");
		
		// Prepare the return Seeds List
		ArrayList<SeedsEntity> retSeedsList = new ArrayList<SeedsEntity>();
				
		// Parse the paramList part
		JSONObject tParamList = tMsgInJSON.getJSONObject("body");

	    JSONArray tSeedsArray = tParamList.getJSONArray(inDate);
			
		int numOfSeeds = tSeedsArray.length();
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
			{
				if(isSeedsWithMosaic(inContext, tSeedsInfo.getString(SeedsDBAdapter.KEY_MOSAIC)))
					tSeedsEntity.setSeedMosaic(true);
				else
					tSeedsEntity.setSeedMosaic(false);
			}	
			tSeedsEntity.setSeedFavorite(false);
			// Parse picture links
			JSONArray tPicList  = tSeedsInfo.getJSONArray(SeedsDBAdapter.KEY_PICLINKS);
			int numOfPicLinks = tPicList.length();
			for (int index3 = 0; index3 < numOfPicLinks; index3++)
			{
				tSeedsEntity.addPicLink(tPicList.getString(index3));
			}
			retSeedsList.add(tSeedsEntity);	
				
			// Temp solution to prevent too many seeds received
			if(retSeedsList.size() >= 100)
			{
				break;
			}
		}
		
		return retSeedsList;		
	}
	
	public static boolean isSeedsWithMosaic(Context _inContext, String _inField){

		if((_inField.contains(_inContext.getString(R.string.seeds_listperday_nomosaictag1)))
		  ||
		  (_inField.contains(_inContext.getString(R.string.seeds_listperday_nomosaictag2))))
			return false;
		else
			return true;
	}
	
	public static void parseSeedsToCartRespMsg(String _inRespMsg) throws JSONException{
		
		ArrayList<Integer> tSuccSeedIdList = new ArrayList<Integer>();
		ArrayList<Integer> tExistSeedIdList = new ArrayList<Integer>();
		ArrayList<Integer> tFailedSeedIdList = new ArrayList<Integer>();
		
		JSONObject tMsgInJSON = new JSONObject(_inRespMsg);  
		String msgType = (String) tMsgInJSON.get("id");
	    
		// Parse the paramList part
		JSONObject tParamList = tMsgInJSON.getJSONObject("body");
		String tCartId = (String) tParamList.get("cartId");
		SeedsRSSList.setCartId(tCartId);
		JSONArray tSuccIdList   = tParamList.getJSONArray("successSeedIdList");
		JSONArray tExistIdList  = tParamList.getJSONArray("existSeedIdList");
		JSONArray tFailedIdList = tParamList.getJSONArray("failedSeedIdList");
		int numOfSuccId = tSuccIdList.length();
		for (int index = 0; index < numOfSuccId; index++)
		{
			tSuccSeedIdList.add(tSuccIdList.getInt(index));		
		}
		int numOfExistId = tExistIdList.length();
		for (int index = 0; index < numOfExistId; index++)
		{
			tExistSeedIdList.add(tExistIdList.getInt(index));		
		}
		int numOfFailedId = tFailedIdList.length();
		for (int index = 0; index < numOfFailedId; index++)
		{
			tFailedSeedIdList.add(tFailedIdList.getInt(index));		
		}
		
	}
	
	public static class SeedsStatusByDate {		
		
		public SeedsStatusByDate(){
			
		}
		
		public static boolean isValidSeedsStatusByDate(String inStatus){
			if(inStatus.equals(SeedsDefinitions.SEEDS_INFO_READY))
				return true;
			else if(inStatus.equals(SeedsDefinitions.SEEDS_INFO_NOTREADY))
				return true;
			else if(inStatus.equals(SeedsDefinitions.SEEDS_INFO_NOUPDATE))
				return true;
			else
				// Report a error log here and a error number
				return false;
		}
		
		public static boolean isSeedsByDateReady(String inStatus){
			return inStatus.equals(SeedsDefinitions.SEEDS_INFO_READY);
		}
		
		public static boolean isSeedsByDateNotReady(String inStatus){
			return inStatus.equals(SeedsDefinitions.SEEDS_INFO_NOTREADY);
		}
		
		public static boolean isSeedsByDateNoUpdate(String inStatus){
			return inStatus.equals(SeedsDefinitions.SEEDS_INFO_NOUPDATE);
		}
		
	}

}
