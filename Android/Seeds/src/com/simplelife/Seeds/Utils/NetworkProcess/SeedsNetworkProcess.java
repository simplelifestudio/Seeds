package com.simplelife.Seeds.Utils.NetworkProcess;

import java.io.IOException;

import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ByteArrayEntity;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

import com.simplelife.Seeds.Utils.JSONProcess.SeedsJSONMessage;

public class SeedsNetworkProcess {
	
	public SeedsNetworkProcess(){
		
	}
	
	public void sendAlohaReqMsg() throws JSONException, ClientProtocolException, IOException {
		
        // Prepare network parameters
	    DefaultHttpClient httpClient = new DefaultHttpClient();
	    ResponseHandler <String> resonseHandler = new BasicResponseHandler();
	    HttpPost postMethod = new HttpPost("http://xxxxxxxxxxxxxxxxxxxxx");
	    
		// Create Aloha Message
		JSONObject alohaReq = SeedsJSONMessage.SeedsConstructMsg(SeedsJSONMessage.AlohaRequest, null);
		
	    // Send the request
		postMethod.setEntity(new ByteArrayEntity(alohaReq.toString().getBytes("UTF8")));
	    
		// Retrieve the response
		String response = httpClient.execute(postMethod,resonseHandler);
	    Log.e("response :", response);
	    
	    // Parse the response
		
	}

}
