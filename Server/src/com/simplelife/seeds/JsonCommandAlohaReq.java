package com.simplelife.seeds;

import java.io.PrintWriter;
import net.sf.json.JSONObject;

public class JsonCommandAlohaReq extends JsonCommandBase {
	@Override
	public void Execute(JSONObject jsonObj, PrintWriter out) {
		out.println("output of Aloha!!");
	}
}
