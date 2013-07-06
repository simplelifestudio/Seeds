/**
 * ErrorCode.java
 * 
 * History:
 *     2013-6-27: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.util;

/**
 * 
 */
public class ErrorCode
{
    public static final int MessageParseError = 1001;           // Invalid JSON string
    public static final int IllegalMessage = 1002;              // Valid JSON string but no "id" in JSON string
    public static final int IllegalMessageId = 1003;            // Valid "id" in JSON but id can't be recognized
    public static final int IllegalMessageBody = 1004;          // There is illegal parameter in message body
    public static final int DatabaseConnectionError = 1005;     // Error on DB connection
    public static final int AbnormalDataInDB = 1006;            // There is abnormal data in DB
    
}
