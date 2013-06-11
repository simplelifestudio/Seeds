/**
 * LogId.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.db;

public interface LogId {
	int
	SEED_CAP_TASK_START = 1,
	SEED_CAP_TASK_SUCCEED = 2,
	SEED_CAP_TASK_FAILED = 3,
	SEED_CAP_TASK_GIVENUP = 4,
	ADMIN_LOGIN = 101,
	ADMIN_TRIGGER_SEED_CAP_TASK = 102,
	ADMIN_CHANGE_USER_STATE = 103,
	USER_REGISTER = 201,
	USER_LOGIN = 202,
	USER_LOGOUT = 203,
	ALOHA_REQUEST = 204,
	USER_REQUEST_SEED_STATUS = 205,
	USER_REQUEST_SEED_INFO = 206,
	USER_REQUEST_SEED_RSS = 207,
	USER_REQUEST_INVALID = 501;
}
