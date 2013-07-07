/**
 * JsonUtil.java
 * 
 * History:
 *     2013-6-12: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.util;

import net.sf.json.JSONObject;

/**
 * 
 */
public class JsonUtil {
	/**
	 * Check if JSON command from client is valid, including if it matches
	 * format of JSON
	 * 
	 * @param command
	 *            : string of command
	 * @return: null if it's invalid JSON command, else, return constructed JSON
	 *          object
	 */
	public static JSONObject createJsonObject(String command) {
		if (command.length() == 0) {
			return null;
		}

		if (command.indexOf("{") == -1) {
			return null;
		}

		JSONObject jsonObj = null;
		try {
			jsonObj = JSONObject.fromObject(command);
		} catch (Exception e) {
			//LogUtil.severe( "Error occurred when try to decode JSON command from client: " + e.getMessage());
			LogUtil.printStackTrace(e);
			return null;
		}

		return jsonObj;
	}
}
