/**
 * JsonResponseBase.java 
 * 
 * History:
 *     2013-7-5: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */
package com.simplelife.seeds.server.json;

import java.io.PrintWriter;
import java.util.Hashtable;

import net.sf.json.JSONObject;

import com.simplelife.seeds.server.util.JsonKey;
import com.simplelife.seeds.server.util.LogUtil;

/**
 * 
 */
public class JsonResponseBase implements IJsonResponse
{
	protected Hashtable<String, Object> response = new Hashtable<String, Object>();
	protected Hashtable<String, Object> body = new Hashtable<String, Object>();
	
	protected JSONObject jsonObject;
    protected PrintWriter outPrintWriter;

	public JsonResponseBase(JSONObject jsonObj, PrintWriter out)
	{
	    jsonObject = jsonObj;
        outPrintWriter = out;
	}
	
	protected void addHeader(String responseName)
    {
		if (response.containsKey(JsonKey.id))
		{
			return;
		}
		
		response.put(JsonKey.id, responseName);
		response.put(JsonKey.body, body);
    }
	
	public void responseError(int intErrorCode, String strErrorDescription, String strRequestMessage, PrintWriter out)
    {
        if (out == null)
        {
            LogUtil.severe("Null out PrintWriter found.");
            return;
        }
        
        addHeader(JsonKey.errorResponse);
        
        strErrorDescription = strErrorDescription.replace("\"", "");
        strErrorDescription = strErrorDescription.replace("json", "");
        strErrorDescription = strErrorDescription.replace("JSON", "");
        
        strRequestMessage = strRequestMessage.replace("\"", "");

        body.put(JsonKey.requestMessage, strRequestMessage);
        body.put(JsonKey.errorCode, Integer.toString(intErrorCode));
        body.put(JsonKey.errorDescription, strErrorDescription);
        
        out.write(toString());
    }
    
	@Override
    public void responseError(int intErrorCode, String strErrorDescription)
    {
	    String jsonRequest = "";
	    if (jsonObject != null)
	    {
	        jsonRequest = jsonObject.toString();
	    }
	    
	    responseError(intErrorCode, strErrorDescription, jsonRequest, outPrintWriter);
    }

    /* 
     * 
     */
    @Override
    public void responseNormalRequest()
    {
        
    }
    
    @Override
    public String toString()
    {
        JSONObject obj = JSONObject.fromObject(response);
        return obj.toString();
    }


}
