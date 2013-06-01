package com.simplelife.seeds.server;

import java.io.PrintWriter;
import java.util.logging.Level;
import java.util.logging.Logger;

import net.sf.json.JSONObject;

public class JsonCommandAlohaReq extends JsonCommandBase {
	private Logger logger = Logger.getLogger("HtmlParser");
	
	@Override
	public void Execute(JSONObject jsonObj, PrintWriter out) {
		
		String res ="{\"command\": \"AlohaResponse\", \"paramList\": {\"content\":\"Hello Seeds App![";
		res += DateUtil.getNowDate().toString();
		res +="]\"}}";
		out.println(res);
		logger.log(Level.INFO, "Aloha response: \n" + res);
	}
}
