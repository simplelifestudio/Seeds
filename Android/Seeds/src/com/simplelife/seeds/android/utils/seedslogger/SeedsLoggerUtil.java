/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsLoggerUtil.java
 *  Seeds
 *
 *  Created by Chris Li on 13-6-28. 
 */

package com.simplelife.seeds.android.utils.seedslogger;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;
import com.google.code.microlog4android.config.PropertyConfigurator;

import android.content.Context;
import android.util.Log;

public class SeedsLoggerUtil {
    
	private static boolean mLogFlag  = true;
	private static boolean mLogToSD  = true;
    private static int     mLogLevel = Log.VERBOSE;
    public  static String  mTag      = "[Seeds]";    
    
    // Single instance for seeds logger
    private static SeedsLoggerUtil mInstance = null;
    
    // Instance of micro4android
    private static Logger mMicroLog = null;
    
 	// Context of the application using the database.  
 	private final Context mContext; 
    
    public static void initSeedsLogger(Context _context){      	
    	
    	if(mInstance == null){  
    		mInstance = new SeedsLoggerUtil(_context);  
        }
    	
    	// Start the micro4android instance
    	PropertyConfigurator.getConfigurator(_context).configure();
    	
    	// Fetch the micro4android instance
    	mMicroLog = LoggerFactory.getLogger(SeedsLoggerUtil.class);
    	
    	// Set the log level 
    	judgeLoggerType();
    }  
      
    public static SeedsLoggerUtil getSeedsLogger(){  
        return mInstance;  
    } 
  
 	public SeedsLoggerUtil (Context _context) { 		
 		mContext = _context; 		
 	}
 	
 	private static void judgeLoggerType(){
 		if(!android.os.Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED))
 			mLogToSD = false;
 	}
 	
 	public void enableLogToSDCard(){
 		mLogToSD = true;
 	}
 	
 	public void disableLogToSDCard(){
 		mLogToSD = false;
 	}
 	
 	public void turnOffSeedsLogger(){
 		mLogFlag = false;
 	}
 	
 	public void turnOnSeedsLogger(){
 		mLogFlag = true;
 	}
 	
 	public void setLogLevelAboveVerbose(){
 		mLogLevel = Log.VERBOSE;
 	}
 	
 	public void setLogLevelAboveDebug(){
 		mLogLevel = Log.DEBUG;
 	}
 	
 	public void setLogLevelAboveInfo(){
 		mLogLevel = Log.INFO;
 	}
 	
 	public void setLogLevelAboveWARN(){
 		mLogLevel = Log.WARN;
 	}
 	
 	public void setLogLevelAboveError(){
 		mLogLevel = Log.ERROR;
 	}

    
    private String getFunctionName()  
    {  
        StackTraceElement[] sts = Thread.currentThread().getStackTrace();  
        if(sts == null)  
        {  
            return null;  
        }  
        for(StackTraceElement st : sts)  
        {  
            if(st.isNativeMethod())  
            {  
                continue;  
            }  
            if(st.getClassName().equals(Thread.class.getName()))  
            {  
                continue;  
            }  
            if(st.getClassName().equals(this.getClass().getName()))  
            {  
                continue;  
            }  
            return  "[ " + Thread.currentThread().getName() + ": "  
                    + st.getFileName() + ":" + st.getLineNumber() + " "  
                    + st.getMethodName() + " ]";  
        }  
        return null;  
    } 
    
    public void info(Object str)  
    {  
        if(mLogFlag)  
        {  
            if(mLogLevel <= Log.INFO)  
            {  
                String name = getFunctionName();  
                if(name != null)  
                {  
                    if(mLogToSD)
                    	mMicroLog.info(mTag + name + " - " + str);
                    else
                    	Log.i(mTag, name + " - " + str);  
                }  
                else  
                {  
                    if(mLogToSD)
                    	mMicroLog.info(mTag + str.toString());
                    else
                    	Log.i(mTag, str.toString());  
                }  
            }  
        }  
          
    } 
    
    public void debug(Object str)  
    {  
        if(mLogFlag)  
        {  
            if(mLogLevel <= Log.DEBUG)  
            {  
                String name = getFunctionName();  
                if(name != null)  
                {  
                    if(mLogToSD)
                    	mMicroLog.debug(mTag + name + " - " + str);
                    else
                    	Log.d(mTag, name + " - " + str);  
                }  
                else  
                {  
                    if(mLogToSD)
                    	mMicroLog.debug(mTag + str.toString());
                    else
                    	Log.d(mTag, str.toString());  
                }  
            }  
        }  
    }  
      
    public void verbose(Object str)  
    {  
        if(mLogFlag)  
        {  
            if(mLogLevel <= Log.VERBOSE)  
            {  
                String name = getFunctionName();  
                if(name != null)  
                {  
                    if(mLogToSD)
                    	mMicroLog.debug(mTag + name + " - " + str);
                    else
                    	Log.v(mTag, name + " - " + str);  
                }  
                else  
                {  
                    if(mLogToSD)
                    	mMicroLog.debug(mTag + str.toString());
                    else
                    	Log.v(mTag, str.toString());  
                }  
            }  
        }  
    }  
      
    public void warn(Object str)  
    {  
        if(mLogFlag)  
        {  
            if(mLogLevel <= Log.WARN)  
            {  
                String name = getFunctionName();  
                if(name != null)  
                {  
                    if(mLogToSD)
                    	mMicroLog.warn(mTag + name + " - " + str);
                    else
                    	Log.w(mTag, name + " - " + str);  
                }  
                else  
                {  
                    if(mLogToSD)
                    	mMicroLog.warn(mTag + str.toString());
                    else
                    	Log.w(mTag, str.toString());  
                }  
            }  
        }  
    }  
      
    public void error(Object str)  
    {  
        if(mLogFlag)  
        {  
            if(mLogLevel <= Log.ERROR)  
            {  
                String name = getFunctionName();  
                if(name != null)  
                {  
                    if(mLogToSD)
                    	mMicroLog.error(mTag + name + " - " + str);
                    else
                    	Log.e(mTag, name + " - " + str);  
                }  
                else  
                {  
                    if(mLogToSD)
                    	mMicroLog.error(mTag + str.toString());
                    else
                    	Log.e(mTag, str.toString());  
                }  
            }  
        }  
    }  
      
    public void excep(Exception ex)  
    {  
        if(mLogFlag)  
        {  
            if(mLogLevel <= Log.ERROR)  
            {  
                if(mLogToSD)
                	mMicroLog.error(mTag + "error", ex);
                else
                	Log.e(mTag, "error", ex);  
            }  
        }  
    }  
      
    public void ethrow(String log, Throwable tr)  
    {  
        if(mLogFlag)  
        {  
            String line = getFunctionName(); 
            if(mLogToSD)
            	mMicroLog.error(mTag + "{Thread:" + Thread.currentThread().getName() + "}"  
                        + "[" + line + ":] " + log + "\n", tr);
            else
            	Log.e(mTag, "{Thread:" + Thread.currentThread().getName() + "}"  
                    + "[" + line + ":] " + log + "\n", tr);  
        }  
    }  
}  
