/**
 * JsonResponseSeedsStatus.java 
 * 
 * History:
 *     2013-7-5: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */
package com.simplelife.seeds.server.json;

import java.io.PrintWriter;
import java.util.Hashtable;
import java.util.List;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import com.simplelife.seeds.server.db.SeedCaptureLog;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.ErrorCode;
import com.simplelife.seeds.server.util.JsonKey;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.SqlUtil;

/**
 * 
 */
public class JsonResponseSeedsStatus extends JsonResponseBase
{
    protected JSONArray dateList;
    
	/**
     * @return the dateList
     */
    public JSONArray getDateList()
    {
        return dateList;
    }

    /**
     * @param dateList the dateList to set
     */
    public void setDateList(JSONArray dateList)
    {
        this.dateList = dateList;
    }

	/**
	 * Constructor
	 * @param jsonObj: Object of JSON command which will be executed
	 * @param out: PrintWriter for output, normally it's response for client
	 */
    public JsonResponseSeedsStatus(JSONObject jsonObj, PrintWriter out)
	{
	    super(jsonObj, out);
		addHeader(JsonKey.commandSeedsStatusResponse);
	}
	
    /**
     * Normal response for client
     */
	public void responseNormalRequest()
    {
	    if (dateList == null)
        {
            LogUtil.severe("Null dateList in responseNormalRequest.");
        }
	    
        int size = dateList.size();
        String result;
        String strDate;
        for (int i = 0; i < size; i++) {
        	strDate = dateList.getString(i);
        	result = getSeedsStatusByDate(strDate);
            if (result.equals(JsonKey.errorStatus))
            {
            	// Error response has been reported in getSeedsStatusByDate
                return;
            }
            
            body.put(strDate, result);
        }
        outPrintWriter.write(toString());
        LogUtil.info("Response SeedsUpdateStatusByDatesRequest successfully: " + dateList.toString());
    }

	/**
	 * Return status of seeds capture for given date
	 * @param date: string of date
	 * @return status of seed capture
	 */
    private String getSeedsStatusByDate(String date)
    {
    	//responseError(ErrorCode.DatabaseConnectionError, "Error occurred on database conection.");
    	//return JsonKey.errorStatus;
    	
        String sql = SqlUtil.getSelectCaptureLogSql(SqlUtil.getPublishDateCondition(date));
        List record = DaoWrapper.query(sql, SeedCaptureLog.class);
        if (record == null)
        {
            responseError(ErrorCode.DatabaseConnectionError, "Error occurred on database conection.");
            return JsonKey.errorStatus;
        }
            
        if (record.size() == 0) 
        {
            return JsonKey.noUpdate;
        }

        // It's order by id in descend, we only get the latest one
        try 
        {
            SeedCaptureLog log = (SeedCaptureLog) record.get(0);
            if (log.getStatus() == 0) {
                return JsonKey.notReady;
            }
            if (log.getStatus() == 1) {
                return JsonKey.noUpdate;
            }
            else if (log.getStatus() == 2) {
                return JsonKey.ready;
            }
            else {
                responseError(ErrorCode.AbnormalDataInDB, "Abnormal date in DB for seed capture status of " + date +": " + Long.toString(log.getStatus()));
                return JsonKey.errorStatus;
            }
        }
        catch (Exception e) {
            responseError(ErrorCode.AbnormalDataInDB, "Abnormal date in DB for seed capture status of " + date + ".");
            LogUtil.printStackTrace(e);
        }

        return JsonKey.errorStatus;
    }
}
