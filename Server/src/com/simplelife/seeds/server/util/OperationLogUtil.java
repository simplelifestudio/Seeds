/**
 * OperationLogUtil.java 
 * 
 * History:
 *     2013-06-10: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.util;

import com.simplelife.seeds.server.db.OperationLog;

/**
 * Utility class for saving operation log
 */
public class OperationLogUtil 
{
	public static void captureTaskStarted(String logInfo)
	{
		save(OperationCode.SEED_CAP_TASK_START, logInfo);
	}
	
	public static void captureTaskSucceed(String logInfo)
	{
		save(OperationCode.SEED_CAP_TASK_SUCCEED, logInfo);
	}
	
	public static void captureTaskFailed(String logInfo)
	{
		save(OperationCode.SEED_CAP_TASK_FAILED, logInfo);
	}
	
	
	public static void save(long logId, String logInfo)
	{
		try
		{
			if (logId == 0)
			{
				LogUtil.severe("logId can't be 0.");
				return;
			}
			
			OperationLog log = new OperationLog(logId, logInfo);
            log.setLogDate(DateUtil.getNow());
			DaoWrapper.save(log);
		}
		catch (Exception e)
		{
			LogUtil.printStackTrace(e);
		}
	}
}
