/**
 * JsonRequestFactory.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.json;

import java.io.PrintWriter;

import net.sf.json.JSONObject;

import com.simplelife.seeds.server.util.ErrorCode;
import com.simplelife.seeds.server.util.JsonKey;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.OperationCode;
import com.simplelife.seeds.server.util.OperationLogUtil;

public class JsonRequestFactory {
	
	/**
	 * Factory of creating command objects bases on JSON object 
	 * @param out: PrintWriter for output, it's used to report error of invalid JSON object
	 * @param jsonObj: the JSON object created bases on JSON command string from client
	 * @param clientIp: IP address of client, used to save operation log
	 * @return created command object, or null for invalid JSON object
	 */
	public static IJsonRequest CreateJsonCommand(PrintWriter out, JSONObject jsonObj, String clientIp)
	{
	    IJsonRequest jsonCmd = null;
	    if (!jsonObj.containsKey(JsonKey.id))
        {
        	String err = "Illegal message: " + JsonKey.id +" can't be found.";
        	LogUtil.warning(err);
        	JsonRequestBase cmdBase = new JsonRequestBase(jsonObj, out);
			cmdBase.responseInvalidRequest(ErrorCode.IllegalMessage, err);
	        return null;
        }
	    
	    try
	    {
            String command = jsonObj.getString(JsonKey.id);

            LogUtil.info("Received command: " + command);
            if (command.equals(JsonKey.commandAlohaRequest))
            {
                jsonCmd = new JsonRequestAloha(jsonObj, out);
                OperationLogUtil.save(OperationCode.ALOHA_REQUEST, clientIp);
            }
            else if (command.equals(JsonKey.commandSeedsStatusRequest))
            {
                jsonCmd = new JsonRequestSeedsStatus(jsonObj, out);
                OperationLogUtil.save(OperationCode.USER_REQUEST_SEED_STATUS, clientIp);
            }
            else if (command.equals(JsonKey.commandSeedsByDatesRequest))
            {
                jsonCmd = new JsonRequestSeeds(jsonObj, out);
                OperationLogUtil.save(OperationCode.USER_REQUEST_SEED_INFO, clientIp);
            }
            else if (command.equals(JsonKey.commandSeedsToCartRequest))
            {
                jsonCmd = new JsonRequestSeedsToCart(jsonObj, out);
                OperationLogUtil.save(OperationCode.USER_REQUEST_SEED_RSS, clientIp);
            }
            else
            {
            	JsonRequestBase cmdBase = new JsonRequestBase(jsonObj, out);
    			cmdBase.responseInvalidRequest(ErrorCode.IllegalMessageId, "Illegal message id: " + command);
                OperationLogUtil.save(OperationCode.USER_REQUEST_INVALID, clientIp);
            }
	    }
	    catch(Exception e)
	    {
	    	JsonRequestBase cmdBase = new JsonRequestBase(jsonObj, out);
			cmdBase.responseInvalidRequest(ErrorCode.IllegalMessage, "Illegal message: " + e.getMessage());
	        LogUtil.printStackTrace(e);
	    }
		
		return jsonCmd;
	}
}
