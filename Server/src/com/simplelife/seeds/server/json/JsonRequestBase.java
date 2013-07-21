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
	
	/**
	 * Constructor
	 * @param jsonObj: Object of JSON command which will be executed
	 * @param out: PrintWriter for output, normally it's response for client
	 */
	public JsonRequestBase(	JSONObject jsonObj, PrintWriter out)
	{
	    jsonObject = jsonObj;
        outPrintWriter = out;
	}
	
	/**
	 * Function of executing JSON command, normally it shall be override by extended classes
	 */
	//@Override
	public void Execute() 
	{
	}
	
	/**
	 * As common part of checking JSON command for all extended classes
	 * @return True if JSON command is valid, otherwise return false.
	 */
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
	
	/**
	 * 
	 * @param intErrorCode
	 * @param strErrorDescription
	 */
	public void responseInvalidRequest(int intErrorCode, String strErrorDescription)
	{
	    JsonResponseBase response = new JsonResponseBase(jsonObject, outPrintWriter); 
        response.responseError(intErrorCode, strErrorDescription);
	}

}
