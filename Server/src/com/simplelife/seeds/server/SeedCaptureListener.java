/**
 * SeedCaptureListener.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server;

import java.util.Date;
import java.util.Timer;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import com.simplelife.seeds.server.db.SeedCaptureLog;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.DateUtil;
import com.simplelife.seeds.server.util.LogUtil;

public class SeedCaptureListener implements ServletContextListener
{
	private static Timer timer;
	private static int firstTriggerHour = 14;
	private static int nextTriggerHour = 14;
	private static int triggerCountOfToday = 0;

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
		String sql = "select * from SeedCaptureLog where publishDate ='" + today + "' and status >= 2 ";
		if (DaoWrapper.exists(sql))
		{
			LogUtil.info("Seeds of today [" + today + "] have been cpatured, schedule next task tomorrow.");
			scheduleTomorrow();
			return;
		}

		sql = "select * from SeedCaptureLog where publishDate ='" + today + "'";
		if (!DaoWrapper.exists(sql))
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
				sql = "update SeedCaptureLog set status = 1 where publishDate ='" + today + "'";
				DaoWrapper.executeSql(sql);
				scheduleTomorrow();
			}
		}

	}

	@Override
	public void contextDestroyed(ServletContextEvent arg0)
	{
		timer.cancel();
	}

	@Override
	public void contextInitialized(ServletContextEvent arg0)
	{
		System.out.println("===========================================================");
		System.out.println("|                                                         |");
		System.out.println("|            Seed Capture Task Scheduler Launched         |");
		System.out.println("|                                                         |");
		System.out.println("===========================================================");

		scheduleNextCapture();
	}

}
