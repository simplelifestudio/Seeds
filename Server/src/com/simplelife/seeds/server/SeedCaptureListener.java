/**
 * SeedCaptureListener.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server;

import java.util.Calendar;
import java.util.Date;
import java.util.Timer;

import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

import com.simplelife.seeds.server.util.DateUtil;
import com.simplelife.seeds.server.util.LogUtil;

public class SeedCaptureListener implements HttpSessionListener 
{
	private static Timer timer;
	private static int taskTriggerHour = 20;
	
	static {
		System.out.println("===========================================================");
		System.out.println("|                                                         |");
		System.out.println("|            Seed Capture Task Scheduler Launched         |");
		System.out.println("|                                                         |");
		System.out.println("===========================================================");
		
		if (DateUtil.isTimeToTrigerTask(taskTriggerHour))
		{
			Calendar cal = DateUtil.getCalendar();
			cal.add(Calendar.MINUTE, 2);
			startCaptureTask(cal.getTime());
		}
		else
		{
			startCaptureTask(DateUtil.getNextTaskTrigger(taskTriggerHour));
		}
	}
	
	public static void scheduleNextCapture()
	{
		timer = new Timer(true);
		Date dateTime = DateUtil.getNextTaskTrigger(taskTriggerHour);
		timer.schedule(new SeedCaptureTask(), dateTime);
		LogUtil.info("Next capture task is scheduled and will be launched at: " + dateTime.toString() + "\n\n");
	}
	
	private static void startCaptureTask(Date dateTime)
	{
		timer = new Timer(true);
		timer.schedule(new SeedCaptureTask(), dateTime);
		LogUtil.info("Capture task to be launched at: " + dateTime.toString() + "\n\n");
	}
	
	@Override
	public void sessionCreated(HttpSessionEvent arg0) {
		System.out.println("=============sessionCreated==================");
	}

	@Override
	public void sessionDestroyed(HttpSessionEvent arg0) {
		System.out.println("=============sessionDestroyed==================");
		
	}

}
