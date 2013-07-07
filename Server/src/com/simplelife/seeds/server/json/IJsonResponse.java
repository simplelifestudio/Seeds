/**
 * IJsonResponse.java
 * 
 * History:
 *     2013-7-6: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.json;


/**
 * 
 */
public interface IJsonResponse
{
    public void responseError(int intErrorCode, String strErrorDescription);
    public void responseNormalRequest();
}
