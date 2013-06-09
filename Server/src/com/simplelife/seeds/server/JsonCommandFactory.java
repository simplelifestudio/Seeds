package com.simplelife.seeds.server;

import java.util.logging.Level;
import java.util.logging.Logger;

import net.sf.json.JSONObject;

public class JsonCommandFactory {
	private static Logger _logger = Logger.getLogger("JsonCommandFactory");
	
	private final static String _jsonCommandKeyword = "command";
	private final static String _jsonCommandAlohaReq = "AlohaRequest";
	private final static String _jsonCommandSeedsStatusReq = "SeedsUpdateStatusByDatesRequest";
	private final static String _jsonCommandSeedsByDatesReq = "SeedsByDatesRequest";
	
	public static IJsonCommand CreateJsonCommand(JSONObject jsonObj)
	{
		String command = jsonObj.getString(_jsonCommandKeyword);
		IJsonCommand jsonCmd = null;
		
		_logger.log(Level.INFO, "Received command: " + command);
		if (command.equals(_jsonCommandAlohaReq))
		{
			jsonCmd = new JsonCommandAlohaReq();
		}
		else if (command.equals(_jsonCommandSeedsStatusReq))
		{
			jsonCmd = new JsonCommandSeedsStatusReq();
		}
		else if (command.equals(_jsonCommandSeedsByDatesReq))
		{
			jsonCmd = new JsonCommandSeedsReq();
		}
		else
		{
			_logger.log(Level.SEVERE, "Unkown command: " + command);
		}
		
		return jsonCmd;
	}
}
