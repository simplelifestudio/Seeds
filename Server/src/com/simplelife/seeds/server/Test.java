/**
 * Test.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.logging.Level;

import org.apache.http.HttpRequest;
import org.apache.http.NameValuePair;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.message.BasicNameValuePair;

import net.sf.json.JSONObject;
import com.simplelife.seeds.server.db.LogId;
import com.simplelife.seeds.server.db.PreviewPic;
import com.simplelife.seeds.server.db.RssUtil;
import com.simplelife.seeds.server.db.Seed;
import com.simplelife.seeds.server.json.IJsonCommand;
import com.simplelife.seeds.server.json.JsonCommandFactory;
import com.simplelife.seeds.server.json.JsonUtil;
import com.simplelife.seeds.server.parser.HtmlParser;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.DateUtil;
import com.simplelife.seeds.server.util.HttpUtil;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.OperationLogUtil;

public class Test {
	public static void main(String[] args)
	{
	    LogUtil.setLevel(Level.WARNING);
	    //HttpUtil.setHttpProxy("87.254.212.120", 8080);
	    
	    testHttpPost();
	    //testSave();
	    //testSeedReq();
	    //testRssContent();
	    
	    /*
	    
	    testRssContent();
	    testLogUtil();
	    testSeedCaptureTask();
	    testEncrypt();
	    testSeedRssReq();
	    testRssSubscribe();
	    
	    testSave();
		testQuery();
		testHtmlParse();
		testSeedReq();
		testStrBuilder();
		testSeedStatusReq();
		testDateFunctions();
		testRangeHtmlParse();
		testOperationLog();
		*/
	    System.exit(0);
	}

	private static void testRssContent()
	{
	    System.out.print(RssUtil.subscribe("chen"));
	}
	private static void testHttpPost()
	{
	    String link = "http://www.maxp2p.com/link.php?ref=Uaaugtsvoi";
	    int index = link.lastIndexOf("ref=");
	    if (index <=0)
	    {
	        LogUtil.warning("Invalid link: " + link);
	    }
	    
	    String ref = link.substring(index);
	    
	    List <NameValuePair> params = new ArrayList<NameValuePair>();
	    params.add(new BasicNameValuePair("ref", ref));
	    
		HttpUtil.post("http://www.maxp2p.com/load.php", params);
	}
	
	private static void testLogUtil()
	{
		LogUtil.setLevel(Level.WARNING);
		LogUtil.fine("Fine log information");
		LogUtil.info("info log information");
		LogUtil.severe("severe log information");
		LogUtil.warning("warning log information");
		
		LogUtil.setLevel(Level.INFO);
		LogUtil.fine("Fine log information");
		LogUtil.info("info log information");
		LogUtil.severe("severe log information");
		LogUtil.warning("warning log information");
	}
	
	private static void testSeedCaptureTask()
	{
       HtmlParser parser = new HtmlParser();
       parser.Parse();
       
       parser = new HtmlParser();
       parser.Parse();
	}
	
	private static void testEncrypt()
	{
		
		try { 
			String plainText = "chen";
			MessageDigest md = MessageDigest.getInstance("MD5"); 
			md.update(plainText.getBytes());  
			byte b[] = md.digest(); 

			int i; 

			StringBuffer buf = new StringBuffer(""); 
			for (int offset = 0; offset < b.length; offset++) { 
			i = b[offset]; 
			if(i<0) i+= 256; 
			if(i<16) 
			buf.append("0"); 
			buf.append(Integer.toHexString(i)); 
			} 

			System.out.println("result: " + buf.toString());//32位的加密 

			System.out.println("result: " + buf.toString().substring(8,24));//16位的加密 

			} catch (NoSuchAlgorithmException e) { 
			// TODO Auto-generated catch block 
			e.printStackTrace(); 
			} 
	}
	
	private static void testRssSubscribe()
	{
		System.out.print(RssUtil.subscribe("chen"));
	}
	
	private static void testOperationLog()
	{
		OperationLogUtil.captureTaskStarted("this is sample of link");
		OperationLogUtil.save(LogId.ALOHA_REQUEST, "Aloha Request Received");
	}
	
	private static void testRangeHtmlParse()
	{
		HtmlParser parser = new HtmlParser();
		List<String> keyList = parser.getkeyWordList();
		keyList.clear();
		keyList.add("最新BT合集");
		
		//parser.setstartDate(DateUtil.getDateStringByDayBack(3));
		//parser.setendDate(DateUtil.getToday());

        parser.setstartDate("2013-06-17");
        parser.setendDate("2013-06-17");

		parser.setbaseLink("http://174.123.15.31/forumdisplay.php?fid=55&page={page}");
		parser.setPageEnd(1);
		parser.setPageEnd(3);
		
		parser.Parse();
		
	}
	private static void testDateFunctions()
	{
		System.out.println(DateUtil.getDaysBetween("2013-5-3", "2013-5-8"));
		System.out.println(DateUtil.getTaskTrigger(20, false).toString());
		System.out.println(DateUtil.getDaysFromToday("2013-06-01"));
		System.out.println(DateUtil.getDaysFromToday("2014-05-01"));
		System.out.println(DateUtil.getDaysFromToday("2013-5-1"));
		System.out.println(DateUtil.getDaysFromToday("2013-*05-01"));
		System.out.println(DateUtil.getDaysFromToday("2012-05-01"));
		System.out.println(DateUtil.getToday());
		System.out.println(DateUtil.getDateStringByDayBack(5));
		System.out.println(DateUtil.getDateStringByDayBack(20));
	}
	private static void testStrBuilder()
	{
		StringBuilder strBuilder = new StringBuilder();
		strBuilder.append("fdajfdjkfjdslk,");
		System.out.println(strBuilder.toString());
		
		strBuilder.deleteCharAt(strBuilder.length() - 1);
		System.out.println(strBuilder.toString());
		
	}
	
	private static void testSeedRssReq()
	{
		String command = "{\n    \"command\": \"SeedsToCartRequest\",\n    \"paramList\": {\n    \"cartId\":\"chen\",\n    \"seedIdList\": [\n            \"1\",\n            \"2\",\n            \"9999\"\n        ]\n    }\n}";
		JSONObject jsonObj = JsonUtil.createJsonObject(command);
		if (jsonObj == null)
		{
			System.out.print("Invalid command");
			return; 
		}
		
		
		IJsonCommand jsonCmd = JsonCommandFactory.CreateJsonCommand(jsonObj, "127.0.0.1");
		
		if (jsonCmd == null)
		{
			System.out.print("Invalid command");
			return; 
		}
		
		PrintWriter out;
		try {
			out = new PrintWriter("d:/SeedsRssRequest.txt");
			jsonCmd.Execute(jsonObj, out);
			out.flush();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
	}
	
	private static void testSeedStatusReq()
	{
		String command = "{\n    \"command\": \"SeedsUpdateStatusByDatesRequest\",\n    \"paramList\": {\n        \"dateList\": [\n            \"2013-05-14\",\n            \"2013-05-17\",\n            \"2013-05-18\"\n        ]\n    }\n}";
		JSONObject jsonObj = JsonUtil.createJsonObject(command);
		if (jsonObj == null)
		{
			System.out.print("Invalid command");
			return; 
		}
		
		IJsonCommand jsonCmd = JsonCommandFactory.CreateJsonCommand(jsonObj, "127.0.0.1");
		
		if (jsonCmd == null)
		{
			System.out.print("Invalid command");
			return; 
		}
		
		PrintWriter out;
		try {
			out = new PrintWriter("d:/SeedsUpdateStatusByDatesResponse.txt");
			jsonCmd.Execute(jsonObj, out);
			out.flush();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
	}
	
	private static void testSeedReq()
	{
		String command = "{\n    \"command\": \"SeedsByDatesRequest\",\n    \"paramList\": {\n        \"dateList\": [\n            \"2013-05-14\",\n            \"2013-05-15\",\n            \"2013-05-17\"\n        ]\n    }\n}";
		JSONObject jsonObj = JsonUtil.createJsonObject(command);
		if (jsonObj == null)
		{
			System.out.print("Invalid command");
			return; 
		}
		
		IJsonCommand jsonCmd = JsonCommandFactory.CreateJsonCommand(jsonObj, "127.0.0.1");
		
		if (jsonCmd == null)
		{
			System.out.print("Invalid command");
			return; 
		}
		PrintWriter out;
		try {
			out = new PrintWriter("d:/SeedsByDatesResponse.txt");
			jsonCmd.Execute(jsonObj, out);
			out.flush();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
	}
	
	private static void testHtmlParse()
	{
		HtmlParser parser = new HtmlParser();
		parser.Parse();
	}
	
	private static void testQuery()
	{
		if (DaoWrapper.exists("select * from seed"))
		{
			LogUtil.severe("no data found");
			return;
		}
		
		List list = DaoWrapper.query("select * from seed", Seed.class);
		java.util.Iterator iter = list.iterator();
		while (iter.hasNext())
		{
			//System.out.println(iter.next().getClass().toString());
			System.out.println(((Seed)iter.next()).getSeedId());
		}
		
		list = DaoWrapper.query("select * from PreviewPic where seedId = 12", PreviewPic.class);
		iter = list.iterator();
		while (iter.hasNext())
		{
			//System.out.println(iter.next().getClass().toString());
			System.out.println(((PreviewPic)iter.next()).getPictureId());
		}
	}
	
	private static void testSave()
	{
		Seed seed = new Seed();
		seed.setSeedId(1);
		seed.setFormat("format");
		seed.setHash("hash");
		seed.setMemo("memo");
		seed.setMosaic("mosaic");
		seed.setName("name");
		
		seed.setPublishDate(DateUtil.getNow());
		seed.setSize("size");
		seed.setSource("source");
		seed.setTorrentLink("torrentLink");
		seed.setType("type");
		
		PreviewPic pic = new PreviewPic();
		pic.setMemo("memo");
		pic.setPictureLink("pictureLink");
		seed.addPicture(pic);
		
		pic = new PreviewPic();
		pic.setMemo("memo2");
		pic.setPictureLink("pictureLink2");
		seed.addPicture(pic);
		
		pic = new PreviewPic();
		pic.setMemo("memo3");
		pic.setPictureLink("pictureLink3");
		seed.addPicture(pic);
		
		pic = new PreviewPic();
		pic.setMemo("memo4");
		pic.setPictureLink("pictureLink4");
		seed.addPicture(pic);
		
		DaoWrapper.save(seed);
		
		//DaoWrapper.getInstance().Delete(seed);
	}
}
