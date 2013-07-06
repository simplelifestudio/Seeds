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

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import com.simplelife.seeds.server.db.SeedCaptureLog;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.ErrorCode;
import com.simplelife.seeds.server.util.JsonKey;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.SqlUtil;

public class JsonCommandSeedsStatusReq extends JsonCommandBase
{

    @Override
    public void Execute(JSONObject jsonObj, PrintWriter out)
    {
    	super.Execute(jsonObj, out);
    	
        try {
            String strParaList = jsonObj.getString(JsonKey.body);
            JSONObject paraObj = JSONObject.fromObject(strParaList);

            if (paraObj == null) {
                String err = "Invalid Json format, " + JsonKey.body +" can't be found.";
                LogUtil.severe(err);
                responseInvalidRequest(ErrorCode.IllegalMessageBody, err);
                return;
            }

            JSONArray dateList = paraObj.getJSONArray(JsonKey.dateList);
            if (dateList == null || dateList.size() == 0) {
                String err = "Invalid Json format, " + JsonKey.dateList +" can't be found or maybe empty.";
                LogUtil.severe(err);
                responseInvalidRequest(ErrorCode.IllegalMessageBody, err);
                return;
            }

            responseNormalRequest(dateList, out);
        } catch (Exception e) {
        	responseInvalidRequest(ErrorCode.IllegalMessageBody, e.getMessage());
            LogUtil.printStackTrace(e);
        }
    }

    private void responseNormalRequest(JSONArray dateList, PrintWriter out)
    {
        StringBuilder strBuilder = new StringBuilder();
        responseJsonHeader(strBuilder);

        String strDate;
        int size = dateList.size();
        for (int i = 0; i < size; i++) {
            strDate = dateList.getString(i);
            if (!responseStatus(strDate, strBuilder, (i < size - 1), out))
            {
            	return;
            }
        }
        strBuilder.append("}\n}\n");

        LogUtil.info(strBuilder.toString());
        out.write(strBuilder.toString());
    }

    @Override
    protected void responseJsonHeader(StringBuilder strBuilder)
    {
        strBuilder.append("{\n");
        strBuilder.append("\"");
        strBuilder.append(JsonKey.id);
        strBuilder.append("\":\"");
        strBuilder.append(JsonKey.commandSeedsStatusResponse);
        strBuilder.append("\",\n");

        strBuilder.append("\"");
        strBuilder.append(JsonKey.body);
        strBuilder.append("\":\n{\n");
    }

    private boolean responseStatus(String strDate, StringBuilder strBuilder, boolean lastOne, PrintWriter out)
    {
        strBuilder.append("\"");
        strBuilder.append(strDate);
        strBuilder.append("\":\"");
        
        String result = getSeedsStatusByDate(strDate, out);
        if (result.equals(JsonKey.errorStatus))
        {
        	return false;
        }
        
        strBuilder.append(result);
        strBuilder.append("\"");

        if (lastOne) {
            strBuilder.append(",");
        }
        strBuilder.append("\n");
        return true;
    }

    private String getSeedsStatusByDate(String date, PrintWriter out)
    {
        String sql = SqlUtil.getSelectCaptureLogSql(SqlUtil.getPublishDateCondition(date));
        List record = DaoWrapper.query(sql, SeedCaptureLog.class);
        if (record == null)
        {
        	responseInvalidRequest(ErrorCode.DatabaseConnectionError, "Error occurred on database conection.");
            return JsonKey.errorStatus;
        }
            
        if (record.size() == 0) 
        {
            return JsonKey.noUpdate;
        }

        // It's order by id in descend, we only get the latest one
        try {
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
            	responseInvalidRequest(ErrorCode.AbnormalDataInDB, "Abnormal date in DB for seed capture status of " + date +": " + Long.toString(log.getStatus()));
                return JsonKey.errorStatus;
            }

        } catch (Exception e) {
        	responseInvalidRequest(ErrorCode.AbnormalDataInDB, "Abnormal date in DB for seed capture status of " + date + ".");
            LogUtil.printStackTrace(e);
        }

        return JsonKey.errorStatus;
    }
}
