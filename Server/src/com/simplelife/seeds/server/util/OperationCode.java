/**
 * OperationCode.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.util;

/**
 * Defines operation code for saving in DBs 
 */
public interface OperationCode 
{
	long
	ADMIN_LOGIN = 101,
	ADMIN_TRIGGER_SEED_CAP_TASK = 102,
	ADMIN_CHANGE_USER_STATE = 103,
	USER_REGISTER = 1001,
	USER_LOGIN = 1002,
	USER_LOGOUT = 1003,
	ALOHA_REQUEST = 1004,
	USER_REQUEST_SEED_STATUS = 1005,
	USER_REQUEST_SEED_INFO = 1006,
	USER_REQUEST_SEED_RSS = 1007,
	SEED_CAP_TASK_START = 1008,
    SEED_CAP_TASK_SUCCEED = 1009,
    SEED_CAP_TASK_FAILED = 1010,
    SEED_CAP_TASK_GIVENUP = 1011,
	USER_REQUEST_INVALID = 1012;
}
