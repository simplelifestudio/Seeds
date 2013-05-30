package com.simplelife.seeds.server;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DateUtil {
	private static Logger _logger = Logger.getLogger("Util");
	private final static int INVALID_VALUE = 0xffff;
	private static SimpleDateFormat defaultDateFormatter;
	
	public DateUtil()
	{
		
	}
	
	/**
	 * Get simple date formatter with default time zone of GMT+8
	 * @return simple date formatter
	 */
	public static SimpleDateFormat getDefaultDateFormatter()
	{
		if (defaultDateFormatter == null)
		{
			defaultDateFormatter = new SimpleDateFormat("yyyy-MM-dd");
			defaultDateFormatter.setTimeZone(getDefaultTimeZone());
		}
		return defaultDateFormatter; 
	}
	
	/**
	 * Get default time zone of China
	 * @return default time zone
	 */
	public static TimeZone getDefaultTimeZone()
	{
		return TimeZone.getTimeZone("GMT+8");
	}
	
	/**
	 * Get calendar instance with default time zone of GMT+8 
	 * @return Calendar instance
	 */
	public static Calendar getCalendar()
	{
		TimeZone.setDefault(getDefaultTimeZone());
		return Calendar.getInstance();
	}
	
	/**
	 * Get day difference between two dates
	 * @param d1:date1
	 * @param d2:date2
	 * @return day difference between d1 and d2, and difference will be negative if d1 > d2 
	 */
	public static int getDaysBetween(String d1, String d2)
	{
		Calendar cal_start;
		Calendar cal_end;
		
		try
		{
			Date date_start = getDefaultDateFormatter().parse(d1);
			Date date_end = getDefaultDateFormatter().parse(d2);
			cal_start = Calendar.getInstance();
			cal_end = Calendar.getInstance();
			cal_start.setTime(date_start);
			cal_end.setTime(date_end);
		}
		catch(Exception e)
		{
			_logger.log(Level.SEVERE, "Invalid date found: " + d1 + ", " + d2 + ", " + e.getMessage());
			return INVALID_VALUE;
		}
		return getDaysBetween(cal_start, cal_end);
	}
	
	/**
	 * Get day difference between two dates
	 * @param d1:date1
	 * @param d2:date2
	 * @return day difference between d1 and d2, and difference will be negative if d1 > d2
	 */
	public static int getDaysBetween(Calendar d1, Calendar d2)
	{
		boolean d1befored2 = true;
		int days = 0;
		try
		{
			if (d1.after(d2)) {
				Calendar swap = d1;
				d1 = d2;
				d2 = swap;
				d1befored2 = false;
			}
			
			days = d2.get(Calendar.DAY_OF_YEAR)- d1.get(Calendar.DAY_OF_YEAR);
			int y2 = d2.get(Calendar.YEAR);
			if (d1.get(Calendar.YEAR) != y2) {
			   d1 = (Calendar) d1.clone();
			   do {
			    days += d1.getActualMaximum(Calendar.DAY_OF_YEAR);
			    d1.add(Calendar.YEAR, 1);
			   } while (d1.get(Calendar.YEAR) != y2);
			}
		}
		catch(Exception e)
		{
			_logger.log(Level.SEVERE, "Invalid date found: " + d1 + ", " + d2 + ", " + e.getMessage());
			return INVALID_VALUE;
		}
		
		if (d1befored2)
		{
			return days;
		}
		else
		{
			return -days;
		}
	}
	
	/**
	 * Get date as format of "yyyy-MM-dd"
	 * @param date: string of date
	 * @return String of date with format of "yyyy-MM-dd" 
	 */
	public static String getFormatedDate(String date)
	{
		return getFormatedDate(date, "yyyy-MM-dd");
	}
	
	/**
	 * Get date as given date format
	 * @param date: string of date
	 * @param format: given date format, such as "yyyy-MM-dd"
	 * @return String of date with given format
	 */
	public static String getFormatedDate(String date, String format)
	{
		SimpleDateFormat sdf = new SimpleDateFormat(format);
		try
		{
			Date dateTmp = sdf.parse(date);
			return sdf.format(dateTmp);
		}
		catch(Exception e)
		{
			_logger.log(Level.SEVERE, "Invalid date found: " + date + ", " + e.getMessage());
			return null;
		}
	}
	
	/**
	 * Get day difference between given date and today
	 * @param date: given date
	 * @return day difference
	 */
	public static int getDaysFromToday(String date)
	{
		Calendar cal_start;
		try
		{
			Date date_start = getDefaultDateFormatter().parse(date);
			cal_start = getCalendar();
			cal_start.setTime(date_start);
			
			return getDaysBetween(cal_start, getCalendar());
		}
		catch(Exception e)
		{
			_logger.log(Level.SEVERE, "Invalid date found: " + date + ", " + e.getMessage());
			return INVALID_VALUE;
		}
	}
	
	/**
	 * Get date object of current
	 * @return
	 */
	public static Date getNowDate()
	{
		return getCalendar().getTime();
	}
	
	/**
	 * Get date string as format of "yyyy-MM-dd"
	 * @return
	 */
	public static String getNow()
	{
		return getDefaultDateFormatter().format(getCalendar().getTime());
	}
	
	/**
	 * Get date string of backward from today by given days, in format of "yyyy-MM-dd"
	 * @param dayBack: backward days from today
	 * @return Date string in format of "yyyy-MM-dd"
	 */
	public static String getDateStringByDayBack(int dayBack)
	{
		String now;
		Calendar cal = getCalendar();
		cal.add(Calendar.DAY_OF_YEAR, -dayBack);
		now = getDefaultDateFormatter().format(cal.getTime());
		return now;
	}
	
	/**
	 * Get date of next time for triggering task
	 * @param taskTriggerHour: hour of triggering task
	 * @return Date of next trigger
	 */
	public static Date getNextTaskTrigger(int taskTriggerHour)
	{
		return getNextTaskTrigger(taskTriggerHour, 0);
	}
	
	/**
	 * Check if currently is time to trigger task
	 * @param taskTriggerHour: hour of triggering task
	 * @return Return true if time is up, else return false
	 */
	public static boolean isTimeToTrigerTask(int taskTriggerHour)
	{
		return isTimeToTrigerTask(taskTriggerHour, 0);
	}
	
	/**
	 * Check if currently is time to trigger task
	 * @param taskTriggerHour: hour of triggering task
	 * @param taskTriggerMinute: minutes of triggering task
	 * @return Return true if time is up, else return false
	 */
	public static boolean isTimeToTrigerTask(int taskTriggerHour, int taskTriggerMinute)
	{
		Calendar cal = getCalendar();
		int curHour = cal.get(Calendar.HOUR_OF_DAY);
		int curMinute = cal.get(Calendar.MINUTE);
		
		if ((curHour > taskTriggerHour) || 
				((curHour == taskTriggerHour) && (curMinute > taskTriggerMinute)))
		{
			return true;
		}
		
		return false;
	}
	
	/**
	 * Get date of next time for triggering task
	 * @param taskTriggerHour: hour of triggering task
	 * @param taskTriggerMinute: minutes of triggering task
	 * @return Date of next trigger
	 */
	public static Date getNextTaskTrigger(int taskTriggerHour, int taskTriggerMinute)
	{
		Calendar cal = getCalendar();
		int curHour = cal.get(Calendar.HOUR_OF_DAY);
		int curMinute = cal.get(Calendar.MINUTE);
		
		if ((curHour > taskTriggerHour) || 
				((curHour == taskTriggerHour) && (curMinute > taskTriggerMinute)))
		{
			cal.add(Calendar.DAY_OF_YEAR, 1);
		}
		
		cal.set(Calendar.HOUR_OF_DAY, taskTriggerHour);
		cal.set(Calendar.MINUTE, taskTriggerMinute);
		return cal.getTime();
	}
}
