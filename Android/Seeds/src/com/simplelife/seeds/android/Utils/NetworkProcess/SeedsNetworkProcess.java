package com.simplelife.seeds.android.Utils.NetworkProcess;

import java.io.IOException;
import java.util.ArrayList;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ByteArrayEntity;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

import com.simplelife.seeds.android.Utils.JSONProcess.SeedsJSONMessage;

public class SeedsNetworkProcess {
	
	private static String mServerUrl = "http://192.168.1.104:8080/Seeds/messageListener";
	
	public SeedsNetworkProcess(){
		
	}
	
	public static void sendAlohaReqMsg() throws JSONException, ClientProtocolException, IOException {
		
        // Prepare network parameters
	    DefaultHttpClient httpClient = new DefaultHttpClient();
	    ResponseHandler <String> resonseHandler = new BasicResponseHandler();
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
		String retSrc = EntityUtils.toString(response.getEntity());
		Log.i("return :", retSrc);
		JSONObject result = new JSONObject( retSrc);  
		String token = (String) result.get("command");  
	    Log.i("response :", token);	
	}
	
	public static void sendUpdateStatusReqMsg(ArrayList<String> inDateArray) throws JSONException, ClientProtocolException, IOException {
		
        // Prepare network parameters
	    DefaultHttpClient httpClient = new DefaultHttpClient();
	    ResponseHandler <String> resonseHandler = new BasicResponseHandler();
	    HttpPost postMethod = new HttpPost(mServerUrl);
	    
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
		
	}

}
