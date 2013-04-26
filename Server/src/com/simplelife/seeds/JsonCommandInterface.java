package com.simplelife.seeds;

import net.sf.json.JSONObject;
import java.io.PrintWriter;

public interface JsonCommandInterface {
	public void Execute(JSONObject jsonObj, PrintWriter out);
}
