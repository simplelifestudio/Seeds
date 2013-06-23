/**
 * JsonCommandSeedsRssReq.java
 * 
 * History:
 *     2013-6-12: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.json;

import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.EncryptUtil;
import com.simplelife.seeds.server.util.LogUtil;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

/**
 * 
 */
public class JsonCommandSeedsToCartReq extends JsonCommandBase
{
    enum SeedToCartResult
    {
        succeed,
        duplicated,
        invalid,
        failed
    }
    
    private final static String jsonCommandKeyword = "command";
    private final static String jsonParaListKeyword = "paramList";
    private final static String jsonSeedIdListKeyword = "seedIdList";
    private final static String jsonCartIdKeyword = "cartId";
    private final static String jsonCommandSeedsToCartRes = "SeedsToCartResponse";

    @Override
    public void Execute(JSONObject jsonObj, PrintWriter out)
    {
        try {
            LogUtil.info("Start to Execute JsonCommandSeedsRssReq");
            String strParaList = jsonObj.getString(jsonParaListKeyword);
            JSONObject paraObj = JSONObject.fromObject(strParaList);

            if (paraObj == null) {
                LogUtil.severe("Invalid SeedsUpdateStatusByDatesRequest command received: " + jsonObj.toString());
                responseInvalidRequest(out, "");
                return;
            }

            String cartId = paraObj.getString(jsonCartIdKeyword);
            if (cartId == null || cartId.length() == 0)
            {
                cartId = EncryptUtil.getRamdomCartId();
            }
            
            JSONArray seedList = paraObj.getJSONArray(jsonSeedIdListKeyword);
            if (seedList == null || seedList.size() == 0) {
                LogUtil.severe("Invalid SeedsUpdateStatusByDatesRequest command received: " + jsonObj.toString());
                responseInvalidRequest(out, cartId);
                return;
            }

            responseNormalRequest(out, cartId, seedList);
        } catch (Exception e) {
            LogUtil.printStackTrace(e);
        }
    }

    private void responseInvalidRequest(PrintWriter out, String cartId)
    {
        StringBuilder strBuilder = new StringBuilder();
        responseJsonHeader(strBuilder, cartId);

        strBuilder.append("\"result\":\"Invalid Request\"\n");
        strBuilder.append("}");

        LogUtil.info(strBuilder.toString());
        out.write(strBuilder.toString());
    }

    private void responseNormalRequest(PrintWriter out, String cartId, JSONArray seedList)
    {
        StringBuilder strBuilder = new StringBuilder();
        responseJsonHeader(strBuilder, cartId);

        String strSeedId;
        int size = seedList.size();
        
        List<String> successList = new ArrayList<String>();
        List<String> failedList = new ArrayList<String>();
        SeedToCartResult result;
        
        for (int i = 0; i < size; i++) {
            strSeedId = seedList.getString(i);
            result = saveRssRequest(strSeedId, cartId, strBuilder);
            
            if (result == SeedToCartResult.succeed || result == SeedToCartResult.duplicated)
            {
                successList.add(strSeedId);
            }
            else
            {
                failedList.add(strSeedId);
            }
        }
        
        strBuilder.append("\"successSeedIdList:\":[\n");
        for (int i = 0; i < successList.size()-1; i++)
        {
            strBuilder.append("\"");
            strBuilder.append(successList.get(i));
            strBuilder.append("\",\n");
        }
        
        if (successList.size() >= 1)
        {
            strBuilder.append("\"");
            strBuilder.append(successList.get(successList.size() - 1));
            strBuilder.append("\"\n");
        }
        strBuilder.append("],\n");

        strBuilder.append("\"failedSeedIdList:\":[\n");
        for (int i = 0; i < failedList.size()-1; i++)
        {
            strBuilder.append("\"");
            strBuilder.append(failedList.get(i));
            strBuilder.append("\",\n");
        }
        
        if (failedList.size() >= 1)
        {
            strBuilder.append("\"");
            strBuilder.append(failedList.get(failedList.size() - 1));
            strBuilder.append("\"\n");
        }
        strBuilder.append("]\n");
        strBuilder.append("}\n");
        out.write(strBuilder.toString());
    }

    private void responseJsonHeader(StringBuilder strBuilder, String cartId)
    {
        strBuilder.append("{\n");
        strBuilder.append("\"");
        strBuilder.append(jsonCommandKeyword);
        strBuilder.append("\":\"");
        strBuilder.append(jsonCommandSeedsToCartRes);
        strBuilder.append("\",\n");

        strBuilder.append("\"");
        strBuilder.append(jsonParaListKeyword);
        strBuilder.append("\":{\n");
        
        strBuilder.append("\"");
        strBuilder.append(jsonCartIdKeyword);
        strBuilder.append("\":\"");
        strBuilder.append(cartId);
        strBuilder.append("\"\n");
    }

    private SeedToCartResult saveRssRequest(String seedId, String cartId, StringBuilder strBuilder)
    {
        String sql = "select seedId from Seed where seedId = " + seedId;
        if (!DaoWrapper.exists(sql)) {
            LogUtil.severe("Invalid seedId which can't be found in DB: " + seedId);
            return SeedToCartResult.invalid;
        }

        sql = "select seedId from SeedSubscribe where userName = '" + cartId + "' and seedId = " + seedId;
        if (DaoWrapper.exists(sql)) {
            LogUtil.warning("Duplicated request received, seed <" + seedId + "> has been subscribed by " + cartId);
            return SeedToCartResult.duplicated;
        }

        sql = "Insert into SeedSubscribe (userName, seedId) " + "values ('" + cartId + "', " + seedId + ")";
        if (DaoWrapper.executeSql(sql)) {
            return SeedToCartResult.succeed;
        } else {
            return SeedToCartResult.failed;
        }
    }
}
