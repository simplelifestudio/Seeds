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

import com.simplelife.seeds.android.SeedsDefinitions;
import com.simplelife.seeds.android.utils.jsonprocess.SeedsJSONMessage;
import com.simplelife.seeds.android.utils.seedslogger.SeedsLoggerUtil;

public class SeedsNetworkProcess {
	
	private static String mServerUrl = "http://106.187.38.52:80/seeds/messageListener";
	
	// For log purpose
	private static SeedsLoggerUtil mLogger = SeedsLoggerUtil.getSeedsLogger();
	
	public SeedsNetworkProcess(){
		
	}
	
	public static String sendAlohaReqMsg() throws JSONException, ClientProtocolException, IOException {
		
        // Prepare network parameters
	    DefaultHttpClient httpClient = new DefaultHttpClient();
	    new BasicResponseHandler();
	    HttpPost postMethod = new HttpPost(mServerUrl);
	    
	    mLogger.info("Sending AlohaRequest Message!");
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
			String token = (String) result.get("id");  
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
	    postMethod.addHeader("Content-Type", "application/json");
	    
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
			String token = (String) result.get("id");  
		    Log.i("response :", token);	
		    
		    return token;
		}
		else
		{
			return null;
		}
	}

	
	public static HttpResponse sendUpdateStatusReqMsg(ArrayList<String> inDateArray) throws JSONException, ClientProtocolException, IOException {
		
		// Prepare network parameters
	    DefaultHttpClient httpClient = new DefaultHttpClient();
	    new BasicResponseHandler();
	    //HttpPost postMethod = new HttpPost(mServerUrl);
	    HttpPost postMethod = new HttpPost(SeedsDefinitions.getServerUrl());
	    postMethod.addHeader("Content-Type", "application/json");
	    mLogger.info("Sending UpdateStatus Message!");
		
	    // Create UpdateStatusReq Message
		JSONObject paramList = new JSONObject();
		JSONArray  dateList  = new JSONArray();
		int arraySize = inDateArray.size();
		for(int i =0 ; i < arraySize; i++)
		{
		    String tDate = inDateArray.get(i);
		    dateList.put(tDate);		    
		}
		paramList.put("dateList",dateList);
		
		JSONObject updateStatusReq = SeedsJSONMessage.SeedsConstructMsg(SeedsJSONMessage.UpdateStatusRequest, paramList);
		
	    // Send the request
		postMethod.setEntity(new StringEntity(updateStatusReq.toString()));		
		mLogger.debug("UpdateStatusReq Message "+updateStatusReq.toString());
		
		// Retrieve the response
		HttpResponse response = httpClient.execute(postMethod);
		
		return response;				
	}
	
	public static HttpResponse sendUpdateStatusReqMsg(String inDate) throws JSONException, ClientProtocolException, IOException {
		
		// Prepare network parameters
	    DefaultHttpClient httpClient = new DefaultHttpClient();
	    new BasicResponseHandler();
	    //HttpPost postMethod = new HttpPost(mServerUrl);
	    HttpPost postMethod = new HttpPost(SeedsDefinitions.getServerUrl());
	    postMethod.addHeader("Content-Type", "application/json");
	    mLogger.info("Sending UpdateStatus Message!");
		
	    // Create UpdateStatusReq Message
		JSONObject paramList = new JSONObject();
		JSONArray  dateList  = new JSONArray();
		dateList.put(inDate);		    
		paramList.put("dateList",dateList);
		
		JSONObject updateStatusReq = SeedsJSONMessage.SeedsConstructMsg(SeedsJSONMessage.UpdateStatusRequest, paramList);
		
	    // Send the request
		postMethod.setEntity(new StringEntity(updateStatusReq.toString()));		
		mLogger.debug("UpdateStatusReq Message "+updateStatusReq.toString());
		
		// Retrieve the response
		HttpResponse response = httpClient.execute(postMethod);
		
		return response;				
	}
	
	public static HttpResponse sendSeedsByDateReqMsg (ArrayList<String> inDateArray ) throws JSONException, ClientProtocolException, IOException {
        // Prepare network parameters
		DefaultHttpClient httpClient = new DefaultHttpClient();
	    //HttpPost postMethod = new HttpPost(mServerUrl);
		HttpPost postMethod = new HttpPost(SeedsDefinitions.getServerUrl());
		postMethod.addHeader("Content-Type", "application/json");
	    mLogger.info("Sending SeedsByDate Message!");
		
	    // Create UpdateStatusReq Message
		JSONObject paramList = new JSONObject();
		JSONArray  dateList  = new JSONArray();
		int arraySize = inDateArray.size();
		for(int i =0 ; i < arraySize; i++)
		{
		    String tDate = inDateArray.get(i);
		    dateList.put(tDate);		    
		}
		paramList.put("dateList",dateList);
		
		JSONObject updateStatusReq = SeedsJSONMessage.SeedsConstructMsg(SeedsJSONMessage.SeedsByDatesRequest, paramList);
		
	    // Send the request
		postMethod.setEntity(new StringEntity(updateStatusReq.toString()));
		
		Log.i("NetworkProcess","SeedsByDate Message "+updateStatusReq.toString());
		
		// Retrieve the response
		HttpResponse response = httpClient.execute(postMethod);
		
		return response;		
	}
	
	public static HttpResponse sendSeedsByDateReqMsg (String inDate) throws JSONException, ClientProtocolException, IOException {
        // Prepare network parameters
		DefaultHttpClient httpClient = new DefaultHttpClient();
	    //HttpPost postMethod = new HttpPost(mServerUrl);
		HttpPost postMethod = new HttpPost(SeedsDefinitions.getServerUrl());
		postMethod.addHeader("Content-Type", "application/json");
	    mLogger.info("Sending SeedsByDate Message!");
		
	    // Create UpdateStatusReq Message
		JSONObject paramList = new JSONObject();
		JSONArray  dateList  = new JSONArray();
		dateList.put(inDate);
		
		paramList.put("dateList",dateList);
		
		JSONObject updateStatusReq = SeedsJSONMessage.SeedsConstructMsg(SeedsJSONMessage.SeedsByDatesRequest, paramList);
		
	    // Send the request
		postMethod.setEntity(new StringEntity(updateStatusReq.toString()));
		
		mLogger.debug("SeedsByDate Message: "+updateStatusReq.toString());
		
		// Retrieve the response
		HttpResponse response = httpClient.execute(postMethod);
		
		return response;		
	}	

}
