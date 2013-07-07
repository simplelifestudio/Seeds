/**
 * JsonRequestSeedsStatus.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.json;

import java.io.PrintWriter;
import java.util.List;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import com.simplelife.seeds.server.db.SeedCaptureLog;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.ErrorCode;
import com.simplelife.seeds.server.util.JsonKey;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.SqlUtil;

public class JsonRequestSeedsStatus extends JsonRequestBase
{
	/**
     * @param jsonObj
     * @param out
     */
    public JsonRequestSeedsStatus(JSONObject jsonObj, PrintWriter out)
    {
        super(jsonObj, out);
    }

    @Override
	protected boolean CheckJsonCommand()
    {
		LogUtil.info("Start to check JSON command\n");
		if (jsonObject == null || outPrintWriter == null)
		{
			return false;
		}
		
		if (!super.CheckJsonCommand())
		{
			return false;
		}
		
		// JsonKey.body is checked in JsonRequestBase
		JSONObject paraObj = jsonObject.getJSONObject(JsonKey.body);
        if (!paraObj.containsKey(JsonKey.dateList)) {
            String err = "Illegal message body: " + JsonKey.dateList +" can't be found.";
            LogUtil.warning(err + jsonObject.toString());
            responseInvalidRequest(ErrorCode.IllegalMessageBody, err);
            return false;
        }
        
        String strDateList = paraObj.getString(JsonKey.dateList);
        if (strDateList.length() <= 2)
        {
        	String err = "Illegal message body: " + JsonKey.dateList +" is empty.";
            LogUtil.warning(err + jsonObject.toString());
            responseInvalidRequest(ErrorCode.IllegalMessageBody, err);
            return false;
        }
        
        LogUtil.info("JSON command is valid.\n");
	    return true;
    }
	
    @Override
    public void Execute()
    {
    	super.Execute();
    	
        try {
        	if (!CheckJsonCommand())
            {
            	return;
            }
            
        	JSONObject paraObj = jsonObject.getJSONObject(JsonKey.body);
            JSONArray dateList = paraObj.getJSONArray(JsonKey.dateList);
            
            JsonResponseSeedsStatus response = new JsonResponseSeedsStatus(jsonObject, outPrintWriter);
            response.setDateList(dateList);
            response.responseNormalRequest();
        } catch (Exception e) {
        	responseInvalidRequest(ErrorCode.IllegalMessageBody, e.getMessage());
            LogUtil.printStackTrace(e);
        }
    }

    
}
