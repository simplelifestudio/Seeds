/**
 * JsonCommandFactory.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.json;

import net.sf.json.JSONObject;
import com.simplelife.seeds.server.db.LogId;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.OperationLogUtil;

public class JsonCommandFactory {
	private final static String jsonCommandKeyword = "command";
	private final static String jsonCommandAlohaReq = "AlohaRequest";
	private final static String jsonCommandSeedsStatusReq = "SeedsUpdateStatusByDatesRequest";
	private final static String jsonCommandSeedsByDatesReq = "SeedsByDatesRequest";
	private final static String jsonCommandSeedsToCartRequest = "SeedsToCartRequest";
	
	
	public static IJsonCommand CreateJsonCommand(JSONObject jsonObj, String clientIp)
	{
		String command = jsonObj.getString(jsonCommandKeyword);
		IJsonCommand jsonCmd = null;
		
		LogUtil.info("Received command: " + command);
		if (command.equals(jsonCommandAlohaReq))
		{
			jsonCmd = new JsonCommandAlohaReq();
			OperationLogUtil.save(LogId.ALOHA_REQUEST, clientIp);
		}
		else if (command.equals(jsonCommandSeedsStatusReq))
		{
			jsonCmd = new JsonCommandSeedsStatusReq();
			OperationLogUtil.save(LogId.USER_REQUEST_SEED_STATUS, clientIp);
		}
		else if (command.equals(jsonCommandSeedsByDatesReq))
		{
			jsonCmd = new JsonCommandSeedsReq();
			OperationLogUtil.save(LogId.USER_REQUEST_SEED_INFO, clientIp);
		}
		else if (command.equals(jsonCommandSeedsToCartRequest))
		{
			jsonCmd = new JsonCommandSeedsToCartReq();
			OperationLogUtil.save(LogId.USER_REQUEST_SEED_RSS, clientIp);
		}
		else
		{
			LogUtil.severe("Unkown command: " + command);
			OperationLogUtil.save(LogId.USER_REQUEST_INVALID, clientIp);
		}
		
		return jsonCmd;
	}
}
