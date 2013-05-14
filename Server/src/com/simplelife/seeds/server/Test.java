package com.simplelife.seeds.server;

import java.io.PrintWriter;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import net.sf.json.JSONObject;

import javassist.bytecode.Descriptor.Iterator;

public class Test {
	public static void main(String[] args)
	{
		//testSave();
		//testQuery();
		//testHtmlParse();
		//testJsonObj();
		testStrBuilder();
	}

	private static void testStrBuilder()
	{
		StringBuilder strBuilder = new StringBuilder();
		strBuilder.append("fdajfdjkfjdslk,");
		System.out.println(strBuilder.toString());
		
		strBuilder.deleteCharAt(strBuilder.length() - 1);
		System.out.println(strBuilder.toString());
		
	}
	private static void testJsonObj()
	{
		SeedsServlet servlet = new SeedsServlet();
		String command = "{\n    \"command\": \"SeedsByDatesRequest\",\n    \"paramList\": {\n        \"datelist\": [\n            \"2013-05-14\",\n            \"2013-04-15\",\n            \"2013-05-13\"\n        ]\n    }\n}";
		JSONObject jsonObj = servlet.createJsonObject(command);
		
		JsonCommandSeedsReq req = new JsonCommandSeedsReq();
		PrintWriter out = new PrintWriter(System.out);
		req.Execute(jsonObj, out);
	}
	
	private static void testHtmlParse()
	{
		HtmlParser parser = new HtmlParser();
		parser.Parse();
	}
	
	private static void testQuery()
	{
		if (DaoWrapper.getInstance().exists("select * from seed"))
		{
			System.err.print("no data found");
		}
		
		List list = DaoWrapper.getInstance().query("select * from seed", Seed.class);
		java.util.Iterator iter = list.iterator();
		while (iter.hasNext())
		{
			//System.out.println(iter.next().getClass().toString());
			System.out.println(((Seed)iter.next()).getSeedId());
		}
		
		list = DaoWrapper.getInstance().query("select * from PreviewPic where seedId = 12", PreviewPic.class);
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
		
		DaoWrapper.getInstance().save(seed);
		
		//DaoWrapper.getInstance().Delete(seed);
	}
}
