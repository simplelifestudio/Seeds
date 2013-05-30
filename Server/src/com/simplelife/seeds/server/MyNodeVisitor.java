package com.simplelife.seeds.server;

import java.text.SimpleDateFormat;
import java.util.Calendar;
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
	private String _publishDate;
	
	private enum AnalyzeStatus
	{
		Init, FilmInfo, Link;
	}
	
	public MyNodeVisitor(boolean recurseChildren, boolean recurseSelf)
	{
		super(recurseChildren, recurseSelf);
		//_logger.setLevel(Level.WARNING);
	}
	
	public void visitTag(Tag tag) 
	{
		if (_analyzeStatus != AnalyzeStatus.FilmInfo)
		{
			return;
		}
		
		if(isImageLink(tag))
    	{
			String picLink = getImageLink(tag.getText());
			//_logger.log(Level.INFO, picLink);
			_seed.addPicture(picLink);
    	}
    }
	
    public void visitStringNode (Text string)    {
    	String nodeText = string.getText();
    	nodeText = nodeText.replaceAll("&nbsp;", "");
    	nodeText = nodeText.trim();
    	
    	if (_analyzeStatus == AnalyzeStatus.Link)
    	{
    		_seed.setTorrentLink(nodeText);
    		//_logger.log(Level.INFO,"Torrent link�� " + link);
    		
    		if (!checkSeedForSave(_seed))
    		{
    			_logger.log(Level.WARNING, "Invalid seed info for save: " + _seed.toString());
    			return;
    		}
    		formatSeedForSave(_seed);
			DaoWrapper.getInstance().save(_seed);
			_logger.log(Level.INFO, "Saved seed to DB: \n" + _seed.toString());
			return;
    	}
    		
    	if (isFilmName(nodeText))
    	{
    		_analyzeStatus = AnalyzeStatus.FilmInfo;
    		_seed = new Seed();
    		_seed.setName(nodeText);
    		_seed.setType("AV");
    		_seed.setSource("���䰮");
    		
    		if (_publishDate == null || _publishDate.length() == 0)
    		{
    			String fmt = "yyyy-MM-dd";
    			SimpleDateFormat sdf = new SimpleDateFormat(fmt);
    			sdf.format(Calendar.getInstance().getTime());
    			_publishDate = sdf.format(Calendar.getInstance().getTime());
    		}
    		_seed.setPublishDate(_publishDate);
    		//_logger.log(Level.INFO,"\n\nӰƬ���ƣ�" + string.getText());
    	}
    	else if(isFilmFormat(nodeText))
    	{
    		_seed.setFormat(nodeText);
    	}
    	else if(isFilmSize(nodeText))
    	{
    		_seed.setSize(nodeText);
    	}
    	else if(isFilmMosaic(nodeText))
    	{
    		_seed.setMosaic(nodeText);
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
    		_seed.setHash(nodeText);
    	}
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
    
    public String removePreTitle(String field)
    {
		if (field == null) {
			return null;
		}
		
		int index = field.indexOf("]");
		if (index > 0) {
			field = field.substring(index + 1).trim();
		}
		else
		{
			index = field.indexOf("��");
			if (index > 0) {
				field = field.substring(index + 1).trim();
			}
		}
		
		index = field.indexOf(":");
		if (index == 0) {
			field = field.substring(1).trim();
		}
		
		index = field.indexOf("��");
		if (index == 0) {
			field = field.substring(1).trim();
		}
		
		return field;
    }
    private void formatSeedForSave(Seed seed)
    {
		if (seed.getFormat() != null) {
			seed.setFormat(removePreTitle(seed.getFormat()));
		}

		if (seed.getHash() != null) {
			seed.setHash(removePreTitle(seed.getHash()));
		}

		if (seed.getMemo() != null) {
			seed.setMemo(removePreTitle(seed.getMemo()));
		}

		if (seed.getMosaic() != null) {
			seed.setMosaic(removePreTitle(seed.getMosaic()));
		}

		if (seed.getName() != null) {
			seed.setName(removePreTitle(seed.getName()));
		}

		if (seed.getSize() != null) {
			seed.setSize(removePreTitle(seed.getSize()));
		}

		if (seed.getType() != null) {
			seed.setType(removePreTitle(seed.getType()));
		}
    }
    
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

	/**
	 * @return the _publishDate
	 */
	public String getpublishDate() {
		return _publishDate;
	}

	/**
	 * @param _publishDate the _publishDate to set
	 */
	public void setpublishDate(String publishDate) {
		this._publishDate = publishDate;
	}

}
