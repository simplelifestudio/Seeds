/**
 * SeedCaptureListener.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server;

import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Timer;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import com.simplelife.seeds.server.db.SeedCaptureLog;
import com.simplelife.seeds.server.util.DBExistResult;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.DateUtil;
import com.simplelife.seeds.server.util.HibernateSessionFactory;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.SqlUtil;
import com.simplelife.seeds.server.util.TableColumnName;
import com.simplelife.seeds.server.util.TableName;

public class SeedCaptureListener implements ServletContextListener
{
	private static List<Timer> timerList = new ArrayList<Timer> ();
	private static int firstTriggerHour = 20;
	private static int nextTriggerHour = 20;
	private static int triggerCountOfToday = 0;

	/*
	private static void scheduleToday()
	{
		Date dateTime = DateUtil.getTaskTrigger(nextTriggerHour, false);

		timer = new Timer();
		timer.schedule(new SeedCaptureTask(), dateTime);
		LogUtil.info("========  Next capture task is scheduled and will be launched at: " + dateTime.toString() + "=========\n");
	}
        

	private static void scheduleTomorrow()
	{
		nextTriggerHour = firstTriggerHour;
		triggerCountOfToday = 0;
		Date dateTime = DateUtil.getTaskTrigger(nextTriggerHour, true);

		timer = new Timer();
		timer.schedule(new SeedCaptureTask(), dateTime);
		LogUtil.info("========  Next capture task is scheduled and will be launched at: " + dateTime.toString() + "=========\n");
	}

	public static void scheduleNextCapture()
	{
		if (timer != null)
		{
			timer.cancel();
			timer.purge();
		}

		String today = DateUtil.getToday();
		// succeed today
		String condition = SqlUtil.getPublishDateCondition(today) + " and status >= 2 ";
		String sql = SqlUtil.getSelectCaptureLogSql(condition);
		DBExistResult result = DaoWrapper.exists(sql); 
		if (result == DBExistResult.existent)
		{
			LogUtil.info("Seeds of today [" + today + "] have been cpatured, schedule next task tomorrow.");
			scheduleTomorrow();
			return;
		}
		else if (result == DBExistResult.errorOccurred)
		{
		    LogUtil.info("Abnormal DB status, schedule next task tomorrow.");
            scheduleTomorrow();
            return;
		}

		sql = SqlUtil.getSelectCaptureLogSql(SqlUtil.getPublishDateCondition(today));
		if (DaoWrapper.exists(sql) != DBExistResult.existent)
		{
			// First try of today
			SeedCaptureLog capLog = new SeedCaptureLog();
			capLog.setPublishDate(today);
			capLog.setStatus(0);
			DaoWrapper.save(capLog);
		}
		else
		{
			// Failed today
			triggerCountOfToday++;
			if (triggerCountOfToday <= 3)
			{
				// We still need to retry today
				nextTriggerHour++;
				scheduleToday();
			}
			else
			{
				// Give up, retry tomorrow.
				sql = "update "+ TableName.SeedCaptureLog +" set "+ TableColumnName.status +" = 1 where " + SqlUtil.getPublishDateCondition(today);
				DaoWrapper.executeSql(sql);
				scheduleTomorrow();
			}
		}

	}
	*/

	private void createTimers()
	{
	    createTimer(DateUtil.getTaskTrigger(20, false));
	    createTimer(DateUtil.getTaskTrigger(21, false));
	    createTimer(DateUtil.getTaskTrigger(22, false));
	}
	
	/**
	 * 
	 * @param dateTime: the time of first execution
	 * @param period: internal seconds of executions
	 */
	public void createTimer(Date dateTime, long period)
	{
	    try
	    {
	        Timer timer = new Timer();
	        timer.scheduleAtFixedRate(new SeedCaptureTask(), dateTime, period * 1000);
	        timerList.add(timer);
	        LogUtil.info("============Seed capture task scheduled from " + dateTime.toString() + " at interval of " + Long.toString(period) + " seconds.");
	    }
	    catch (Exception e)
	    {
	        LogUtil.printStackTrace(e);
	    }
	}
	
	public void createTimer(Date dateTime)
	{
	    createTimer(dateTime, 86400);
	}
	
	@Override
	public void contextDestroyed(ServletContextEvent arg0)
	{
	    /*
		if (timer != null)
		{
			timer.cancel();
		}
		*/
	    Iterator<Timer> it = timerList.iterator();
	    Timer timer;
	    while (it.hasNext())
	    {
	        timer = it.next();
	        timer.cancel();
	    }
	    
		HibernateSessionFactory.closeCurrentSession();
	}

	@Override
	public void contextInitialized(ServletContextEvent arg0)
	{
		System.out.println("===========================================================");
		System.out.println("|                                                         |");
		System.out.println("|            Seed Capture Task Scheduler Launched         |");
		System.out.println("|                                                         |");
		System.out.println("===========================================================");

		//scheduleNextCapture();
		
		createTimers();
	}

}
