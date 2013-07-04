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
import com.simplelife.seeds.server.util.ErrorCode;
import com.simplelife.seeds.server.util.JsonKey;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.SqlUtil;
import com.simplelife.seeds.server.util.TableName;
import com.simplelife.seeds.server.util.DBExistResult;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

/**
 * 
 */
public class JsonCommandSeedsToCartReq extends JsonCommandBase
{
	/**
	 * Enum for saving result of adding seed to cart  
	 */
    enum SeedToCartResult
    {
        succeed,
        duplicated,
        invalid,
        failed
    }
    
    private String cartId;

    @Override
    public void Execute(JSONObject jsonObj, PrintWriter out)
    {
    	super.Execute(jsonObj, out);
    	
        try 
        {
            LogUtil.info("Start to Execute SeedsToCartRequest");
            String strParaList = jsonObj.getString(JsonKey.body);
            JSONObject paraObj = JSONObject.fromObject(strParaList);
            
            if (paraObj == null) 
            {
            	// Safe code, normally exception occurs if JsonKey.body can't be found or invalid
                String err = "Invalid Json format, " + JsonKey.body +" can't be found: " + jsonObj.toString();
                LogUtil.severe(err);
                responseInvalidRequest(ErrorCode.IllegalMessageBody, err);
                return;
            }

            cartId = paraObj.getString(JsonKey.cartId);
            if (cartId == null || cartId.length() == 0)
            {
            	// cartId is defined as empty, else will be catched by exception instead of here
                cartId = EncryptUtil.getRamdomCartId();
                LogUtil.info("Generated random cartId: " + cartId);
            }
            
            JSONArray seedList = paraObj.getJSONArray(JsonKey.seedIdList);
            if (seedList == null || seedList.size() == 0) 
            {
                String err = "Invalid Json format, " + JsonKey.seedIdList +" can't be found: " + jsonObj.toString();
                LogUtil.severe(err);
                responseInvalidRequest(ErrorCode.IllegalMessageBody, err);
                return;
            }

            responseNormalRequest(out, cartId, seedList);
        }
        catch (Exception e) 
        {
        	responseInvalidRequest(ErrorCode.IllegalMessageBody, e.getMessage());
            LogUtil.printStackTrace(e);
        }
    }

    /**
     * Generate response for valid request from client 
     * @param out: output stream for client
     * @param cartId: cart ID for client, it's given by client or generated randomly for first time 
     * @param seedList: seed list to be added into cart
     */
    private void responseNormalRequest(PrintWriter out, String cartId, JSONArray seedList)
    {
        StringBuilder strBuilder = new StringBuilder();
        responseJsonHeader(strBuilder);

        String strSeedId;
        int size = seedList.size();
        
        List<String> successList = new ArrayList<String>();
        List<String> failedList = new ArrayList<String>();
        SeedToCartResult result;
        
        for (int i = 0; i < size; i++)
        {
            strSeedId = seedList.getString(i);
            result = saveRssRequest(strSeedId, cartId, strBuilder);
            if (result == SeedToCartResult.succeed || result == SeedToCartResult.duplicated)
            {
                successList.add(strSeedId);
            }
            else if  (result == SeedToCartResult.failed)
            {
                // TODO: response failure to client
                failedList.add(strSeedId);
            }
            else
            {
                // TODO: response failure to client
                failedList.add(strSeedId);
            }
        }
        
        strBuilder.append("\"" + JsonKey.successSeedIdList + ":\":\n[\n");
        for (int i = 0; i < successList.size()-1; i++)
        {
            strBuilder.append("\"");
            strBuilder.append(successList.get(i));
            strBuilder.append("\",\n");
        }
        
        if (successList.size() >= 1)
        {
        	// It doesn't need to add ',' for last item
            strBuilder.append("\"");
            strBuilder.append(successList.get(successList.size() - 1));
            strBuilder.append("\"\n");
        }
        strBuilder.append("],\n");

        strBuilder.append("\"" + JsonKey.failedSeedIdList + ":\":\n[\n");
        for (int i = 0; i < failedList.size()-1; i++)
        {
            strBuilder.append("\"");
            strBuilder.append(failedList.get(i));
            strBuilder.append("\",\n");
        }
        
        if (failedList.size() >= 1)
        {
        	// It doesn't need to add ',' for last item
            strBuilder.append("\"");
            strBuilder.append(failedList.get(failedList.size() - 1));
            strBuilder.append("\"\n");
        }
        strBuilder.append("]\n}\n}\n");
        out.write(strBuilder.toString());
    }

    @Override
    protected void responseJsonHeader(StringBuilder strBuilder)
    {
        strBuilder.append("{\n");
        strBuilder.append("\"");
        strBuilder.append(JsonKey.id);
        strBuilder.append("\":\"");
        strBuilder.append(JsonKey.commandSeedsToCartResponse);
        strBuilder.append("\",\n");

        strBuilder.append("\"");
        strBuilder.append(JsonKey.body);
        strBuilder.append("\":{\n");
        
        strBuilder.append("\"");
        strBuilder.append(JsonKey.cartId);
        strBuilder.append("\":\"");
        strBuilder.append(cartId);
        strBuilder.append("\"\n");
    }

    private SeedToCartResult saveRssRequest(String seedId, String cartId, StringBuilder strBuilder)
    {
        String sql = "select " + SqlUtil.seedId + " from " + TableName.Seed + " where " + SqlUtil.seedId + " = " + seedId;
        // TODO: return SeedToCartResult.failed if result is  errorOccurred
        if (DaoWrapper.exists(sql) != DBExistResult.existent) {
            LogUtil.severe("Invalid seedId which can't be found in DB: " + seedId);
            return SeedToCartResult.invalid;
        }

        sql = "select " + SqlUtil.seedId + " from " + TableName.Cart + " where " + SqlUtil.cartId + " = '" + cartId + "' and " + SqlUtil.seedId +" = " + seedId;
        DBExistResult result = DaoWrapper.exists(sql);
        if (result == DBExistResult.existent) {
            LogUtil.warning("Duplicated request received, seed <" + seedId + "> has been subscribed by " + cartId);
            return SeedToCartResult.duplicated;
        }
        else if (result == DBExistResult.errorOccurred)
        {
            LogUtil.info("Abnormal DB status, schedule next task tomorrow.");
            return SeedToCartResult.failed;
        }

        sql = "Insert into " + TableName.Cart +"("+ SqlUtil.cartId + ", "+ SqlUtil.seedId +") " + "values ('" + cartId + "', " + seedId + ")";
        if (DaoWrapper.executeSql(sql))
        {
            LogUtil.info("Succeed to subscribe seed <" + seedId + "> for " + cartId);
            return SeedToCartResult.succeed;
        }
        else
        {
            return SeedToCartResult.failed;
        }
    }
}
