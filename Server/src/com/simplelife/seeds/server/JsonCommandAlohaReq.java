package com.simplelife.seeds.server;

import java.io.PrintWriter;
import net.sf.json.JSONObject;

public class JsonCommandAlohaReq extends JsonCommandBase {
	@Override
	public void Execute(JSONObject jsonObj, PrintWriter out) {
		String res ="{\"command\": \"AlohaResponse\", \"paramList\": {\"content\":\"Hello Seeds App![";
		res += DateUtil.getNowDate().toString();
		res +="]\"}}";
		out.println(res);
	}
}
