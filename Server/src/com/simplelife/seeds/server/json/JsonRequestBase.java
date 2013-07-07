/**
 * JsonRequestBase.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.json;

import java.io.PrintWriter;

import com.simplelife.seeds.server.util.ErrorCode;
import com.simplelife.seeds.server.util.JsonKey;
import com.simplelife.seeds.server.util.LogUtil;

import net.sf.json.JSONObject;

public class JsonRequestBase implements IJsonRequest 
{
	protected JSONObject jsonObject;
	protected PrintWriter outPrintWriter;
	
	public JsonRequestBase(	JSONObject jsonObj, PrintWriter out)
	{
	    jsonObject = jsonObj;
        outPrintWriter = out;
	}
	
	//@Override
	public void Execute() 
	{
	}
	
	protected boolean CheckJsonCommand()
	{
    	if (!jsonObject.containsKey(JsonKey.body))
        {
        	String err = "Illegal message: " + JsonKey.body +" can't be found.";
            LogUtil.warning(err + jsonObject.toString());
            
            responseInvalidRequest(ErrorCode.IllegalMessageBody, err);
            return false;
        }
        
		return true;
    }
	
	public void responseInvalidRequest(int intErrorCode, String strErrorDescription)
	{
	    JsonResponseBase response = new JsonResponseBase(jsonObject, outPrintWriter); 
        response.responseError(intErrorCode, strErrorDescription);
	}

}
