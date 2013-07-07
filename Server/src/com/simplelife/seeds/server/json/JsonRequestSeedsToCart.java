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
		
		if (!paraObj.containsKey(JsonKey.seedIdList)) {
            String err = "Illegal message body: " + JsonKey.seedIdList +" can't be found.";
            LogUtil.warning(err + jsonObject.toString());
            responseInvalidRequest(ErrorCode.IllegalMessageBody, err);
            return false;
        }
		
        String strDateList = paraObj.getString(JsonKey.seedIdList);
        if (strDateList.length() <= 2)
        {
        	String err = "Illegal message body: " + JsonKey.seedIdList +" is empty.";
            LogUtil.warning(err + jsonObject.toString());
            responseInvalidRequest(ErrorCode.IllegalMessageBody, err);
            return false;
        }
        
        LogUtil.info("JSON command is valid.\n");
	    return true;
    }
    
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
            
            if (jsonObject.containsKey(JsonKey.cartId))
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
            
            JSONArray seedList = paraObj.getJSONArray(JsonKey.seedIdList);
            JsonResponseSeedsToCart response = new JsonResponseSeedsToCart(jsonObject, outPrintWriter);
            response.setCartId(cartId);
            response.setSeedList(seedList);
            response.responseNormalRequest();
        }
        catch (Exception e) 
        {
        	responseInvalidRequest(ErrorCode.IllegalMessageBody, e.getMessage());
            LogUtil.printStackTrace(e);
        }
    }

    
}
