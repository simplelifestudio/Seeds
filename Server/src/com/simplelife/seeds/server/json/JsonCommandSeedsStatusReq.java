/**
 * JsonCommandSeedsStatusReq.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.json;

import java.io.PrintWriter;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.simplelife.seeds.server.db.DaoWrapper;
import com.simplelife.seeds.server.db.SeedCaptureLog;
import com.simplelife.seeds.server.util.LogUtil;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

public class JsonCommandSeedsStatusReq extends JsonCommandBase {
	private final String _noUpdate = "NO_UPDATE";
	private final String _notReady = "NOT_READY";
	private final String _ready = "READY";
	
	private final static String _jsonCommandKeyword = "command";
	private final static String _jsonParaListKeyword = "paramList";
	private final static String _jsonDateListKeyword = "datelist";
	private final static String _jsonCommandSeedsStatusRes = "SeedsUpdateStatusByDatesResponse";
	
	
	@Override
	public void Execute(JSONObject jsonObj, PrintWriter out) {
		String strDateList = jsonObj.getString(_jsonParaListKeyword); 
		JSONObject dateObj = JSONObject.fromObject(strDateList);
		
		if (dateObj == null)
		{
			LogUtil.severe("Invalid SeedsUpdateStatusByDatesRequest command received: " + jsonObj.toString());
			responseInvalidRequest(out);
			return;
		}
		
		JSONArray dateList = dateObj.getJSONArray(_jsonDateListKeyword);
		if (dateList == null || dateList.size() == 0)
		{
			LogUtil.severe("Invalid SeedsUpdateStatusByDatesRequest command received: " + jsonObj.toString());
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
		
		LogUtil.info(strBuilder.toString());
		out.write(strBuilder.toString());
	}
	private void responseInvalidRequest(PrintWriter out)
	{
		StringBuilder strBuilder = new StringBuilder();
		responseJsonHeader(strBuilder);
		strBuilder.append("}");
		
		LogUtil.info(strBuilder.toString());
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
		strBuilder.append("\":{\n");
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
	    String sql = "select * from SeedCaptureLog where publishDate ='" + date + "' order by id desc";
        List record = DaoWrapper.query(sql, SeedCaptureLog.class);
        
        if (record.size() == 0)
        {
        	return _noUpdate;
        }
        
        // It's order by id in descend, we only get the latest one
        try
        {
        	SeedCaptureLog log = (SeedCaptureLog) record.get(0);
        	if (log.getStatus() == 1)
        	{
        		return _notReady;
        	}
        	else if (log.getStatus() == 2)
        	{
        		return _ready;
        	}
        	else
        	{
        		return "ERROR_STATUS";
        	}
        		
        }
        catch(Exception e)
        {
        	//LogUtil.severe("Error occurred when converting seed capture log: " + e.getMessage());
        	LogUtil.printStackTrace(e);
        }
        
        return "ERROR_STATUS";
	}
}
