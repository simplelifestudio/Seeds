/**
 * JsonCommandAlohaReq.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.json;

import java.io.PrintWriter;
import net.sf.json.JSONObject;
import com.simplelife.seeds.server.util.DateUtil;
import com.simplelife.seeds.server.util.LogUtil;

public class JsonCommandAlohaReq extends JsonCommandBase {
	
	@Override
	public void Execute(JSONObject jsonObj, PrintWriter out) {
		
		String res ="{\"command\": \"AlohaResponse\", \"paramList\": {\"content\":\"Hello Seeds App![";
		res += DateUtil.getNowDate().toString();
		res +="]\"}}";
		out.println(res);
		LogUtil.info("Aloha response: \n" + res);
	}
}
