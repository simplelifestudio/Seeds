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
    /**
     * Interface for reporting error to client
     * @param intErrorCode: error code, it should be value in com.simplelife.seeds.server.util.ErrorCode
     * @param strErrorDescription
     */
    public void responseError(int intErrorCode, String strErrorDescription);
    
    /**
     * Interface for report normal result to client 
     */
    public void responseNormalRequest();
}
