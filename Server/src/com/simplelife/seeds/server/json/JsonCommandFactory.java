/**
 * JsonCommandFactory.java 
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

public class JsonCommandFactory {
	
	
	public static IJsonCommand CreateJsonCommand(PrintWriter out, JSONObject jsonObj, String clientIp)
	{
	    IJsonCommand jsonCmd = null;
	    try
	    {
            String command = jsonObj.getString(JsonKey.id);

            LogUtil.info("Received command: " + command);
            if (command.equals(JsonKey.commandAlohaRequest))
            {
                jsonCmd = new JsonCommandAlohaReq();
                OperationLogUtil.save(OperationCode.ALOHA_REQUEST, clientIp);
            }
            else if (command.equals(JsonKey.commandSeedsStatusRequest))
            {
                jsonCmd = new JsonCommandSeedsStatusReq();
                OperationLogUtil.save(OperationCode.USER_REQUEST_SEED_STATUS, clientIp);
            }
            else if (command.equals(JsonKey.commandSeedsByDatesRequest))
            {
                jsonCmd = new JsonCommandSeedsReq();
                OperationLogUtil.save(OperationCode.USER_REQUEST_SEED_INFO, clientIp);
            }
            else if (command.equals(JsonKey.commandSeedsToCartRequest))
            {
                jsonCmd = new JsonCommandSeedsToCartReq();
                OperationLogUtil.save(OperationCode.USER_REQUEST_SEED_RSS, clientIp);
            }
            else
            {
            	JsonCommandBase cmdBase = new JsonCommandBase();
    			cmdBase.responseInvalidRequest(ErrorCode.IllegalMessageId, "Illegal message id: " + command, jsonObj, out);
                OperationLogUtil.save(OperationCode.USER_REQUEST_INVALID, clientIp);
            }
	    }
	    catch(Exception e)
	    {
	    	JsonCommandBase cmdBase = new JsonCommandBase();
			cmdBase.responseInvalidRequest(ErrorCode.IllegalMessage, "Illegal message: " + e.getMessage(), jsonObj, out);
	        LogUtil.printStackTrace(e);
	    }
		
		return jsonCmd;
	}
}
