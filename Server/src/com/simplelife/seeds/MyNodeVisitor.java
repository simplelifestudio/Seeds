package com.simplelife.seeds;

import java.util.logging.Level;
import java.util.logging.Logger;

import org.htmlparser.Remark;
import org.htmlparser.Tag;
import org.htmlparser.Text;
import org.htmlparser.visitors.NodeVisitor;

public class MyNodeVisitor extends NodeVisitor {
	private Logger _logger = Logger.getLogger("MyNodeVistor");
	private AnalyzeStatus _analyzeStatus = AnalyzeStatus.Init;
	private Seed _seed;
	
	private enum AnalyzeStatus
	{
		Init, FilmInfo, Link;
	}
	
	public MyNodeVisitor(boolean recurseChildren, boolean recurseSelf)
	{
		super(recurseChildren, recurseSelf);
	}
	
	public void visitTag(Tag tag) 
	{
		if (_analyzeStatus != AnalyzeStatus.FilmInfo)
		{
			return;
		}
		
		if(isImageLink(tag))
    	{
			
			_logger.log(Level.INFO,getImageLink(tag.getText()));
    	}
    	//_logger.log(Level.INFO, "This is Tag:"+tag.getText());
    }
	
    public void visitStringNode (Text string)    {
    	if (_analyzeStatus == AnalyzeStatus.Link)
    	{
    		// TODO: save to db
    		_logger.log(Level.INFO,"Torrent link��" + string.getText());
    		return;
    	}
    		
    	if (isFilmName(string.getText()))
    	{
    		_analyzeStatus = AnalyzeStatus.FilmInfo;
    		_seed = new Seed();
    		_seed.setName(string.getText());
    		_logger.log(Level.INFO,"\n\nӰƬ���ƣ�" + string.getText());
    	}
    	else if(isFilmFormat(string.getText()))
    	{
    		_seed.setFormat(string.getText());
    		_logger.log(Level.INFO,"ӰƬ��ʽ��" + string.getText());
    	}
    	else if(isFilmSize(string.getText()))
    	{
    		_seed.setSize(string.getText());
    		_logger.log(Level.INFO,"ӰƬ��С��" + string.getText());
    	}
    	else if(isFilmMosaic(string.getText()))
    	{
    		_seed.setMosaic(string.getText());
    		_logger.log(Level.INFO,"�������룺" + string.getText());
    	}
    	else if(isTorrentLink(string.getText()))
    	{
    		if (_analyzeStatus == AnalyzeStatus.FilmInfo)
    		{
    			_analyzeStatus = AnalyzeStatus.Link;
    		}
    	}
    	else if(isHash(string.getText()))
    	{
    		_seed.setHash(string.getText());
    		_logger.log(Level.INFO,"��ϣУ�飺" + string.getText());
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
    	_analyzeStatus = AnalyzeStatus.Init;
    	//_logger.log(Level.INFO,"visitEndTag:"+tag.getText());
    }
    public void finishedParsing () {
    	//_logger.log(Level.INFO,"finishedParsing");
    }
    
    private boolean isFilmName(String str)
    {
    	if (str.indexOf("ӰƬ����") >= 0)
    	{
    		return true;
    	}
    	
    	if (str.indexOf("ӰƬƬ��") >= 0)
    	{
    		return true;
    	}
    	
    	if (str.indexOf("ӰƬ���Q") >= 0)
    	{
    		return true;
    	}
    	return false;
    }
    
    private boolean isFilmSize(String str)
    {
    	if (str.indexOf("ӰƬ��С") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("�n����С") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("��С�r�g") >= 0)
    	{
    		return true;
    	}
    	return false;
    }
    private boolean isFilmFormat(String str)
    {
    	if (str.indexOf("ӰƬ��ʽ") >= 0)
    	{
    		return true;
    	}
    	
    	if (str.indexOf("�ļ����") >= 0)
    	{
    		return true;
    	}
    	
    	if (str.indexOf("�ļ�����") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("�n��e") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("��ʽ����") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("��ʽ���") >= 0)
    	{
    		return true;
    	}
    	return false;
    }
    private boolean isFilmMosaic(String str)
    {
    	if (str.indexOf("�дa�o�a") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("��������") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("�Ƿ��дa") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("�Ƿ�����") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("ӰƬe") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("�У��o�a") >= 0)
    	{
    		return true;
    	}
    	return false;
    }
    
    private boolean isHash(String str)
    {
    	if (str.indexOf("��֤����") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("��C̖�a") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("�� �� ��") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("��������") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("��Cȫ�a") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("��֤����") >= 0)
    	{
    		return true;
    	}
    	if (str.indexOf("�� ϣ У") >= 0)
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
