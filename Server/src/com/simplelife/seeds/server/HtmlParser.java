package com.simplelife.seeds.server;


import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.URL;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Iterator;
import java.util.List;
import java.util.logging.*;

import org.htmlparser.Node;
import org.htmlparser.NodeFilter;
import org.htmlparser.Parser;
import org.htmlparser.filters.*;
import org.htmlparser.tags.LinkTag;
import org.htmlparser.util.*;


public class HtmlParser implements ISourceParser {
	private String baseLink;
	private Logger logger = Logger.getLogger("HtmlParser");
	private final int parseDays = 3;
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
		keyWordList.add("最新BT合集");
		pageStart = 1;
		pageEnd = 1;
		startDate = DateUtil.getDateStringByDayBack(parseDays);
		endDate = DateUtil.getDateStringByDayBack(-1);
	}
	
	public String getbaseLink() {
		return baseLink;
	}

	public void setbaseLink(String baseLink) {
		this.baseLink = baseLink;
	}

	@Override
	public void Parse() {
		parsePageByDateRange();
	}

	/**
	 * return 2013-06-01 by "[6-01]最新BT合集"
	 * @param title: title in web page
	 * @return Formatted date string
	 */
	private String getDateByTitle(String title)
	{
		String outDate = null;
		int start = title.indexOf('[');
		boolean flag = true;
		if (start < 0)
		{
			flag = false;
		}
		
		int end = title.indexOf(']'); 
		if (end < 0)
		{
			flag = false;
		}
		
		String dateString = title.substring(start + 1, end);
		int mid = dateString.indexOf('-'); 
		if (mid < 0)
		{
			flag = false;
		}
		
		if (!flag)
		{
			logger.log(Level.WARNING, "Invalid date format found: " + title);
			return null;
		}
		outDate = Integer.toString(Calendar.getInstance().get(Calendar.YEAR));
		outDate += "-";
		outDate += dateString;
		
		return DateUtil.getFormatedDate(outDate);
	}
	
	
	/**
	 * Parse pages by condition of [startDate, endDate] in pages from pageStart to pageEnd
	 */
	public void parsePageByDateRange()
	{
		if (endDate.compareTo(startDate) < 0)
		{
			logger.log(Level.WARNING, "endDate [" + endDate +"] is earlier than startDate[" + startDate +"], parse cancelled.");
			return;
		}
		
		if (pageEnd < pageStart)
		{
			logger.log(Level.WARNING, "pageEnd [" + pageEnd +"] is less than pageStart[" + pageStart +"], parse cancelled.");
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
				logger.log(Level.SEVERE, "Empty HTML Link for parse.");
				return;
			}
			
			URL url = new URL(htmlLink);
			//Proxy proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress("10.159.32.155", 8080));
			//HttpURLConnection urlConn = (HttpURLConnection) url.openConnection(proxy);
			HttpURLConnection urlConn = (HttpURLConnection) url.openConnection();
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
							logger.log(Level.SEVERE, textNode.getText() + " with parent node as " + textNode.getParent().getClass());
							continue;
						}
						
						logger.log(Level.INFO, textNode.getText() + "," + parentNode.getLink());
						parseSeedPage(parentNode.getLink(), textNode.getText());
					}
				}
			}
		}
		catch(Exception e)
		{
			logger.log(Level.SEVERE, "Error occurred when trying to parse html page: " + e.getMessage());
		}
	}
	
	
	/**
	 * Parse seeds list page
	 * @param htmlLink: link of seeds list page
	 * @param title: title like "[6-01]最新BT合集"
	 */
	private void parseSeedPage(String htmlLink, String title)
	{
		String date = getDateByTitle(title);
		if ((date.compareTo(startDate) < 0) || (date.compareTo(endDate) > 0))
		{
			logger.log(Level.INFO, "Skip date<" + title + "> since it is out of date range [" + startDate + ", " + endDate + "]");
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
		String sql = "select * from SeedCaptureLog where publishDate ='" + date + "' and status >= 2 ";
		if (DaoWrapper.getInstance().exists(sql))
		{
			logger.log(Level.INFO, "Seeds of " + date + " have been captured.");
			return;
		}
		
		logger.log(Level.INFO, "Start to parse seed page: " + htmlLink + ", " + date);
		URL url;
		try 
		{
			SeedCaptureLog capLog = new SeedCaptureLog();
			capLog.setPublishDate(date);
			capLog.setStatus(1);
			
			OperationLog log = new OperationLog(1, htmlLink);
			log.Save();
			
			deleteCaptureLog(date);
			DaoWrapper.getInstance().save(capLog);
			
			url = new URL(htmlLink);
			HttpURLConnection urlConn = (HttpURLConnection) url.openConnection();
			Parser parser = new Parser(urlConn);
			
			MyNodeVisitor visitor = new MyNodeVisitor( true, false );
			visitor.setpublishDate(date);

            parser.visitAllNodesWith(visitor);
            
            capLog.setStatus(2);
            //deleteCaptureLog(date);
			DaoWrapper.getInstance().save(capLog);
			log = new OperationLog(2, htmlLink);
			log.Save();
			logger.log(Level.INFO, "Parse seed page succeed: " + htmlLink + ", " + date);
		}
		catch (Exception e) 
		{
			OperationLog log = new OperationLog(3, htmlLink);
			log.Save();
			logger.log(Level.INFO, "Error occurred when trying to parse html page: " + htmlLink + ", error: " + e.getMessage());
		}
	}
	
	private void deleteCaptureLog(String date)
	{
		String sql = "delete from SeedCaptureLog where publishDate ='" + date + "'";
		DaoWrapper.getInstance().executeSql(sql);
	}
}
