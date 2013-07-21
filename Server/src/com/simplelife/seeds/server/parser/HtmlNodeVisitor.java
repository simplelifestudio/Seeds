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

public class HtmlNodeVisitor extends NodeVisitor {
	private AnalyzeStatus _analyzeStatus = AnalyzeStatus.Init;
	private Seed seed;
	private String publishDate;
	
	private enum AnalyzeStatus
	{
		Init, FilmInfo, Link;
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
    	
    	if (_analyzeStatus == AnalyzeStatus.Link)
    	{
    		seed.setTorrentLink(nodeText);
    		
    		if (!checkSeedForSave(seed))
    		{
    			LogUtil.warning("Invalid seed info for save: " + seed.toString());
    			return;
    		}
    		formatSeedForSave(seed);
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
    		seed.setName(nodeText);
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
    		seed.setFormat(nodeText);
    	}
    	else if(isFilmSize(nodeText))
    	{
    		seed.setSize(nodeText);
    	}
    	else if(isFilmMosaic(nodeText))
    	{
    		seed.setMosaic(nodeText);
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
    		seed.setHash(nodeText);
    	}
    }
    public void visitRemarkNode (Remark remark) {
    	//_logger.log(Level.INFO,"This is Remark:"+remark.getText());
    }
    public void beginParsing () {
    	//_logger.log(Level.INFO,"beginParsing");
    }
    public void visitEndTag (Tag tag){
    	//_analyzeStatus = AnalyzeStatus.Init;
    	//_logger.log(Level.INFO,"visitEndTag:"+tag.getText());
    }
    public void finishedParsing () {
    	//_logger.log(Level.INFO,"finishedParsing");
    }
    
    /**
     * Remove special characters
     * @param field: string of field
     * @return String after removing special characters  
     */
    public String removePreTitle(String field)
    {
		if (field == null) {
			return null;
		}
		
		int index = field.indexOf("Link");
		if (index >= 0) {
			// Link URL: [url]http://www.maxp2p.com/link.php?ref=ft48srXUSU
			index = field.indexOf("http://");
			field = field.substring(index).trim();
			return field;
		}
		
		index = field.indexOf("]");
		if (index > 0) {
			field = field.substring(index + 1).trim();
		}
		else
		{
			index = field.indexOf("】");
			if (index > 0) {
				field = field.substring(index + 1).trim();
			}
		}
		
		index = field.indexOf(":");
		if (index == 0) {
			field = field.substring(1).trim();
		}
		
		index = field.indexOf("：");
		if (index == 0) {
			field = field.substring(1).trim();
		}
		
		field = field.replaceAll("[\"{,}]", "");
		field = field.replace("[", "");
		field = field.replace("]", "");
		return field;
    }
    
    /**
     * Format seed fields before save
     * @param seed: object of current seed
     */
    private void formatSeedForSave(Seed seed)
    {
		if (seed.getFormat() != null) 
		{
			seed.setFormat(removePreTitle(seed.getFormat()));
		}

		if (seed.getHash() != null) 
		{
			seed.setHash(removePreTitle(seed.getHash()));
		}

		if (seed.getMemo() != null) 
		{
			seed.setMemo(removePreTitle(seed.getMemo()));
		}

		if (seed.getMosaic() != null) 
		{
			seed.setMosaic(removePreTitle(seed.getMosaic()));
		}

		if (seed.getName() != null) 
		{
			seed.setName(removePreTitle(seed.getName()));
		}

		if (seed.getSize() != null) 
		{
			seed.setSize(removePreTitle(seed.getSize()));
		}

		if (seed.getType() != null) 
		{
			seed.setType(removePreTitle(seed.getType()));
		}
		
		if (seed.getTorrentLink() != null) 
		{
			seed.setTorrentLink(removePreTitle(seed.getTorrentLink()));
		}
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
