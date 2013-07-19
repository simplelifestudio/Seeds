/**
 * IJsonRequest.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.json;

import net.sf.json.JSONObject;
import java.io.PrintWriter;

public interface IJsonRequest {
    /**
     * Interface of execute for all JSON request
     */
	public void Execute();
}
