/**
 * JsonKey.java 
 * 
 * History:
 *     2013-6-28: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */
package com.simplelife.seeds.server.util;

/**
 * Defines key words used in JSON command
 */
public class JsonKey
{
	public static final String id = "id";
	public static final String body = "body";
	public static final String errorResponse = "ErrorResponse";
    public static final String requestMessage = "requestMessage";
    public static final String errorCode = "errorCode";
    public static final String errorDescription = "errorDescription";
    public final static String dateList = "dateList";
    public final static String piclinks= "picLinks";
    
    public final static String seedIdList = "seedIdList";
    public final static String cartId = "cartId";
    public final static String successSeedIdList = "successSeedIdList";
    public final static String failedSeedIdList = "failedSeedIdList";
    public final static String existSeedIdList = "existSeedIdList";
    public final static String noUpdate = "NO_UPDATE";
    public final static String notReady = "NOT_READY";
    public final static String ready = "READY";
    public final static String errorStatus = "ERROR_STATUS";
    
	public final static String commandAlohaRequest = "AlohaRequest";
	public final static String commandSeedsStatusRequest = "SeedsUpdateStatusByDatesRequest";
	public final static String commandSeedsByDatesRequest = "SeedsByDatesRequest";
	public final static String commandSeedsToCartRequest = "SeedsToCartRequest";
	
	public final static String commandSeedsByDatesResponse = "SeedsByDatesResponse";
	public final static String commandSeedsStatusResponse = "SeedsUpdateStatusByDatesResponse";
	public final static String commandSeedsToCartResponse = "SeedsToCartResponse";
}
