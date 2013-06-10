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
import java.util.Calendar;
import java.util.List;

import com.simplelife.seeds.server.db.DaoWrapper;
import com.simplelife.seeds.server.db.LogId;
import com.simplelife.seeds.server.db.OperationLog;
import com.simplelife.seeds.server.db.PreviewPic;
import com.simplelife.seeds.server.db.Seed;
import com.simplelife.seeds.server.json.JsonCommandSeedsReq;
import com.simplelife.seeds.server.json.JsonCommandSeedsStatusReq;
import com.simplelife.seeds.server.parser.HtmlParser;
import com.simplelife.seeds.server.util.DateUtil;
import com.simplelife.seeds.server.util.OperationLogUtil;

import net.sf.json.JSONObject;

import javassist.bytecode.Descriptor.Iterator;

public class Test {
	public static void main(String[] args)
	{
		testSave();
		testQuery();
		testHtmlParse();
		testSeedReq();
		testStrBuilder();
		testSeedStatusReq();
		testDateFunctions();
		testRangeHtmlParse();
		testOperationLog();
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
		
		parser.setstartDate("2013-04-20");
		parser.setendDate("2013-05-21");
		parser.setbaseLink("http://174.123.15.31/forumdisplay.php?fid=55&page={page}");
		parser.setPageEnd(1);
		parser.setPageEnd(10);
		
		parser.Parse();
		
	}
	private static void testDateFunctions()
	{
		//System.out.println(DateUtil.getDaysBetween("2013-5-3", "2013-5-8"));
		//System.out.println(DateUtil.getNextTaskTrigger(20).toString());
		//System.out.println(DateUtil.getDaysFromToday("2013-06-01"));
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
	
	private static void testSeedStatusReq()
	{
		SeedsServlet servlet = new SeedsServlet();
		String command = "{\n    \"command\": \"SeedsUpdateStatusByDatesRequest\",\n    \"paramList\": {\n        \"datelist\": [\n            \"2013-05-14\",\n            \"2013-05-17\",\n            \"2013-05-18\"\n        ]\n    }\n}";
		JSONObject jsonObj = servlet.createJsonObject(command);
		
		JsonCommandSeedsStatusReq req = new JsonCommandSeedsStatusReq();
		PrintWriter out;
		try {
			out = new PrintWriter("d:/SeedsUpdateStatusByDatesResponse.txt");
			req.Execute(jsonObj, out);
			out.flush();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
	}
	
	private static void testSeedReq()
	{
		SeedsServlet servlet = new SeedsServlet();
		String command = "{\n    \"command\": \"SeedsByDatesRequest\",\n    \"paramList\": {\n        \"datelist\": [\n            \"2013-05-14\",\n            \"2013-05-15\",\n            \"2013-05-17\"\n        ]\n    }\n}";
		JSONObject jsonObj = servlet.createJsonObject(command);
		
		JsonCommandSeedsReq req = new JsonCommandSeedsReq();
		PrintWriter out;
		try {
			out = new PrintWriter("d:/SeedsByDatesResponse.txt");
			req.Execute(jsonObj, out);
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
			System.err.print("no data found");
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
		
		seed.setPublishDate(Calendar.getInstance().getTime().toString());
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
		
		DaoWrapper.save(seed);
		
		//DaoWrapper.getInstance().Delete(seed);
	}
}
