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
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import com.simplelife.seeds.server.util.DBExistResult;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.EncryptUtil;
import com.simplelife.seeds.server.util.ErrorCode;
import com.simplelife.seeds.server.util.JsonKey;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.TableColumnName;
import com.simplelife.seeds.server.util.TableName;

/**
 * 
 */
public class JsonRequestSeedsToCart extends JsonRequestBase
{
	/**
     * @param jsonObj
     * @param out
     */
    public JsonRequestSeedsToCart(JSONObject jsonObj, PrintWriter out)
    {
        super(jsonObj, out);
    }

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
    
    /**
     * Check validation of JSON command
     */
    @Override
	protected boolean CheckJsonCommand()
    {
		LogUtil.info("Start to check JSON command\n");
		if (jsonObject == null || outPrintWriter == null)
		{
			return false;
		}
		
		if (!super.CheckJsonCommand())
		{
			return false;
		}
		
		// JsonKey.body is checked in JsonRequestBase
		JSONObject paraObj = jsonObject.getJSONObject(JsonKey.body);
		
		if (paraObj.containsKey(JsonKey.cartId))
        {
            String cartId = paraObj.getString(JsonKey.cartId);
            if (cartId.length() > 32)
            {
                String err = JsonKey.cartId + " is too long, the max length is 32.";
                LogUtil.warning(err + jsonObject.toString());
                responseInvalidRequest(ErrorCode.IllegalMessageBody, err);
                return false;
            }
        }
		
		if (!paraObj.containsKey(JsonKey.seedIdList)) {
            String err = "Illegal message body: " + JsonKey.seedIdList +" can't be found.";
            LogUtil.warning(err + jsonObject.toString());
            responseInvalidRequest(ErrorCode.IllegalMessageBody, err);
            return false;
        }
		
		// Check seedId must be digital
		JSONArray seedList = paraObj.getJSONArray(JsonKey.seedIdList);
		int size = seedList.size();
		String strSeedId;
		for (int i = 0; i < size; i++)
		{
			strSeedId = seedList.getString(i).trim();
			if (!strSeedId.matches("^[-+]?(([0-9]+)([.]([0-9]+))?|([.]([0-9]+))?)$"))
			{
				String err = "Invalid seedId found: " + strSeedId;
	            LogUtil.warning(err + jsonObject.toString());
	            responseInvalidRequest(ErrorCode.IllegalMessageBody, err);
	            return false;
			}
			if (strSeedId.length() == 0)
			{
				String err = "Empty seedId found in: " + seedList.toString();
	            LogUtil.warning(err + jsonObject.toString());
	            responseInvalidRequest(ErrorCode.IllegalMessageBody, err);
	            return false;
			}
		}
		
        LogUtil.info("JSON command is valid.\n");
	    return true;
    }
    
    /**
     * Function of executing JSON command
     */
    @Override
    public void Execute()
    {
    	super.Execute();
    	
        try 
        {
            LogUtil.info("Start to Execute SeedsToCartRequest");
            
            if (!CheckJsonCommand())
            {
            	return;
            }
            
            JSONObject paraObj = jsonObject.getJSONObject(JsonKey.body);
            String cartId;
            
            if (paraObj.containsKey(JsonKey.cartId))
            {
                cartId = paraObj.getString(JsonKey.cartId);
            }
            else
            {
            	cartId = null;
            }
            
            if (cartId == null || cartId.length() == 0)
            {
            	cartId = EncryptUtil.getRamdomCartId();
                LogUtil.info("Generated random cartId: " + cartId);
            }
            
            JsonResponseSeedsToCart response = new JsonResponseSeedsToCart(jsonObject, outPrintWriter);
            response.setCartId(cartId);
            
            if (paraObj.getString(JsonKey.seedIdList).length() <=2)
            {
            	response.setSeedList(null);
            }
            else
            {
            	JSONArray seedList = paraObj.getJSONArray(JsonKey.seedIdList);
            	response.setSeedList(seedList);
            }
            
            response.responseNormalRequest();
        }
        catch (Exception e) 
        {
        	responseInvalidRequest(ErrorCode.IllegalMessageBody, e.getMessage());
            LogUtil.printStackTrace(e);
        }
    }

    
}
