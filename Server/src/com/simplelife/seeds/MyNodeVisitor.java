package com.simplelife.seeds;

import java.util.logging.Level;
import java.util.logging.Logger;

import org.htmlparser.Remark;
import org.htmlparser.Tag;
import org.htmlparser.Text;
import org.htmlparser.visitors.NodeVisitor;

public class MyNodeVisitor extends NodeVisitor {
	private Logger _logger = Logger.getLogger("MyNodeVistor");
	private AnalyzeFlag _AnalyzeFlag = AnalyzeFlag.Init;
	private enum AnalyzeFlag
	{
		Init, FilmInfo, Link;
	}
	
	public MyNodeVisitor(boolean recurseChildren, boolean recurseSelf)
	{
		super(recurseChildren, recurseSelf);
	}
	
	public void visitTag(Tag tag) 
	{
		if (_AnalyzeFlag != AnalyzeFlag.FilmInfo)
		{
			return;
		}
		
		if(isImageLink(tag))
    	{
			System.out.println(getImageLink(tag.getText()));
    	}
    	//_logger.log(Level.INFO, "This is Tag:"+tag.getText());
    }
	
    public void visitStringNode (Text string)    {
    	if (_AnalyzeFlag == AnalyzeFlag.Link)
    	{
    		// TODO: save to db
    		System.out.println("Torrent link：" + string.getText());
    		return;
    	}
    		
    	if (isFilmName(string.getText()))
    	{
    		_AnalyzeFlag = AnalyzeFlag.FilmInfo;
    		System.out.println("\n\n影片名称：" + string.getText());
    	}
    	else if(isFilmFormat(string.getText()))
    	{
    		System.out.println("影片格式：" + string.getText());
    	}
    	else if(isFilmSize(string.getText()))
    	{
    		System.out.println("影片大小：" + string.getText());
    	}
    	else if(isFilmMosaic(string.getText()))
    	{
    		System.out.println("有码无码：" + string.getText());
    	}
    	else if(isTorrentLink(string.getText()))
    	{
    		_AnalyzeFlag = AnalyzeFlag.Link;
    	}
    	else if(isHash(string.getText()))
    	{
    		System.out.println("哈希校验：" + string.getText());
    	}

    	
    	//_logger.log(Level.INFO,"This is Text:"+string);
    }
    public void visitRemarkNode (Remark remark) {
    	//_logger.log(Level.INFO,"This is Remark:"+remark.getText());
    }
    public void beginParsing () {
    	//_logger.log(Level.INFO,"beginParsing");
    }
    public void visitEndTag (Tag tag){
    	_AnalyzeFlag = AnalyzeFlag.Init;
    	//_logger.log(Level.INFO,"visitEndTag:"+tag.getText());
    }
    public void finishedParsing () {
    	//_logger.log(Level.INFO,"finishedParsing");
    }
    
    private boolean isFilmName(String str)
    {
    	if (str.indexOf("影片名称") >= 0)
    	{
    		return true;
    	}
    	
    	if (str.indexOf("影片片名") >= 0)
    	{
    		return true;
    	}
    	
    	if (str.indexOf("影片名稱") >= 0)
    	{
    		return true;
    	}
    	return false;
    }
    
    private boolean isFilmSize(String str)
    {
    	if (str.indexOf("影片大小") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("檔案大小") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("大小時間") >= 0)
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
    	if (str.indexOf("檔案類別") >= 0)
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

}
