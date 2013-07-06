/**
 * JsonCommandBase.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.json;

import java.io.PrintWriter;

import com.simplelife.seeds.server.util.JsonKey;

import net.sf.json.JSONObject;

public class JsonCommandBase implements IJsonCommand 
{
	protected JSONObject jsonObject;
	protected PrintWriter outPrintWriter;
	
	@Override
	public void Execute(JSONObject jsonObj, PrintWriter out) 
	{
		jsonObject = jsonObj;
		outPrintWriter = out;
	}
	
	public void responseInvalidRequest(int intErrorCode, String strErrorDescription, String strRequestMessage, PrintWriter out)
	{
		if (out == null)
		{
			return;
		}
		
		strErrorDescription = strErrorDescription.replace("\"", "");
		strErrorDescription = strErrorDescription.replace("json", "");
		strErrorDescription = strErrorDescription.replace("JSON", "");
		
		strRequestMessage = strRequestMessage.replace("\"", "");

		StringBuilder strBuilder = new StringBuilder();
        addErrorResponseHeader(strBuilder);
        strBuilder.append("\"");
        
        strBuilder.append(JsonKey.requestMessage);
        strBuilder.append("\":\"");
        strBuilder.append(strRequestMessage);
        strBuilder.append("\",\n");
        
        strBuilder.append("\"");
        strBuilder.append(JsonKey.errorCode);
        strBuilder.append("\":\"");
        strBuilder.append(Integer.toString(intErrorCode));
        strBuilder.append("\",\n");
        
        strBuilder.append("\"");
        strBuilder.append(JsonKey.errorDescription);
        strBuilder.append("\":\"");
        strBuilder.append(strErrorDescription);
        strBuilder.append("\"\n");
        
        strBuilder.append("}\n}\n");
        out.write(strBuilder.toString());
	}
	
	public void responseInvalidRequest(int intErrorCode, String strErrorDescription, JSONObject jsonObj, PrintWriter out)
	{
		responseInvalidRequest(intErrorCode, strErrorDescription, jsonObj.toString(), out);
	}
	
	public void responseInvalidRequest(int intErrorCode, String strErrorDescription)
	{
		responseInvalidRequest(intErrorCode, strErrorDescription, jsonObject, outPrintWriter);
	}
	
	protected void addErrorResponseHeader(StringBuilder strBuilder)
	{
	    strBuilder.append("{\n");
        strBuilder.append("\"");
        strBuilder.append(JsonKey.id);
        strBuilder.append("\":\"");
        strBuilder.append(JsonKey.errorResponse);
        strBuilder.append("\",\n");

        strBuilder.append("\"");
        strBuilder.append(JsonKey.body);
        strBuilder.append("\":\n{\n");
	}
	
	
	protected void responseJsonHeader(StringBuilder strBuilder)
	{
	    strBuilder.append("This is invalid responseJsonHeader in JsonCommandBase");
	}

}
