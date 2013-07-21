/**
 * Test.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server;

import java.io.File;
import java.io.PrintWriter;
import java.util.List;
import java.util.logging.Level;

import net.sf.json.JSONObject;

import org.apache.http.NameValuePair;

import com.simplelife.seeds.server.db.RssUtil;
import com.simplelife.seeds.server.db.Seed;
import com.simplelife.seeds.server.db.SeedCaptureLog;
import com.simplelife.seeds.server.db.SeedPicture;
import com.simplelife.seeds.server.json.IJsonRequest;
import com.simplelife.seeds.server.json.JsonRequestFactory;
import com.simplelife.seeds.server.parser.HtmlNodeVisitor;
import com.simplelife.seeds.server.parser.HtmlParser;
import com.simplelife.seeds.server.parser.TorrentDownloader;
import com.simplelife.seeds.server.util.DBExistResult;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.DateUtil;
import com.simplelife.seeds.server.util.EncryptUtil;
import com.simplelife.seeds.server.util.ErrorCode;
import com.simplelife.seeds.server.util.HttpUtil;
import com.simplelife.seeds.server.util.JsonKey;
import com.simplelife.seeds.server.util.JsonUtil;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.OperationCode;
import com.simplelife.seeds.server.util.OperationLogUtil;
import com.simplelife.seeds.server.util.SqlUtil;
import com.simplelife.seeds.server.util.TableColumnName;
import com.simplelife.seeds.server.util.TableName;

public class Test {
	public static void main(String[] args)
	{
	    //LogUtil.setLevel(Level.WARNING);
	    //HttpUtil.setHttpProxy("87.254.212.120", 8080);
	    //HttpUtil.setHostIP("127.0.0.1");
	    //HttpUtil.setHttpPort(8080);
	    
	    //testLogUtil();
	    //testEncrypt();
	    
	    // =========DB related=========
	    //testSave();
		//testQuery();
	    //testOperationLog();
	    //testCaptureLog();
		
	    // =========web related=========
	    //testRangeHtmlParse();
	    testHtmlParse();
	    //testSeedCaptureTask();
	    //testTorrentDownload();
	    //testHtmlNodeVisitor();
		//testRssContent();
        
	    // =========JSON related=========
	    //testJsonCommandFactory();
	    //testJsonAlohaReq();
	    //testJsonSeedStatusReq();
	    //testJsonSeedReq();
	    //testJsonSeedToCartReq();
	    
		
	    // =========Base Functions=========
		//testDateFunctions();
	    //testGetParaListByLink();
	    //testSeedCaptureTaskTimer();
		//testTaskTrigger();
	    //testSeedCaptureTaskRun();
		
		System.exit(0);
	}
	
	private static void testSeedCaptureTaskRun()
	{
	    SeedCaptureTask task = new SeedCaptureTask();
	    task.run();
	    
	    TorrentCheckTask task2 = new  TorrentCheckTask();
	    task2.run();
	    
	    File file = new File("E:\\work\\tomcat\\webapps/torrent");
	    task2.checkAndDeleteFile(file);
	}

	private static void testTaskTrigger()
	{
		System.out.print(DateUtil.getTaskTrigger(20, false).toString() + "\n");
		System.out.print(DateUtil.getTaskTrigger(21, false).toString() + "\n");
		System.out.print(DateUtil.getTaskTrigger(22, false).toString() + "\n");
	}
	
	private static void testHtmlNodeVisitor()
	{
	    HtmlNodeVisitor vistor = new HtmlNodeVisitor(true, false);
	    
	    String sTemp = "fjajuijkl;k\"fjdkajfkdlj;";
	    System.out.print("before format: " + sTemp + "\n");
	    System.out.print("before format: " + vistor.removePreTitle(sTemp)+ "\n");
	    
	    sTemp = "fjajuijkl[\"fjdkajfkdlj;";
        System.out.print("before format: " + sTemp + "\n");
        System.out.print("before format: " + vistor.removePreTitle(sTemp)+ "\n");
        
        sTemp = "aaaa,{\"[aa]aaa[aa;a,,a;aaa:aaaa";
        System.out.print("before format: " + sTemp + "\n");
        System.out.print("before format: " + vistor.removePreTitle(sTemp)+ "\n");
	    
	    
	}
	private static void testSeedCaptureTaskTimer()
	{
	    Level level = LogUtil.getLevel();
	    LogUtil.setLevel(Level.INFO);
	    SeedCaptureListener listner = new SeedCaptureListener();
	    try
        {
	        listner.scheduleSeedCaptureTask(DateUtil.getNowDate(), 5);
            Thread.sleep(3000);
            
            listner.scheduleSeedCaptureTask(DateUtil.getNowDate(), 5);
            Thread.sleep(3000);
            
            listner.scheduleSeedCaptureTask(DateUtil.getNowDate(), 5);
            Thread.sleep(100000);
        } 
	    catch (InterruptedException e)
        {
            e.printStackTrace();
        }
	    LogUtil.setLevel(level);
	}
	
	private static void testCaptureLog()
	{
		String date = "2013-07-13";
		
		String sql = SqlUtil.getSelectCaptureLogSql(SqlUtil.getPublishDateCondition(date));
        List record = DaoWrapper.query(sql, SeedCaptureLog.class);
        
        SeedCaptureLog log = (SeedCaptureLog) record.get(0);
        if (log.getStatus() == 0) {
        	System.out.print(JsonKey.notReady);
        }
        if (log.getStatus() == 1) {
        	System.out.print(JsonKey.noUpdate);
        }
        else if (log.getStatus() == 2) {
        	System.out.print(JsonKey.ready);
        }
        else {
        	System.out.print(JsonKey.errorStatus);
        }
	}
	
	private static void testJsonCommandFactory()
	{
		System.out.print("==========Report Invalid Json command===========\n");
		String command = "{\n    \"id\": \"AlohaRequest_invalid\",\n    \"body\": {\n    \"content\":\"Hello Seeds Server!\"\n    }\n}";
	    testJsonCommand(command);
	}
	
	private static void testTorrentDownload()
	{
	    String link = "http://www.maxp2p.com/link.php?ref=Uaaugtsvoi";
	    String output = DateUtil.getToday() + ".torrent";
	    TorrentDownloader dl = new TorrentDownloader(link, output);
	    dl.run();
	}
	
	private static void testRssContent()
	{
		RssUtil rssUtil = new RssUtil();
	    System.out.print(rssUtil.browseRss("chen"));
	}
	
	private static void testGetParaListByLink()
	{
	    List <NameValuePair> params;
	    params = HttpUtil.getParaListByLink("fdsfsdafsd");
	    if (params != null)
	    {
	        LogUtil.severe("The result must be null");
	    }
	    
	    HttpUtil.getParaListByLink("http:");
	    if (params != null)
        {
            LogUtil.severe("The result must be null");
        }
	    
	    HttpUtil.getParaListByLink("http:?");
	    if (params != null)
        {
            LogUtil.severe("The result must be null");
        }
        
	    HttpUtil.getParaListByLink("http://aaa?=");
	    if (params != null)
        {
            LogUtil.severe("The result must be null");
        }
        
	    HttpUtil.getParaListByLink("http://aaa?ref=");
	    if (params != null)
        {
            LogUtil.severe("The result must be null");
        }
        
	    params = HttpUtil.getParaListByLink("http://aaa?ref=aa");
	    if (params == null)
        {
            LogUtil.severe("The result is null");
        }
	    else
	    {
	        LogUtil.info(params.toString());
	    }
        
	    params = HttpUtil.getParaListByLink("http://aaa?ref1=aa&ref2=bb");
	    if (params == null)
        {
            LogUtil.severe("The result is null");
        }
        else
        {
            LogUtil.info(params.toString());
        }
	}
	
	private static void testLogUtil()
	{
		System.out.print("Set log level to WARNING\n");
		LogUtil.setLevel(Level.WARNING);
		LogUtil.fine("Fine log information");
		LogUtil.info("info log information");
		LogUtil.severe("severe log information");
		LogUtil.warning("warning log information");
		
		System.out.print("Set log level to INFO\n");
		LogUtil.setLevel(Level.INFO);
		LogUtil.fine("Fine log information");
		LogUtil.info("info log information");
		LogUtil.severe("severe log information");
		LogUtil.warning("warning log information");
		
		System.out.print("Set log level to WARNING\n");
		LogUtil.setLevel(Level.WARNING);
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
		String plainText = "chen";
		
		System.out.print("\nMD5 of chen:\n");
		System.out.print(EncryptUtil.getMD5ofStr(plainText));
		
		System.out.print("\nMD5 of chen:\n");
		System.out.print(EncryptUtil.getMD5ofStr(plainText));
		
		System.out.print("\nRandom cartId:\n");
		System.out.print(EncryptUtil.getRamdomCartId());
		
		System.out.print("\nRandom cartId:\n");
		System.out.print(EncryptUtil.getRamdomCartId());
		
		System.out.print("\n");
	}
	
	private static void testOperationLog()
	{
		OperationLogUtil.captureTaskStarted("this is sample of link");
		OperationLogUtil.save(OperationCode.ALOHA_REQUEST, "Aloha Request Received");
	}
	
	private static void testRangeHtmlParse()
	{
		HtmlParser parser = new HtmlParser();
		List<String> keyList = parser.getkeyWordList();
		keyList.clear();
		keyList.add("最新BT合集");
		
		//parser.setstartDate(DateUtil.getDateStringByDayBack(3));
		//parser.setendDate(DateUtil.getToday());

        parser.setstartDate("2013-07-10");
        parser.setendDate("2013-07-17");

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
	
	private static void testJsonAlohaReq()
	{
	    System.out.print("\n\n==========Normal AlohaRequest==========\n");
	    String command = "{\n    \"id\": \"AlohaRequest\",\n    \"body\": {\n    \"content\":\"Hello Seeds Server!\"\n    }\n}";
	    testJsonCommand(command);
	    
	    System.out.print("\n\n==========Report id not found==========\n");
	    command = "{\n    \"command\": \"paramList\",\n    \"body\": {\n    \"content\":\"Hello Seeds Server!\"\n    }\n}";
        testJsonCommand(command);
	}
	
	private static void testJsonSeedToCartReq()
	{
		
		System.out.print("\n\n==========Normal request==========\n");
		String command = "{\n    \"id\": \"SeedsToCartRequest\",\n    \"body\": {\n    \"cartId\":\"chen\",\n    \"seedIdList\": [\n            \"1\",\n            \"2\",\n            \"9999\"\n        ]\n    }\n}";
		testJsonCommand(command);

		// No cartId
		System.out.print("\n\n==========No cartId, random ID to be generated==========\n");
		command = "{\n    \"id\": \"SeedsToCartRequest\",\n    \"body\": {\n   \"seedIdList\": []\n    }\n}";
		testJsonCommand(command);
				
		System.out.print("\n\n==========Normal request but all failed==========\n");
		command = "{\n    \"id\": \"SeedsToCartRequest\",\n    \"body\": {\n    \"cartId\":\"chen\",\n    \"seedIdList\": [\n            \"7777\",\n            \"8888\",\n            \"9999\"\n        ]\n    }\n}";
		testJsonCommand(command);
		
		System.out.print("\n\n==========Normal request and all succeed==========\n");
		command = "{\n    \"id\": \"SeedsToCartRequest\",\n    \"body\": {\n    \"cartId\":\"chen\",\n    \"seedIdList\": [\n            \"1\",\n            \"2\"        ]\n    }\n}";
		testJsonCommand(command);
		
		// empty cartId
		System.out.print("\n\n==========Random cartId to be generated==========\n");
		command = "{\n    \"id\": \"SeedsToCartRequest\",\n    \"body\": {\n    \"cartId\":\"\",\n    \"seedIdList\": [\n            \"1\",\n            \"2\",\n            \"9999\"\n        ]\n    }\n}";
		testJsonCommand(command);
		
		// No cartId
		System.out.print("\n\n==========No cartId, random ID to be generated==========\n");
		command = "{\n    \"id\": \"SeedsToCartRequest\",\n    \"body\": {\n   \"seedIdList\": [\n            \"1\",\n            \"2\",\n            \"9999\"\n        ]\n    }\n}";
		testJsonCommand(command);
		
		// No seedIdList
		System.out.print("\n\n==========Report error of no seedIdList==========\n");
		command = "{\n    \"id\": \"SeedsToCartRequest\",\n    \"body\": {\n    \"cartId\":\"\" }\n}";
		testJsonCommand(command);
		
		System.out.print("\n\n==========Empty seedIdList, response normally with generated cartId==========\n");
		command = "{\n    \"id\": \"SeedsToCartRequest\",\n    \"body\": {\n    \"cartId\":\"\", \"seedIdList\": [] }\n}";
		testJsonCommand(command);

		// Invalid body
		System.out.print("\n\n==========Report error of no body==========\n");
		command = "{\n    \"id\": \"SeedsToCartRequest\",\n    \"paramList\": {\n    \"cartId\":\"chen\",\n    \"seedIdList\": [\n            \"aaa\",\n            \"bbb\",\n            \"9999\"\n        ]\n    }\n}";
        testJsonCommand(command);
		
        // Invalid id
        System.out.print("\n\n==========Report error of no id==========\n");
		command = "{\n    \"command\": \"SeedsToCartRequest\",\n    \"paramList\": {\n    \"cartId\":\"chen\",\n    \"seedIdList\": [\n            \"1\",\n            \"2\",\n            \"9999\"\n        ]\n    }\n}";
        testJsonCommand(command);
        
        System.out.print("\n\n==========Report error of invalid seedId==========\n");
		command = "{\n    \"id\": \"SeedsToCartRequest\",\n    \"body\": {\n    \"cartId\":\"chen\",\n    \"seedIdList\": [\n            \"111\",\n            \"bbb\",\n            \"9999\"\n        ]\n    }\n}";
        testJsonCommand(command);
        
        System.out.print("\n\n==========Report error of invalid seedId==========\n");
		command = "{\n    \"id\": \"SeedsToCartRequest\",\n    \"body\": {\n    \"cartId\":\"chen\",\n    \"seedIdList\": [\n            \"0x111\",\n            \"bbb\",\n            \"9999\"\n        ]\n    }\n}";
        testJsonCommand(command);
        
		// No cartId, empty seedId
		System.out.print("\n\n==========Report error of empty seedId==========\n");
		command = "{\n    \"id\": \"SeedsToCartRequest\",\n    \"body\": {\n   \"seedIdList\": [\"1111\", \"\"]\n    }\n}";
		testJsonCommand(command);
		
		
		System.out.print("\n\n==========Report error of too long cartId==========\n");
        command = "{\n    \"id\": \"SeedsToCartRequest\",\n    \"body\": {\"cartId\":\"123456789012345678901234567890123\"\n   \"seedIdList\": [\"1111\", \"\"]\n    }\n}";
        testJsonCommand(command);
	}
	
	private static void testJsonSeedStatusReq()
	{
		System.out.print("\n\n==========Normal request==========\n");
		String command = "{\n    \"id\": \"SeedsUpdateStatusByDatesRequest\",\n    \"body\": {\n        \"dateList\": [\n            \"2013-05-14\",\n            \"2013-05-17\",\n            \"2013-05-18\"\n        ]\n    }\n}";
		testJsonCommand(command);
		
		System.out.print("\n\n==========Normal request but all invalid date==========\n");
		command = "{\n    \"id\": \"SeedsUpdateStatusByDatesRequest\",\n    \"body\": {\n        \"dateList\": [\n            \"2014-05-14\",\n            \"2014-05-17\",\n            \"2014-05-18\"\n        ]\n    }\n}";
		testJsonCommand(command);
		
		// empty dateList
		System.out.print("\n\n==========Report error of no dateList==========\n");
		command = "{\n    \"id\": \"SeedsUpdateStatusByDatesRequest\",\n    \"body\": {\n        \"dateList\": [\n]\n    }\n}";
		testJsonCommand(command);
		
		// No dateList
		System.out.print("\n\n==========Report error of no dateList==========\n");
		command = "{\n    \"id\": \"SeedsUpdateStatusByDatesRequest\",\n    \"body\": {\n        }\n}";
		testJsonCommand(command);
		
		// Invalid body
		System.out.print("\n\n==========Report error of no body==========\n");
		command = "{\n    \"id\": \"SeedsUpdateStatusByDatesRequest\",\n    \"paramList\": {\n        \"dateList\": [\n            \"2013-05-14\",\n            \"2013-05-17\",\n            \"2013-05-18\"\n        ]\n    }\n}";
        testJsonCommand(command);
		
        // Invalid id
        System.out.print("\n\n==========Report error of no id==========\n");
        command = "{\n    \"id_invalid\": \"SeedsUpdateStatusByDatesRequest\",\n    \"body\": {\n        \"dateList\": [\n            \"2013-05-14\",\n            \"2013-05-17\",\n            \"2013-05-18\"\n        ]\n    }\n}";
        testJsonCommand(command);
        
        System.out.print("\n\n==========Test handle of error handling==========\n");
        String date = "2013-06-17";
        String sql = SqlUtil.getSelectCaptureLogSql("publishDate = '" + date + "'");
        if (DaoWrapper.exists(sql) !=  DBExistResult.existent)
        {
        	System.out.print("Error: record of " + date + " is nonexistent in DB");
        	return;
        }
        
        // Invalid id
        System.out.print("\n\n==========Report error of invalid date==========\n");
        command = "{\n    \"id\": \"SeedsUpdateStatusByDatesRequest\",\n    \"body\": {\n        \"dateList\": [\n            \"2013-5-14\",\n            \"2013-05-17\",\n            \"2013-05-18\"\n        ]\n    }\n}";
        testJsonCommand(command);
        
        System.out.print("\n\n==========status == 0, not ready ==========\n");
        sql = "update " + TableName.SeedCaptureLog + " set " + TableColumnName.status + " = 0 where " + TableColumnName.publishDate + " = '" + date + "'";
        DaoWrapper.executeSql(sql);
        command = "{\n    \"id\": \"SeedsUpdateStatusByDatesRequest\",\n    \"body\": {\n        \"dateList\": [\n            \""+ date + "\"\n]\n    }\n}";
		testJsonCommand(command);
		
		System.out.print("\n\n==========status == 1, no update ==========\n");
        sql = "update " + TableName.SeedCaptureLog + " set " + TableColumnName.status + " = 1 where " + TableColumnName.publishDate + " = '" + date + "'";
        DaoWrapper.executeSql(sql);
        command = "{\n    \"id\": \"SeedsUpdateStatusByDatesRequest\",\n    \"body\": {\n        \"dateList\": [\n            \""+ date + "\"\n]\n    }\n}";
		testJsonCommand(command);
		
		System.out.print("\n\n==========status == 2, ready ==========\n");
        sql = "update " + TableName.SeedCaptureLog + " set " + TableColumnName.status + " = 2 where " + TableColumnName.publishDate + " = '" + date + "'";
        DaoWrapper.executeSql(sql);
        command = "{\n    \"id\": \"SeedsUpdateStatusByDatesRequest\",\n    \"body\": {\n        \"dateList\": [\n            \""+ date + "\"\n]\n    }\n}";
		testJsonCommand(command);
		
		System.out.print("\n\n==========status == 3, abnormal date ==========\n");
        sql = "update " + TableName.SeedCaptureLog + " set " + TableColumnName.status + " = 3 where " + TableColumnName.publishDate + " = '" + date + "'";
        DaoWrapper.executeSql(sql);
        command = "{\n    \"id\": \"SeedsUpdateStatusByDatesRequest\",\n    \"body\": {\n        \"dateList\": [\n            \""+ date + "\"\n]\n    }\n}";
		testJsonCommand(command);
	}
	
	private static void testJsonSeedReq()
	{
		System.out.print("\n\n==========Normal request==========\n");
		String command = "{\n    \"id\": \"SeedsByDatesRequest\",\n    \"body\": {\n        \"dateList\": [\n            \"2013-06-28\",\n            \"2013-05-17\",\n            \"2013-05-18\"\n        ]\n    }\n}";
		testJsonCommand(command);
		
		System.out.print("\n\n==========Normal request but all invalid date==========\n");
		command = "{\n    \"id\": \"SeedsByDatesRequest\",\n    \"body\": {\n        \"dateList\": [\n            \"2014-05-14\",\n            \"2014-05-17\",\n            \"2014-05-18\"\n        ]\n    }\n}";
		testJsonCommand(command);
		
		// empty dateList
		System.out.print("\n\n==========Report error of no dateList==========\n");
		command = "{\n    \"id\": \"SeedsByDatesRequest\",\n    \"body\": {\n        \"dateList\": [\n]\n    }\n}";
		testJsonCommand(command);
		
		// No dateList
		System.out.print("\n\n==========Report error of no dateList==========\n");
		command = "{\n    \"id\": \"SeedsByDatesRequest\",\n    \"body\": {\n        }\n}";
		testJsonCommand(command);
		
		// Invalid body
		System.out.print("\n\n==========Report error of no body==========\n");
		command = "{\n    \"id\": \"SeedsByDatesRequest\",\n    \"paramList\": {\n        \"dateList\": [\n            \"2013-05-14\",\n            \"2013-05-17\",\n            \"2013-05-18\"\n        ]\n    }\n}";
        testJsonCommand(command);
		
        // Invalid id
        System.out.print("\n\n==========Report error of no id==========\n");
        command = "{\n    \"id_invalid\": \"SeedsByDatesRequest\",\n    \"body\": {\n        \"dateList\": [\n            \"2013-05-14\",\n            \"2013-05-17\",\n            \"2013-05-18\"\n        ]\n    }\n}";
        testJsonCommand(command);
        
        // Invalid id
        System.out.print("\n\n==========Report error of invalid date==========\n");
        command = "{\n    \"id\": \"SeedsByDatesRequest\",\n    \"body\": {\n        \"dateList\": [\n            \"2013-5-14\",\n            \"2013-05-17\",\n            \"2013-05-18\"\n        ]\n    }\n}";
        testJsonCommand(command);

	}
	
	private static void testJsonCommand(String command)
	{
	    JSONObject jsonObj = JsonUtil.createJsonObject(command);
        if (jsonObj == null)
        {
            return; 
        }
        
        
        PrintWriter out;
        try {
            out = new PrintWriter(System.out);
            
            IJsonRequest jsonCmd = JsonRequestFactory.CreateJsonCommand(out, jsonObj, "127.0.0.1");
            
            if (jsonCmd == null)
            {
            	out.flush();
                return; 
            }
            
            jsonCmd.Execute();
            out.flush();
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	private static void testHtmlParse()
	{
		HtmlParser parser = new HtmlParser();
		parser.setstartDate("2013-07-20");
		parser.setendDate("2013-07-20");
		parser.Parse();
	}
	
	private static void testQuery()
	{
		String sql = SqlUtil.getSelectSeedSql("");
		if (DaoWrapper.exists(sql) != DBExistResult.existent)
		{
			LogUtil.severe("no data found: " + sql);
			return;
		}
		
		List list = DaoWrapper.query(sql, Seed.class);
		if (list == null)
		{
			LogUtil.severe("Exception in DB connection, check DB configuration: " + sql);
			return;
		}
		java.util.Iterator iter = list.iterator();
		while (iter.hasNext())
		{
			//System.out.println(iter.next().getClass().toString());
			System.out.println(((Seed)iter.next()).getSeedId());
		}
		
		list = DaoWrapper.query(SqlUtil.getSelectSeedSql(TableColumnName.seedId + " = 12"), Seed.class);
		iter = list.iterator();
		while (iter.hasNext())
		{
			//System.out.println(iter.next().getClass().toString());
			System.out.println(((Seed)iter.next()).getSeedId());
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
		
		seed.setPublishDate(DateUtil.getToday());
		seed.setSize("size");
		seed.setSource("source");
		seed.setTorrentLink("torrentLink");
		seed.setType("type");
		
		SeedPicture pic = new SeedPicture();
		pic.setMemo("memo");
		pic.setPictureLink("pictureLink");
		seed.addPicture(pic);
		
		pic = new SeedPicture();
		pic.setMemo("memo2");
		pic.setPictureLink("pictureLink2");
		seed.addPicture(pic);
		
		pic = new SeedPicture();
		pic.setMemo("memo3");
		pic.setPictureLink("pictureLink3");
		seed.addPicture(pic);
		
		pic = new SeedPicture();
		pic.setMemo("memo4");
		pic.setPictureLink("pictureLink4");
		seed.addPicture(pic);
		
		DaoWrapper.save(seed);
		
		//DaoWrapper.getInstance().Delete(seed);
	}
}
