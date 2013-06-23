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
import com.simplelife.seeds.server.util.LogUtil;

public class JsonCommandSeedsStatusReq extends JsonCommandBase
{
    private final String noUpdate = "NO_UPDATE";
    private final String notReady = "NOT_READY";
    private final String ready = "READY";

    private final static String jsonCommandKeyword = "command";
    private final static String jsonParaListKeyword = "paramList";
    private final static String jsonDateListKeyword = "dateList";
    private final static String jsonCommandSeedsStatusRes = "SeedsUpdateStatusByDatesResponse";

    @Override
    public void Execute(JSONObject jsonObj, PrintWriter out)
    {
        try {
            String strParaList = jsonObj.getString(jsonParaListKeyword);
            JSONObject paraObj = JSONObject.fromObject(strParaList);

            if (paraObj == null) {
                LogUtil.severe("Invalid SeedsUpdateStatusByDatesRequest command received: " + jsonObj.toString());
                responseInvalidRequest(out);
                return;
            }

            JSONArray dateList = paraObj.getJSONArray(jsonDateListKeyword);
            if (dateList == null || dateList.size() == 0) {
                LogUtil.severe("Invalid SeedsUpdateStatusByDatesRequest command received: " + jsonObj.toString());
                responseInvalidRequest(out);
                return;
            }

            responseNormalRequest(dateList, out);
        } catch (Exception e) {
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
            responseStatus(strDate, strBuilder, (i < size - 1));
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
        strBuilder.append(jsonCommandKeyword);
        strBuilder.append("\":\"");
        strBuilder.append(jsonCommandSeedsStatusRes);
        strBuilder.append("\",\n");

        strBuilder.append("\"");
        strBuilder.append(jsonParaListKeyword);
        strBuilder.append("\":{\n");
    }

    private void responseStatus(String strDate, StringBuilder strBuilder, boolean lastOne)
    {
        strBuilder.append("\"");
        strBuilder.append(strDate);
        strBuilder.append("\":\"");
        strBuilder.append(getSeedsStatusByDate(strDate));
        strBuilder.append("\"");

        if (lastOne) {
            strBuilder.append(",");
        }
        strBuilder.append("\n");
    }

    private String getSeedsStatusByDate(String date)
    {
        String sql = "select * from SeedCaptureLog where publishDate ='" + date + "' order by id desc";
        List record = DaoWrapper.query(sql, SeedCaptureLog.class);

        if (record.size() == 0) {
            return noUpdate;
        }

        // It's order by id in descend, we only get the latest one
        try {
            SeedCaptureLog log = (SeedCaptureLog) record.get(0);
            if (log.getStatus() == 0) {
            	return notReady;
            }
            if (log.getStatus() == 1) {
                return noUpdate;
            }
            else if (log.getStatus() == 2) {
                return ready;
            }
            else {
                return "ERROR_STATUS";
            }

        } catch (Exception e) {
            // LogUtil.severe("Error occurred when converting seed capture log: "
            // + e.getMessage());
            LogUtil.printStackTrace(e);
        }

        return "ERROR_STATUS";
    }
}
