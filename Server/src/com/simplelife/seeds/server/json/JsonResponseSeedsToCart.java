/**
 * JsonResponseSeedsToCart.java
 * 
 * History:
 *     2013-7-6: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.json;

import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import com.simplelife.seeds.server.json.JsonRequestSeedsToCart.SeedToCartResult;
import com.simplelife.seeds.server.util.DBExistResult;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.DateUtil;
import com.simplelife.seeds.server.util.ErrorCode;
import com.simplelife.seeds.server.util.JsonKey;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.TableColumnName;
import com.simplelife.seeds.server.util.TableName;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

/**
 * 
 */
public class JsonResponseSeedsToCart extends JsonResponseBase
{
    private JSONArray seedList; 
    private String cartId;
    
    /**
     * @return the cartId
     */
    public String getCartId()
    {
        return cartId;
    }

    /**
     * @param cartId the cartId to set
     */
    public void setCartId(String cartId)
    {
        this.cartId = cartId;
    }

    /**
     * @return the seedList
     */
    public JSONArray getSeedList()
    {
        return seedList;
    }

    /**
     * @param seedList the seedList to set
     */
    public void setSeedList(JSONArray seedList)
    {
        this.seedList = seedList;
    }

    /**
     * @param jsonObj
     * @param out
     */
    public JsonResponseSeedsToCart(JSONObject jsonObj, PrintWriter out)
    {
        super(jsonObj, out);
        addHeader(JsonKey.commandSeedsToCartResponse);
    }
    
    /**
     * Generate response for valid request from client 
     * @param out: output stream for client
     * @param cartId: cart ID for client, it's given by client or generated randomly for first time 
     * @param seedList: seed list to be added into cart
     */
    @Override
    public void responseNormalRequest()
    {
        if (seedList == null || seedList.size() == 0)
        {
        	List<String> successList = new ArrayList<String>();
            body.put(JsonKey.cartId, this.cartId);
            body.put(JsonKey.successSeedIdList, successList);
            body.put(JsonKey.failedSeedIdList, successList);
            outPrintWriter.write(toString());
            return;
        }
        
        String strSeedId;
        int size = seedList.size();
        
        List<String> successList = new ArrayList<String>();
        List<String> failedList = new ArrayList<String>();
        SeedToCartResult result = null;
        
        for (int i = 0; i < size; i++)
        {
            strSeedId = seedList.getString(i);
            result = saveRssRequest(strSeedId, cartId);
            if (result == SeedToCartResult.succeed || result == SeedToCartResult.duplicated)
            {
                successList.add(strSeedId);
            }
            else if  (result == SeedToCartResult.failed)
            {
                failedList.add(strSeedId);
            }
            else
            {
                failedList.add(strSeedId);
            }
        }
        
        if ((successList.size() == 0) && (result == SeedToCartResult.failed))
        {
        	// If all seedId failed, change response from JsonResponseSeedsToCart to ErrorResponse
        	response.remove(JsonKey.id);
            responseError(ErrorCode.DatabaseConnectionError, "Unknown error on DB connection.");
            return;
        }
        
        body.put(JsonKey.cartId, this.cartId);
        body.put(JsonKey.successSeedIdList, successList);
        body.put(JsonKey.failedSeedIdList, failedList);
        outPrintWriter.write(toString());
    }

    private SeedToCartResult saveRssRequest(String seedId, String cartId)
    {
        String sql = "select " + TableColumnName.seedId + " from " + TableName.Seed + " where " + TableColumnName.seedId + " = " + seedId;
        DBExistResult result = DaoWrapper.exists(sql);
        
        if (result == DBExistResult.errorOccurred)
        {
            LogUtil.severe("Error on DB connection.");
            return SeedToCartResult.failed;
        }
        
        if (result != DBExistResult.existent) {
            LogUtil.severe("Invalid seedId which can't be found in DB: " + seedId);
            return SeedToCartResult.invalid;
        }

        sql = "select " + TableColumnName.seedId + " from " + TableName.Cart + " where " + TableColumnName.cartId + " = '" + cartId + "' and " + TableColumnName.seedId +" = " + seedId;
        result = DaoWrapper.exists(sql);
        if (result == DBExistResult.existent) {
            LogUtil.warning("Duplicated request received, seed <" + seedId + "> has been subscribed by " + cartId);
            sql = "update "  + TableName.Cart  
                    + " set " + TableColumnName.date + " = '" + DateUtil.getToday() + "' where "
                    + TableColumnName.cartId + " = '" + cartId + "' and "
                    + TableColumnName.seedId + " = " + seedId+ "";
            DaoWrapper.executeSql(sql);
            return SeedToCartResult.duplicated;
        }
        else if (result == DBExistResult.errorOccurred)
        {
            LogUtil.info("Abnormal DB status, check DB setting.");
            return SeedToCartResult.failed;
        }

        sql = "Insert into " + TableName.Cart 
                +"("+ TableColumnName.cartId + ", " + TableColumnName.seedId  + ", " + TableColumnName.date +") "
                + "values ('" + cartId + "', " + seedId + ",'" + DateUtil.getToday() + "')";
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
