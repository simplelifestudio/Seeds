package com.simplelife.seeds.android.Utils.JSONProcess;

import org.json.JSONException;
import org.json.JSONObject;

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
			SeedsMsg.put("command", MsgType);
		    
		    if (paramList != null)
		    {
		        // Put in the paramList
		    	SeedsMsg.put("paramList",paramList);
		    }
		    		  
		} catch (JSONException ex) {    
		    throw new RuntimeException(ex);  
		}
		
		return SeedsMsg;	
	}
	

}