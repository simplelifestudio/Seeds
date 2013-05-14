package com.simplelife.seeds.server;

import java.io.PrintWriter;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

public class JsonCommandSeedsReq extends JsonCommandBase {
	private final static String _jsonCommandKeyword = "command";
	private final static String _jsonParaListKeyword = "paramList";
	private final static String _jsonDateListKeyword = "datelist";
	private final static String _jsonCommandSeedsByDatesRes = "SeedsByDatesResponse";
	
	private Logger _logger = Logger.getLogger("JsonCommandSeedsReq");
	
	@Override
	public void Execute(JSONObject jsonObj, PrintWriter out) {
		String strDateList = jsonObj.getString(_jsonParaListKeyword); 
		JSONObject dateObj = JSONObject.fromObject(strDateList);
		
		if (dateObj == null)
		{
			_logger.log(Level.SEVERE, "Invalid SeedsUpdateStatusByDatesRequest command received: " + jsonObj.toString());
			responseInvalidRequest(out);
			return;
		}
		
		JSONArray dateList = dateObj.getJSONArray(_jsonDateListKeyword);
		if (dateList == null || dateList.size() == 0)
		{
			_logger.log(Level.SEVERE, "Invalid SeedsUpdateStatusByDatesRequest command received: " + jsonObj.toString());
			responseInvalidRequest(out);
			return;	
		}
		
		responseNormalRequest(dateList, out);
	}
	
	private void responseNormalRequest(JSONArray dateList, PrintWriter out)
	{
		StringBuilder strBuilder = new StringBuilder();

		responseJsonHeader(strBuilder);
		
		String strDate;
		int size = dateList.size();
		for (int i = 0; i < size; i++)
		{
			strDate = dateList.getString(i);
			responseSeeds(strDate, strBuilder, (i < size-1));
		}
		strBuilder.deleteCharAt(strBuilder.length() - 2);      // remove , for last date
		strBuilder.append("}\n}");
		
		out.write(strBuilder.toString());
	}
	private void responseInvalidRequest(PrintWriter out)
	{
		StringBuilder strBuilder = new StringBuilder();
		strBuilder.append("}");
		out.write(strBuilder.toString());
	}
	
	
	private void responseJsonHeader(StringBuilder strBuilder)
	{
		strBuilder.append("{\n");
		strBuilder.append("\"");
		strBuilder.append(_jsonCommandKeyword);
		strBuilder.append("\":\"");
		strBuilder.append(_jsonCommandSeedsByDatesRes);
		strBuilder.append("\",\n");
		
		strBuilder.append("\"");
		strBuilder.append(_jsonParaListKeyword);
		strBuilder.append("\":{\n");
	}
	
	private void responseSeeds(String strDate, StringBuilder strBuilder, boolean lastOne)
	{
		responseJsonHeader(strBuilder);
		
		strBuilder.append("\"");
		strBuilder.append(strDate);
		strBuilder.append("\":[\n");
		responseSeedDetails(strDate, strBuilder);
		strBuilder.append("],\n");
	}
	
	private void responseSeedDetails(String strDate, StringBuilder strBuilder)
	{
		String sql = "Select seedId,type,source,publishDate,name,size,format, torrentLink, hash,mosaic, memo from seed";
		List<Seed> seeds = DaoWrapper.getInstance().query(sql, Seed.class);
		Iterator<Seed> it = seeds.iterator();
		Seed seed;
		while (it.hasNext())
		{
			strBuilder.append("{\n");
			seed = it.next();
			responseOneSeedFields(seed, strBuilder);
			responsePictureLinks(seed.getSeedId(), strBuilder);
			strBuilder.append("},\n");
		}
		
	}
	
	private void responsePictureLinks(Long seedId, StringBuilder strBuilder)
	{
		strBuilder.append("\"piclinks\":[\n");
		String sql = "select pictureId, seedId, pictureLink, memo " +
				"from PreviewPic where seedId = " + seedId.toString()+
				" order by pictureId";
		
		List<PreviewPic> pics= DaoWrapper.getInstance().query(sql, PreviewPic.class);
		Iterator<PreviewPic> it = pics.iterator();
		PreviewPic prePic;
		while (it.hasNext())
		{
			prePic = it.next();
			strBuilder.append("\"");
			strBuilder.append(prePic.getPictureLink());
			strBuilder.append("\",\n");
		}
		strBuilder.deleteCharAt(strBuilder.length() - 1);
		strBuilder.append("\n]\n");
	}
	
	private void responseOneSeedFields(Seed seed, StringBuilder strBuilder)
	{
		if ((seed.getType() != null) && (seed.getType().length() > 0))
		{
			strBuilder.append("\"type\":\"");
			strBuilder.append(seed.getType());
			strBuilder.append("\",\n");
		}
		
		if ((seed.getSource() != null) && (seed.getSource().length() > 0))
		{
			strBuilder.append("\"source\":\"");
			strBuilder.append(seed.getSource());
			strBuilder.append("\",\n");
		}
		
		if ((seed.getPublishDate() != null) && (seed.getPublishDate().length() > 0))
		{
			strBuilder.append("\"publishDate\":\"");
			strBuilder.append(seed.getPublishDate());
			strBuilder.append("\",\n");
		}
		
		if ((seed.getName() != null) && (seed.getName().length() > 0))
		{
			strBuilder.append("\"name\":\"");
			strBuilder.append(seed.getName());
			strBuilder.append("\",\n");
		}
		
		if ((seed.getSize() != null) && (seed.getSize().length() > 0))
		{
			strBuilder.append("\"size\":\"");
			strBuilder.append(seed.getSize());
			strBuilder.append("\",\n");
		}
		
		if ((seed.getFormat() != null) && (seed.getFormat().length() > 0))
		{
			strBuilder.append("\"format\":\"");
			strBuilder.append(seed.getFormat());
			strBuilder.append("\",\n");
		}
		
		if ((seed.getTorrentLink() != null) && (seed.getTorrentLink().length() > 0))
		{
			strBuilder.append("\"torrentLink\":\"");
			strBuilder.append(seed.getTorrentLink());
			strBuilder.append("\",\n");
		}
		
		if ((seed.getHash() != null) && (seed.getHash().length() > 0))
		{
			strBuilder.append("\"hash\":\"");
			strBuilder.append(seed.getHash());
			strBuilder.append("\",\n");
		}
		
		if ((seed.getMosaic() != null) && (seed.getMosaic().length() > 0))
		{
			strBuilder.append("\"mosaic\":\"");
			strBuilder.append(seed.getMosaic());
			strBuilder.append("\",\n");
		}
		
		if ((seed.getMemo() != null) && (seed.getMemo().length() > 0))
		{
			strBuilder.append("\"memo\":\"");
			strBuilder.append(seed.getMemo());
			strBuilder.append("\",\n");
		}
		
	}
}
