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
    		System.out.println("Torrent link��" + string.getText());
    		return;
    	}
    		
    	if (isFilmName(string.getText()))
    	{
    		_AnalyzeFlag = AnalyzeFlag.FilmInfo;
    		System.out.println("\n\nӰƬ���ƣ�" + string.getText());
    	}
    	else if(isFilmFormat(string.getText()))
    	{
    		System.out.println("ӰƬ��ʽ��" + string.getText());
    	}
    	else if(isFilmSize(string.getText()))
    	{
    		System.out.println("ӰƬ��С��" + string.getText());
    	}
    	else if(isFilmMosaic(string.getText()))
    	{
    		System.out.println("�������룺" + string.getText());
    	}
    	else if(isTorrentLink(string.getText()))
    	{
    		_AnalyzeFlag = AnalyzeFlag.Link;
    	}
    	else if(isHash(string.getText()))
    	{
    		System.out.println("��ϣУ�飺" + string.getText());
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
