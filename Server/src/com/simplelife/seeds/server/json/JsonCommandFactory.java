/**
 * JsonCommandFactory.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.json;

import javax.servlet.http.HttpServletRequest;

import com.simplelife.seeds.server.db.LogId;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.OperationLogUtil;

import net.sf.json.JSONObject;

public class JsonCommandFactory {
	private final static String _jsonCommandKeyword = "command";
	private final static String _jsonCommandAlohaReq = "AlohaRequest";
	private final static String _jsonCommandSeedsStatusReq = "SeedsUpdateStatusByDatesRequest";
	private final static String _jsonCommandSeedsByDatesReq = "SeedsByDatesRequest";
	
	public static IJsonCommand CreateJsonCommand(JSONObject jsonObj, HttpServletRequest request)
	{
		String command = jsonObj.getString(_jsonCommandKeyword);
		IJsonCommand jsonCmd = null;
		
		LogUtil.info("Received command: " + command);
		if (command.equals(_jsonCommandAlohaReq))
		{
			jsonCmd = new JsonCommandAlohaReq();
			OperationLogUtil.save(LogId.ALOHA_REQUEST, request.getLocalAddr());
		}
		else if (command.equals(_jsonCommandSeedsStatusReq))
		{
			jsonCmd = new JsonCommandSeedsStatusReq();
			OperationLogUtil.save(LogId.USER_REQUEST_SEED_STATUS, request.getLocalAddr());
		}
		else if (command.equals(_jsonCommandSeedsByDatesReq))
		{
			jsonCmd = new JsonCommandSeedsReq();
			OperationLogUtil.save(LogId.USER_REQUEST_SEED_INFO, request.getLocalAddr());
		}
		else
		{
			LogUtil.severe("Unkown command: " + command);
			OperationLogUtil.save(LogId.USER_REQUEST_INVALID, request.getLocalAddr());
		}
		
		return jsonCmd;
	}
}
