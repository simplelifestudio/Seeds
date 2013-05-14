package com.simplelife.seeds.server;


import java.net.HttpURLConnection;
import java.net.URL;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;
import java.util.logging.*;

import org.eclipse.jdt.internal.compiler.lookup.CaptureBinding;
import org.htmlparser.Node;
import org.htmlparser.NodeFilter;
import org.htmlparser.Parser;
import org.htmlparser.filters.*;
import org.htmlparser.tags.LinkTag;
import org.htmlparser.util.*;


public class HtmlParser implements ISourceParser {
	private String _htmlLink;
	private Logger _logger = Logger.getLogger("HtmlParser");
	private final int _parse_days = 3;
	//private final String _encode = "GBK";
	private List<String> _keyWordList = new ArrayList<String>();

	public HtmlParser()
	{
		_htmlLink = "http://174.123.15.31/forumdisplay.php?fid=55";
		_keyWordList.add("最新BT合集");
	}
	public String get_htmlLink() {
		return _htmlLink;
	}

	public void set_htmlLink(String _htmlLink) {
		this._htmlLink = _htmlLink;
	}

	@Override
	public void Parse() {
		parseFirstLevelPage(_htmlLink);
		
	}

	public String dateNeedParse(String title)
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
			_logger.log(Level.WARNING, "Invalid date format found: " + title);
			return null;
		}
		
		try
		{
			Calendar.getInstance().setTimeZone(TimeZone.getTimeZone("GMT+8"));
			
			Calendar calNow = Calendar.getInstance();
			calNow.add(Calendar.DAY_OF_MONTH, 1);
			
			Calendar calParse = Calendar.getInstance();
			calParse.set(Calendar.MONTH, Integer.parseInt(dateString.substring(0, mid))- 1);		// Jan is 0
			calParse.set(Calendar.DAY_OF_MONTH, Integer.parseInt(dateString.substring(mid+1)));
			
			String fmt = "yyyy-MM-dd";
			SimpleDateFormat sdf = new SimpleDateFormat(fmt);
			outDate = sdf.format(calParse.getTime());
			
			calParse.add(Calendar.DATE, _parse_days);
			
			if (calParse.before(calNow))
			{
				_logger.log(Level.WARNING, "Date to be parsed is too early: " + calParse.toString());
				return null;
			}
		}
		catch(Exception e)
		{
			_logger.log(Level.SEVERE, "Invalid date found: " + dateString);
		}
		return outDate;
	}
	
	/*
	private void printNode(Node node, int indent)
	{
		if (node == null)
		{
			indent--;
			return;
		}
		
		if (indent >= 6)
		{
			int aa = 0;
			aa++;
		}
		
		_logger.log(Level.INFO, "[" + indent +"]" + node.getClass() + ", " + node.getText());
		
		if (node.getChildren() == null)
		{
			indent--;
			return;
		}
		
		Node chiNode = node.getFirstChild();
		while (chiNode != null)
		{
			chiNode = chiNode.getNextSibling();
			printNode(chiNode, indent+1);
		}
		indent--;
	}
	*/
	
	private void parseFirstLevelPage(String htmlLink)
	{
		try
		{
			URL url = new URL(htmlLink);
			HttpURLConnection urlConn = (HttpURLConnection) url.openConnection();
			Parser parser = new Parser(urlConn);
			
			//TextExtractingVisitor visitor = new TextExtractingVisitor();
			//parser.visitAllNodesWith(visitor);
			//String textInPage = visitor.getExtractedText();
			//_logger.log(Level.SEVERE, textInPage);
			
			/*for (org.htmlparser.util.NodeIterator it = parser.elements(); it.hasMoreNodes();)
			{
				Node node = it.nextNode();
				printNode(node, 1);
				
			}*/
			
			
			Iterator<String> it = _keyWordList.iterator();
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
							_logger.log(Level.SEVERE, textNode.getText() + " with parent node as " + textNode.getParent().getClass());
							continue;
						}
						
						_logger.log(Level.INFO, textNode.getText() + "," + parentNode.getLink());
						parseSeedPage(parentNode.getLink(), textNode.getText());
					}
				}
			}
		}
		catch(Exception e)
		{
			_logger.log(Level.SEVERE, "Error occurred when trying to parse html page: " + e.getMessage());
		}
	}
	
	private void parseSeedPage(String htmlLink, String date)
	{
		String outDate = dateNeedParse(date);
		if (outDate == null)
		{
			return;
		}
		
		_logger.log(Level.INFO, "Start to parse seed page: " + htmlLink + ", " + date);
		
		URL url;
		try 
		{
			url = new URL(htmlLink);
			HttpURLConnection urlConn = (HttpURLConnection) url.openConnection();
			Parser parser = new Parser(urlConn);
			
			MyNodeVisitor visitor = new MyNodeVisitor( true, false );
			visitor.setpublishDate(outDate);

            parser.visitAllNodesWith(visitor);
		}
		catch (Exception e) 
		{
			_logger.log(Level.INFO, "Error occurred when trying to parse html page: " + htmlLink + ", error: " + e.getMessage());
		}
		
	}
}
