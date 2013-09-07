/**
 * HtmlParser.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.parser;


import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.htmlparser.Node;
import org.htmlparser.NodeFilter;
import org.htmlparser.Parser;
import org.htmlparser.filters.StringFilter;
import org.htmlparser.tags.LinkTag;
import org.htmlparser.util.NodeList;

import com.simplelife.seeds.server.db.SeedCaptureLog;
import com.simplelife.seeds.server.util.DBExistResult;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.DateUtil;
import com.simplelife.seeds.server.util.HttpUtil;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.OperationLogUtil;
import com.simplelife.seeds.server.util.SqlUtil;
import com.simplelife.seeds.server.util.TableColumnName;
import com.simplelife.seeds.server.util.TableName;


public class HtmlParser implements ISourceParser {
	private String baseLink;
	private final int parseDays = 2;
	//private final String _encode = "GBK";
	private List<String> keyWordList = new ArrayList<String>();
	private String startDate;
	private String endDate;
	private int pageStart;
	private int pageEnd;
	
	/**
	 * @return the pageStart
	 */
	public int getPageStart() {
		return pageStart;
	}

	/**
	 * @param pageStart the pageStart to set
	 */
	public void setPageStart(int pageStart) {
		this.pageStart = pageStart;
	}

	/**
	 * @return the pageEnd
	 */
	public int getPageEnd() {
		return pageEnd;
	}

	/**
	 * @param pageEnd the pageEnd to set
	 */
	public void setPageEnd(int pageEnd) {
		this.pageEnd = pageEnd;
	}

	
	/**
	 * @return the _startDate
	 */
	public String getstartDate() {
		return startDate;
	}

	/**
	 * @param startDate the _startDate to set
	 */
	public void setstartDate(String startDate) {
		this.startDate = startDate;
	}

	/**
	 * @return the _endDate
	 */
	public String getendDate() {
		return endDate;
	}

	/**
	 * @param endDate the _endDate to set
	 */
	public void setendDate(String endDate) {
		this.endDate = endDate;
	}


	/**
	 * @return the _keyWordList
	 */
	public List<String> getkeyWordList() {
		return keyWordList;
	}

	public HtmlParser()
	{
		baseLink = "http://174.123.15.31/forumdisplay.php?fid=55&page={page}";
		keyWordList.add("最新BT");
		pageStart = 1;
		pageEnd = 1;
		startDate = DateUtil.getDateStringByDayBack(parseDays);
		//endDate = DateUtil.getDateStringByDayBack(-1);
		endDate = DateUtil.getToday();
	}
	
	public String getbaseLink() 
	{
		return baseLink;
	}

	public void setbaseLink(String baseLink)
	{
		this.baseLink = baseLink;
	}

	@Override
	public void Parse() 
	{
		parsePageByDateRange();
	}
	
	
	/**
	 * Parse pages by condition of [startDate, endDate] in pages from pageStart to pageEnd
	 */
	public void parsePageByDateRange()
	{
		if (endDate.compareTo(startDate) < 0)
		{
			LogUtil.warning("endDate [" + endDate +"] is earlier than startDate[" + startDate +"], parse cancelled.");
			return;
		}
		
		if (pageEnd < pageStart)
		{
			LogUtil.warning("pageEnd [" + pageEnd +"] is less than pageStart[" + pageStart +"], parse cancelled.");
			return;
		}
		
		String link;
		for (int i = pageStart; i <= pageEnd; i++)
		{
			// Example of Link: http://174.123.15.31/forumdisplay.php?fid=55&page={page}
			link = baseLink.replace("{page}", Integer.toString(i));
			parseFirstLevelPage(link);
		}
	}
	
	
	/**
	 * Parse topic list page, to get seed list pages filtered by given keyword 
	 * @param htmlLink: link of topic list page
	 */
	private void parseFirstLevelPage(String htmlLink)
	{
		try
		{
			if (htmlLink == null || htmlLink.length() == 0)
			{
				LogUtil.severe("Empty HTML Link for parse.");
				return;
			}
			
			//Proxy proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress("10.159.32.155", 8080));
			//HttpURLConnection urlConn = (HttpURLConnection) url.openConnection(proxy);
			HttpURLConnection urlConn = HttpUtil.getHttpUrlConnection(htmlLink);
			Parser parser = new Parser(urlConn);
			
			Iterator<String> it = keyWordList.iterator();
			String keyWord;
			while (it.hasNext())
			{
				keyWord = it.next();
				NodeFilter filter = new StringFilter(keyWord);
				NodeList nodes = parser.extractAllNodesThatMatch(filter);
				if (nodes != null)
				{
					for (int i = 0; i < nodes.size(); i++)
					{
						Node textNode = (Node) nodes.elementAt(i);
						LinkTag parentNode = (LinkTag) textNode.getParent();
						if (parentNode == null)
						{
							LogUtil.severe(textNode.getText() + " with parent node as " + textNode.getParent().getClass());
							continue;
						}
						
						LogUtil.info(textNode.getText() + "," + parentNode.getLink());
						parseSeedPage(parentNode.getLink(), textNode.getText());
					}
				}
			}
		}
		catch(Exception e)
		{
			//LogUtil.severe("Error occurred when trying to parse html page: " + e.getMessage());
			LogUtil.printStackTrace(e);
		}
	}
	
	
	/**
	 * Parse seeds list page
	 * @param htmlLink: link of seeds list page
	 * @param title: title like "[6-01]最新BT合集"
	 */
	private void parseSeedPage(String htmlLink, String title)
	{
		String date = DateUtil.getDateByTitle(title);
		if ((date.compareTo(startDate) < 0) || (date.compareTo(endDate) > 0))
		{
			LogUtil.info("Skip date<" + title + "> since it is out of date range [" + startDate + ", " + endDate + "]");
			return;
		}
		
		parseSeedDetails(htmlLink, date);
	}
	
	/**
	 * Parse details of seeds
	 * @param htmlLink: link of seeds list page
	 * @param date: publish date of seeds
	 */
	public void parseSeedDetails(String htmlLink, String date)
	{
		String condition = SqlUtil.getPublishDateCondition(date) + " and status >= 2 ";
		String sql = SqlUtil.getSelectCaptureLogSql(condition);
		if (DaoWrapper.exists(sql) == DBExistResult.existent)
		{
			LogUtil.info("Seeds of " + date + " have been captured.");
			return;
		}
		
		sql = SqlUtil.getSelectCaptureLogSql(SqlUtil.getPublishDateCondition(date));
		if (DaoWrapper.exists(sql) != DBExistResult.existent)
		{
			// First try of this date
			SeedCaptureLog capLog = new SeedCaptureLog();
			capLog.setPublishDate(date);
			capLog.setStatus(0);
			DaoWrapper.save(capLog);
		}
		
		LogUtil.info("Start to parse seed page: " + htmlLink + ", " + date);
		URL url;
		try 
		{
			OperationLogUtil.captureTaskStarted(htmlLink);
			deleteExistentSeeds(date);
			
			
			//url = new URL(htmlLink);
			//HttpURLConnection urlConn = (HttpURLConnection) url.openConnection();
			HttpURLConnection urlConn = HttpUtil.getHttpUrlConnection(htmlLink);
			Parser parser = new Parser(urlConn);
			
			HtmlNodeVisitor visitor = new HtmlNodeVisitor( true, false );
			visitor.setpublishDate(date);

            parser.visitAllNodesWith(visitor);
            
            updateCaptureLog(date);
			OperationLogUtil.captureTaskSucceed(htmlLink);
			LogUtil.info("Parse seed page succeed: " + htmlLink + ", " + date);
		}
		catch (Exception e) 
		{
			OperationLogUtil.captureTaskFailed(htmlLink);
			LogUtil.severe("Error occurred when trying to parse html page: " + htmlLink + ", error: " + e.getMessage());
			LogUtil.printStackTrace(e);
		}
	}
	
	/**
	 * Delete existent seeds of given date in DB bofore saving new data
	 * @param date: string of date
	 */
	public void deleteExistentSeeds(String date)
	{
	    String sql = "delete from "+ TableName.SeedPicture +" where " + TableColumnName.seedId 
	    		+ " in (select " + TableColumnName.seedId +" from " + TableName.Seed +" where " + SqlUtil.getPublishDateCondition(date) + ")";
        DaoWrapper.executeSql(sql);
        
        sql = "delete from " + TableName.Seed + " where " + SqlUtil.getPublishDateCondition(date);
        DaoWrapper.executeSql(sql);
	}
	
	/**
	 * Update status of seed capture of given date
	 * @param date: string of date
	 */
	private void updateCaptureLog(String date)
	{
	    String sql = "update "+ TableName.SeedCaptureLog +" set status = 2 where " + SqlUtil.getPublishDateCondition(date);
        DaoWrapper.executeSql(sql);
	}

	/**
	 * Delete record of seed capture status of given date
	 * @param date: string of date
	 */
	public void deleteCaptureLog(String date)
	{
		String sql = "delete from "+ TableName.SeedCaptureLog +" where " + SqlUtil.getPublishDateCondition(date);
		DaoWrapper.executeSql(sql);
	}
	
	public void deleteCaptureLog(String startDate, String endDate)
	{
		String sql = "delete from "+ TableName.SeedCaptureLog 
				+" where " + TableColumnName.publishDate + " >= '" + startDate + "' and "
				+ TableColumnName.publishDate + " <= '" + endDate + "'";
		DaoWrapper.executeSql(sql);
	}
}
