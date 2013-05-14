package com.simplelife.seeds.server;

import net.sf.json.JSONObject;
import java.io.PrintWriter;

public interface IJsonCommand {
	public void Execute(JSONObject jsonObj, PrintWriter out);
}
