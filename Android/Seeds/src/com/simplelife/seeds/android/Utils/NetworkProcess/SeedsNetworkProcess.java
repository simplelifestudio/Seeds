package com.simplelife.seeds.android.utils.networkprocess;

import java.io.IOException;
import java.util.ArrayList;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

import com.simplelife.seeds.android.utils.jsonprocess.SeedsJSONMessage;

public class SeedsNetworkProcess {
	
	private static String mServerUrl = "http://106.187.38.52:80/seeds/messageListener";	
	
	public SeedsNetworkProcess(){
		
	}
	
	public static String sendAlohaReqMsg() throws JSONException, ClientProtocolException, IOException {
		
        // Prepare network parameters
	    DefaultHttpClient httpClient = new DefaultHttpClient();
	    new BasicResponseHandler();
	    HttpPost postMethod = new HttpPost(mServerUrl);
	    
		Log.i("NetworkProcess","Sending Aloha Message!");
	    // Create Aloha Message
		JSONObject paramList = new JSONObject();
		paramList.put("content","Hello Seeds Server!");
		
		JSONObject alohaReq = SeedsJSONMessage.SeedsConstructMsg(SeedsJSONMessage.AlohaRequest, paramList);
		
	    // Send the request
		postMethod.setEntity(new StringEntity(alohaReq.toString()));
		Log.i("NetworkProcess","Aloha Message "+alohaReq.toString());
		// Retrieve the response
		HttpResponse response = httpClient.execute(postMethod);
		
	    // Parse the response
		if (response.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
			String retSrc = EntityUtils.toString(response.getEntity());
			Log.i("return :", retSrc);
			JSONObject result = new JSONObject( retSrc);  
			String token = (String) result.get("command");  
		    Log.i("response :", token);	
		    
		    return token;
		}
		else
		{
			return null;
		}
	}

	public static String sendAlohaReqMsg(String _tgtUrl) throws JSONException, ClientProtocolException, IOException {
		
        // Prepare network parameters
	    DefaultHttpClient httpClient = new DefaultHttpClient();
	    new BasicResponseHandler();
	    HttpPost postMethod = new HttpPost(_tgtUrl);
	    
		Log.i("NetworkProcess","Sending Aloha Message to "+_tgtUrl);
	    // Create Aloha Message
		JSONObject paramList = new JSONObject();
		paramList.put("content","Hello Seeds Server!");
		
		JSONObject alohaReq = SeedsJSONMessage.SeedsConstructMsg(SeedsJSONMessage.AlohaRequest, paramList);
		
	    // Send the request
		postMethod.setEntity(new StringEntity(alohaReq.toString()));
		Log.i("NetworkProcess","Aloha Message "+alohaReq.toString());
		// Retrieve the response
		HttpResponse response = httpClient.execute(postMethod);
		
	    // Parse the response
		if (response.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
			String retSrc = EntityUtils.toString(response.getEntity());
			Log.i("return :", retSrc);
			JSONObject result = new JSONObject( retSrc);  
			String token = (String) result.get("command");  
		    Log.i("response :", token);	
		    
		    return token;
		}
		else
		{
			return null;
		}
	}

	
	public static String sendUpdateStatusReqMsg(ArrayList<String> inDateArray) throws JSONException, ClientProtocolException, IOException {
		
		// Prepare network parameters
	    DefaultHttpClient httpClient = new DefaultHttpClient();
	    new BasicResponseHandler();
	    HttpPost postMethod = new HttpPost(mServerUrl);
	    String respInString;
	    
		Log.i("NetworkProcess","Sending UpdateStatus Message!");
		
	    // Create UpdateStatusReq Message
		JSONObject paramList = new JSONObject();
		JSONArray  dateList  = new JSONArray();
		int arraySize = inDateArray.size();
		for(int i =0 ; i < arraySize; i++)
		{
		    String tDate = inDateArray.get(i);
		    dateList.put(tDate);		    
		}
		paramList.put("datelist",dateList);
		
		JSONObject updateStatusReq = SeedsJSONMessage.SeedsConstructMsg(SeedsJSONMessage.UpdateStatusRequest, paramList);
		
	    // Send the request
		postMethod.setEntity(new StringEntity(updateStatusReq.toString()));
		
		Log.i("NetworkProcess","UpdateStatusReq Message "+updateStatusReq.toString());
		
		// Retrieve the response
		HttpResponse response = httpClient.execute(postMethod);
		
        // Check the response context
		if (response.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
            
            respInString = EntityUtils.toString(response.getEntity());
            Log.i("NetworkProcess","Receive response msg: "+ respInString);
            return respInString;
            // String strsResult = strResult.replace("\r", "");            
        } else {
        	Log.i("NetworkProcess","UpdateStatusReq Message sending failed! Status Code: "+response.getStatusLine().getStatusCode());
        	return null;           
        }
		
	}
	
	public static String sendSeedsByDateReqMsg (ArrayList<String> inDateArray ) throws JSONException, ClientProtocolException, IOException {
        // Prepare network parameters
		DefaultHttpClient httpClient = new DefaultHttpClient();
	    HttpPost postMethod = new HttpPost(mServerUrl);
	    String respInString;
	    
		Log.i("NetworkProcess","Sending SeedsByDate Message!");
		
	    // Create UpdateStatusReq Message
		JSONObject paramList = new JSONObject();
		JSONArray  dateList  = new JSONArray();
		int arraySize = inDateArray.size();
		for(int i =0 ; i < arraySize; i++)
		{
		    String tDate = inDateArray.get(i);
		    dateList.put(tDate);		    
		}
		paramList.put("datelist",dateList);
		
		JSONObject updateStatusReq = SeedsJSONMessage.SeedsConstructMsg(SeedsJSONMessage.SeedsByDatesRequest, paramList);
		
	    // Send the request
		postMethod.setEntity(new StringEntity(updateStatusReq.toString()));
		
		Log.i("NetworkProcess","SeedsByDate Message "+updateStatusReq.toString());
		
		// Retrieve the response
		HttpResponse response = httpClient.execute(postMethod);
		
        // Check the response context
		if (response.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
            
            respInString = EntityUtils.toString(response.getEntity());
            return respInString;
            // String strsResult = strResult.replace("\r", "");            
        } else {
        	Log.i("NetworkProcess","SeedsByDate Message sending failed! Status Code: "+response.getStatusLine().getStatusCode());
        	return null;           
        }
	}	

}
