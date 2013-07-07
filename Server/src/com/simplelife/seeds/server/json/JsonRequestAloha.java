/**
 * JsonRequestAloha.java 
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

public class JsonRequestAloha extends JsonRequestBase {
	
	/**
     * @param jsonObj
     * @param out
     */
    public JsonRequestAloha(JSONObject jsonObj, PrintWriter out)
    {
        super(jsonObj, out);
    }

    @Override
	public void Execute() {
		
		String res ="{\"id\": \"AlohaResponse\",\"body\": {\"content\":\"Hello Seeds App! <";
		res += DateUtil.getNow();
		res +=">\"}}";
		outPrintWriter.println(res);
		LogUtil.info("Aloha response: \n" + res);
	}
}
