/**
 * HtmlNodeVisitor.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.parser;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import org.htmlparser.Remark;
import org.htmlparser.Tag;
import org.htmlparser.Text;
import org.htmlparser.visitors.NodeVisitor;
import com.simplelife.seeds.server.db.Seed;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.DateUtil;
import com.simplelife.seeds.server.util.LogUtil;

public class HtmlNodeVisitor extends NodeVisitor 
{
	private final char charColon =':';
	private final char charColonFullwidth1 ='︰';
	private final char charColonFullwidth2 ='：';

	private final char charBracketLeft ='[';
	private final char charBracketLeftChn ='【';
	private final char charBracketRight =']';
	private final char charBracketRightChn ='】';

	private final char charReturn ='\r';
	private final char charNewline ='\n';	
	
	private int _analyzeStatus = AnalyzeStatus.Init;
	private Seed seed;
	private String publishDate;
	
	private interface AnalyzeStatus
	{
		public final static int Init = 1;
		public final static int FilmInfo = 2;
		public final static int WaitForName = 3;
		public final static int Link = 4;
	}
	
	public HtmlNodeVisitor(boolean recurseChildren, boolean recurseSelf)
	{
		super(recurseChildren, recurseSelf);
	}
	
	/**
	 * Check if tag is picture link, and add to current seed if yes
	 */
	public void visitTag(Tag tag) 
	{
		if (_analyzeStatus != AnalyzeStatus.FilmInfo)
		{
			return;
		}
		
		if(isImageLink(tag))
    	{
			String picLink = getImageLink(tag.getText());
			seed.addPicture(picLink);
    	}
    }

	/**
	 * Handle text nodes
	 */
    public void visitStringNode (Text string)    {
    	String nodeText = string.getText();
    	nodeText = nodeText.replaceAll("&nbsp;", "");
    	nodeText = nodeText.trim();
    	if (_analyzeStatus == AnalyzeStatus.WaitForName)
    	{
    		seed.setName(formatText(nodeText, true));
    		_analyzeStatus = AnalyzeStatus.FilmInfo;
    		return;
    	}
    	
    	if (_analyzeStatus == AnalyzeStatus.Link)
    	{
    	    String torrentLink = formatText(nodeText, false);
    	    if (torrentLink.length() == 0)
    	    {
    	        // we don't change status here, as the next node may be the link we want
    	        LogUtil.severe("Empty torrent link found.");
    	        return;
    	    }
    	    
    		seed.setTorrentLink(torrentLink);
    		if (!checkSeedForSave(seed))
    		{
    			LogUtil.severe("Invalid seed info for save: " + seed.toString());
    			_analyzeStatus = AnalyzeStatus.Init;
    			return;
    		}
    		
			DaoWrapper.save(seed);
			LogUtil.info("Saved seed to DB: \n" + seed.toString());
			_analyzeStatus = AnalyzeStatus.Init;
			return;
    	}
    		
    	if (isFilmName(nodeText))
    	{
    		// Start a new seed if film name found
    		_analyzeStatus = AnalyzeStatus.FilmInfo;
    		seed = new Seed();
    		
    		String filmName = formatText(nodeText, true);
    		if (filmName.length() == 0)
    		{
    			_analyzeStatus = AnalyzeStatus.WaitForName;
    		}
    		else
    		{
    			seed.setName(filmName);
    		}
    		
    		//seed.setName(nodeText);
    		seed.setType("AV");
    		seed.setSource("咪咪爱");
    		
    		if (publishDate == null || publishDate.length() == 0)
    		{
    			publishDate = DateUtil.getToday();
    		}
    		seed.setPublishDate(publishDate);
    	}
    	else if(isFilmFormat(nodeText))
    	{
    		seed.setFormat(formatText(nodeText, true));
    	}
    	else if(isFilmSize(nodeText))
    	{
    		seed.setSize(formatText(nodeText, true));
    	}
    	else if(isFilmMosaic(nodeText))
    	{
    		seed.setMosaic(formatText(nodeText, true));
    	}
    	else if(isTorrentLink(nodeText))
    	{
    		if (_analyzeStatus == AnalyzeStatus.FilmInfo)
    		{
    			_analyzeStatus = AnalyzeStatus.Link;
    		}
    	}
    	else if(isHash(nodeText))
    	{
    		seed.setHash(formatText(nodeText, true));
    	}
    }
    public void visitRemarkNode (Remark remark) 
    {
    	//_logger.log(Level.INFO,"This is Remark:"+remark.getText());
    }
    
    public void beginParsing () 
    {
    	//_logger.log(Level.INFO,"beginParsing");
    }
    
    public void visitEndTag (Tag tag)
    {
    	//_analyzeStatus = AnalyzeStatus.Init;
    	//_logger.log(Level.INFO,"visitEndTag:"+tag.getText());
    }
    
    public void finishedParsing () 
    {
    	//_logger.log(Level.INFO,"finishedParsing");
    }
    
    
    /**
     * Cut sub string before special char
     * @param field: string to be checked
     * @param charToCut: char to be checked
     * @return String after remove
     */
    private String cutString(String field, char charToCut)
    {
    	int index = field.indexOf(charToCut);
    	if (index == field.length() - 1)
    	{
    		return field;
    	}
    	
    	if (index >= 0)
    	{
    		field = field.substring(index + 1).trim();
    	}
    	return field;
    }
    
    /**
     * Check and remove head char if found
     * @param field: string to be checked
     * @param charHead: char to be checked 
     * @return String after remove
     */
    private String removeHead(String field, char charHead)
    {
		if (field.charAt(0) == charHead)
		{
			field = field.substring(1).trim();
		}
		return field;
    }
    
    /**
     * Cut sub string before special char
     * @param field: field to be formatted
     * @param removeColon: if colon will be removed or not
     * @return String after remove
     */
    public String cutSpecialChar(String field, boolean removeColon)
    {
    	if (field == null) 
		{
			return null;
		}
		
		if (field.length() == 0)
		{
			return "";
		}
		
		int len = 0;
		while (len != field.length())
		{
			len = field.length();
			if (removeColon)
			{
				field = cutString(field, charColon);
			}
			
			field = cutString(field, charColonFullwidth1);
			field = cutString(field, charColonFullwidth2);
			//field = cutString(field, charBracketLeft);
			field = cutString(field, charBracketRight);
			field = cutString(field, charBracketRightChn);
			//field = cutString(field, charReturn);
			//field = cutString(field, charNewline);
		}
		
		return field;
    }
    
    /**
     * Remove special heading chars in field  
     * @param field: String to be checked
     * @param removeColon: if colon will be removed or not
     * @return String after remove
     */
    public String removeHeadSpecialChar(String field, boolean removeColon)
    {
		if (field == null) 
		{
			return null;
		}
		
		if (field.length() == 0)
		{
			return "";
		}
		
		int len = 0;
		while (len != field.length())
		{
			len = field.length();
			if (removeColon)
			{
				field = removeHead(field, charColon);
			}
			
			field = removeHead(field, charColonFullwidth1);
			field = removeHead(field, charColonFullwidth2);
			field = removeHead(field, charBracketLeft);
			field = removeHead(field, charBracketLeftChn);
			field = removeHead(field, charBracketRight);
			field = removeHead(field, charBracketRightChn);
			field = removeHead(field, charReturn);
			field = removeHead(field, charNewline);
		}
		
		return field;
    }
    
    /**
     * Remove special characters
     * @param field: string of field
     * @return String after removing special characters  
     */
    public String formatText(String field, boolean removeColon)
    {
    	field = removeHeadSpecialChar(field, removeColon);
    	field = cutSpecialChar(field, removeColon);
		return field;
    }
    
   
    /**
     * Check fields of seed to ensure it's valid for save
     * @param seed: object of current seed
     * @return true if ok, else false
     */
    private boolean checkSeedForSave(Seed seed)
    {
    	if (seed.getName() == null || seed.getName().length() == 0)
    	{
    		return false;
    	}
    	if (seed.getTorrentLink() == null || seed.getTorrentLink().length() == 0)
    	{
    		return false;
    	}
    	return true;
    }

    private boolean isFilmName(String str)
    {
    	if (str.indexOf("片名") >= 0)
    	{
    		return true;
    	}
    	return false;
    }
    
    private boolean isFilmSize(String str)
    {
    	if (str.indexOf("大小") >= 0)
    	{
    		return true;
    	}
    	return false;
    }
    private boolean isFilmFormat(String str)
    {
    	if (str.indexOf("影片格式") >= 0)
    	{
    		return true;
    	}
    	
    	if (str.indexOf("文件類型") >= 0)
    	{
    		return true;
    	}
    	
    	if (str.indexOf("文件类型") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("格式类型") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("格式類型") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("格式") >= 0)
    	{
    		return true;
    	}
    	return false;
    }
    private boolean isFilmMosaic(String str)
    {
    	if (str.indexOf("有碼無碼") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("有码无码") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("是否有碼") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("是否有码") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("影片類別") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("有／無碼") >= 0)
    	{
    		return true;
    	}
        if (str.indexOf("檔案類別") >= 0)
        {
            return true;
        }
    	return false;
    }
    
    private boolean isHash(String str)
    {
    	if (str.indexOf("验证徵码") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("驗證號碼") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("特 征 码") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("特征编码") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("驗證全碼") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("验证编码") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("哈 希 校") >= 0)
    	{
    		return true;
    	}
    	return false;
    }
    
    private boolean isTorrentLink(String str)
    {
    	if (str.indexOf("Link URL:") >= 0)
    	{
    		return true;
    	}
    	return false;
    }
    
    
    
    private boolean isImageLink(Tag tag)
    {
    	if (tag.getTagName().indexOf("IMG") >= 0)
    	{
    		return true;
    	}
    	return false;
    }
    
    private String getImageLink(String str)
    {
    	int index = str.indexOf("src=\""); 
    	if (index < 0)
    	{
    		return "";
    	}
    	
    	int start = index + 5;
    	int end = str.indexOf('"', start);
    	if (end < 0)
    	{
    		return "";
    	}
    	return str.substring(start, end);
    }

	/**
	 * @return the publishDate
	 */
	public String getpublishDate() {
		return publishDate;
	}

	/**
	 * @param publishDate the publishDate to set
	 */
	public void setpublishDate(String publishDate) {
		this.publishDate = publishDate;
	}

}
