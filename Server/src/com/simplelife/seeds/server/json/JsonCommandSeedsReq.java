/**
 * JsonCommandSeedsReq.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.json;

import java.io.PrintWriter;
import java.util.Iterator;
import java.util.List;
import com.simplelife.seeds.server.db.SeedPicture;
import com.simplelife.seeds.server.db.Seed;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.ErrorCode;
import com.simplelife.seeds.server.util.JsonKey;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.SqlUtil;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

public class JsonCommandSeedsReq extends JsonCommandBase
{
    @Override
    public void Execute(JSONObject jsonObj, PrintWriter out)
    {
    	super.Execute(jsonObj, out);
    	
        try {
            LogUtil.info("Start to Execute SeedsUpdateStatusByDatesRequest");
            String strParaList = jsonObj.getString(JsonKey.body);
            JSONObject paraObj = JSONObject.fromObject(strParaList);

            if (paraObj == null) {
                String err = "Invalid Json format, " + JsonKey.body +" can't be found: " + jsonObj.toString();
                LogUtil.severe(err);
                responseInvalidRequest(ErrorCode.IllegalMessageBody, err);
                return;
            }

            JSONArray dateList = paraObj.getJSONArray(JsonKey.dateList);
            if (dateList == null || dateList.size() == 0) {
                String err = "Invalid Json format, " + JsonKey.dateList +" can't be found or may be empty.";
                LogUtil.severe(err + jsonObj.toString());
                responseInvalidRequest(ErrorCode.IllegalMessageBody, err);
                return;
            }

            responseNormalRequest(dateList, out);
        } catch (Exception e) {
        	responseInvalidRequest(ErrorCode.IllegalMessageBody, e.getMessage());
            LogUtil.printStackTrace(e);
        }
    }

    private void responseNormalRequest(JSONArray dateList, PrintWriter out)
    {
        StringBuilder strBuilder = new StringBuilder();

        responseJsonHeader(strBuilder);

        String strDate;
        String strDateList = "[";
        int size = dateList.size();
        for (int i = 0; i < size; i++) {
            strDate = dateList.getString(i);
            strDateList += strDate + " ";
            responseSeeds(strDate, strBuilder, (i < size - 1));
        }

        strDateList = strDateList.trim();
        strDateList += "]";

        strBuilder.deleteCharAt(strBuilder.length() - 2); // remove , for last
                                                          // date
        strBuilder.append("}\n}\n");

        out.write(strBuilder.toString());
        LogUtil.info("Response SeedsUpdateStatusByDatesRequest successfully: " + strDateList);
    }

    @Override
    protected void responseJsonHeader(StringBuilder strBuilder)
    {
        strBuilder.append("{\n");
        strBuilder.append("\"");
        strBuilder.append(JsonKey.id);
        strBuilder.append("\":\"");
        strBuilder.append(JsonKey.commandSeedsByDatesResponse);
        strBuilder.append("\",\n");

        strBuilder.append("\"");
        strBuilder.append(JsonKey.body);
        strBuilder.append("\":{\n");
    }

    private void responseSeeds(String strDate, StringBuilder strBuilder, boolean lastOne)
    {
        strBuilder.append("\"");
        strBuilder.append(strDate);
        strBuilder.append("\":[\n");
        responseSeedDetails(strDate, strBuilder);
        strBuilder.append("],\n");
    }

    private void responseSeedDetails(String strDate, StringBuilder strBuilder)
    {
    	String sql = SqlUtil.getSelectSeedSql(SqlUtil.getPublishDateCondition(strDate));
        List<Seed> seeds = DaoWrapper.query(sql, Seed.class);
        
        if (seeds != null)
        {
	        Iterator<Seed> it = seeds.iterator();
	        Seed seed;
	        while (it.hasNext()) {
	            strBuilder.append("{\n");
	            seed = it.next();
	            responseOneSeedFields(seed, strBuilder);
	            responsePictureLinks(seed.getSeedId(), strBuilder);
	            strBuilder.append("},\n");
	        }
	        
	        if (seeds.size() > 0)
	        {
	        	strBuilder.deleteCharAt(strBuilder.length() - 2);
	        }
        }
    }

    private void responsePictureLinks(Long seedId, StringBuilder strBuilder)
    {
        String sql = SqlUtil.getSelectSeedPictureSql(SqlUtil.getSeedIdCondition(seedId));
        List<SeedPicture> pics = DaoWrapper.query(sql, SeedPicture.class);
        
        strBuilder.append("\"piclinks\":[\n");
        if (pics != null)
        {
	        Iterator<SeedPicture> it = pics.iterator();
	        SeedPicture prePic;
	        while (it.hasNext()) {
	            prePic = it.next();
	            strBuilder.append("\"");
	            strBuilder.append(prePic.getPictureLink());
	            strBuilder.append("\",\n");
	        }
	        if (pics.size() > 0)
	        {
	            strBuilder.deleteCharAt(strBuilder.length() - 2); // Remove last ","
	        }
        }
        strBuilder.append("]\n");
    }

    private void responseOneSeedFields(Seed seed, StringBuilder strBuilder)
    {
        responseField(Long.toString(seed.getSeedId()), "seedId", strBuilder);
        responseField(seed.getType(), "type", strBuilder);
        responseField(seed.getSource(), "source", strBuilder);
        responseField(seed.getPublishDate(), "publishDate", strBuilder);
        responseField(seed.getName(), "name", strBuilder);
        responseField(seed.getSize(), "size", strBuilder);
        responseField(seed.getFormat(), "format", strBuilder);
        responseField(seed.getTorrentLink(), "torrentLink", strBuilder);
        responseField(seed.getHash(), "hash", strBuilder);
        responseField(seed.getMosaic(), "mosaic", strBuilder);
        responseField(seed.getMemo(), "memo", strBuilder);
    }

    private void responseField(String field, String title, StringBuilder strBuilder)
    {
        if ((field != null) && (field.length() > 0)) {
            strBuilder.append("\"");
            strBuilder.append(title);
            strBuilder.append("\":\"");
            strBuilder.append(field);
            strBuilder.append("\",\n");
        }
    }
}
