package com.simplelife.seeds.server;

import java.io.PrintWriter;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

public class JsonCommandSeedsStatusReq extends JsonCommandBase {
	private final static String _jsonCommandKeyword = "command";
	private final static String _jsonParaListKeyword = "paramList";
	private final static String _jsonDateListKeyword = "datelist";
	private final static String _jsonCommandSeedsStatusRes = "SeedsUpdateStatusByDatesResponse";
	
	private Logger _logger = Logger.getLogger("JsonCommandSeedsStatusReq");
	
	@Override
	public void Execute(JSONObject jsonObj, PrintWriter out) {
		String strDateList = jsonObj.getString(_jsonParaListKeyword); 
		JSONObject dateObj = JSONObject.fromObject(strDateList);
		
		if (dateObj == null)
		{
			_logger.log(Level.SEVERE, "Invalid SeedsUpdateStatusByDatesRequest command received: " + jsonObj.toString());
			responseInvalidRequest(out);
			return;
		}
		
		JSONArray dateList = dateObj.getJSONArray(_jsonDateListKeyword);
		if (dateList == null || dateList.size() == 0)
		{
			_logger.log(Level.SEVERE, "Invalid SeedsUpdateStatusByDatesRequest command received: " + jsonObj.toString());
			responseInvalidRequest(out);
			return;	
		}
		
		responseNormalRequest(dateList, out);
		
	}
	
	private void responseNormalRequest(JSONArray dateList, PrintWriter out)
	{
		StringBuilder strBuilder = new StringBuilder();
		responseJsonHeader(strBuilder);
		
		String strDate;
		int size = dateList.size();
		for (int i = 0; i < size; i++)
		{
			strDate = dateList.getString(i);
			responseStatus(strDate, strBuilder, (i < size-1));
		}
		strBuilder.append("}\n}");
		
		out.write(strBuilder.toString());
	}
	private void responseInvalidRequest(PrintWriter out)
	{
		StringBuilder strBuilder = new StringBuilder();
		responseJsonHeader(strBuilder);
		strBuilder.append("}");
		
		out.write(strBuilder.toString());
	}
	
	
	private void responseJsonHeader(StringBuilder strBuilder)
	{
		strBuilder.append("{\n");
		strBuilder.append("\"");
		strBuilder.append(_jsonCommandKeyword);
		strBuilder.append("\":\"");
		strBuilder.append(_jsonCommandSeedsStatusRes);
		strBuilder.append("\",\n");
		
		strBuilder.append("\"");
		strBuilder.append(_jsonParaListKeyword);
		strBuilder.append("\":{");
	}
	
	private void responseStatus(String strDate, StringBuilder strBuilder, boolean lastOne)
	{
		strBuilder.append("\"");
		strBuilder.append(strDate);
		strBuilder.append("\":\"");
		strBuilder.append(getSeedsStatusByDate(strDate));
		strBuilder.append("\"");
		
		if (lastOne)
		{
			strBuilder.append(",");
		}
		strBuilder.append("\n");
	}
	
	private String getSeedsStatusByDate(String date)
	{
		return "NO_UPDATE";
	}
}
