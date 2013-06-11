/**
 * LogUtil.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.util;

import java.util.logging.Level;
import java.util.logging.Logger;

public class LogUtil {
	private static Logger logger = Logger.getLogger("Seeds");
	
	public static void info(String logInfo)
	{
		log(Level.INFO, logInfo);
	}
	
	public static void severe(String logInfo)
	{
		log(Level.SEVERE, logInfo);
	}
	
	public static void warning(String logInfo)
	{
		log(Level.WARNING, logInfo);
	}
	
	public static void fine(String logInfo)
	{
		log(Level.FINE, logInfo);
	}
	
	public static void printStackTrace(Exception e)
	{
		StackTraceElement[] messages = e.getStackTrace();
		int length=messages.length;
		for(int i=0;i<length;i++)
		{
			//logger.logp(Level.SEVERE, "", "", messages[i].getClassName());
			//logger.logp(Level.SEVERE, "", "", messages[i].getFileName());
			//logger.logp(Level.SEVERE, "", "", Integer.toString(messages[i].getLineNumber()));
			//logger.logp(Level.SEVERE, "", "", messages[i].getMethodName());
			logger.logp(Level.SEVERE, "", "", messages[i].toString());
		}
	}
	
	private static void log(Level level, String logInfo)
	{
		logger.log(level, logInfo);
	}
}
