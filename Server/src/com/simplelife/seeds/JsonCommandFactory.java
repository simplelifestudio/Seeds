package com.simplelife.seeds;

import net.sf.json.JSONObject;

public class JsonCommandFactory {
	private final static String _jsonCommandKeyword = "command";
	private final static String _jsonParaListKeyword = "paramList";

	private final static String _jsonCommandAlohaReq = "AlohaRequest";
	private final static String _jsonCommandAlohaRes = "AlohaResponse";
	private final static String _jsonCommandSeedsStatusReq = "SeedsUpdateStatusByDatesRequest";
	private final static String _jsonCommandSeedsStatusRes = "SeedsUpdateStatusByDatesResponse";
	private final static String _jsonCommandSeedsByDatesReq = "SeedsByDatesRequest";
	private final static String _jsonCommandSeedsByDatesRes = "SeedsByDatesResponse";
	
	public static JsonCommandInterface CreateJsonCommand(JSONObject jsonObj)
	{
		String command = jsonObj.getString(_jsonCommandKeyword);
		JsonCommandInterface jsonCmd = null;
		if (command == _jsonCommandAlohaReq)
		{
			jsonCmd = new JsonCommandAlohaReq();
		}
		
		return jsonCmd;
	}
}
