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
import com.simplelife.seeds.server.db.PreviewPic;
import com.simplelife.seeds.server.db.Seed;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.LogUtil;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

public class JsonCommandSeedsReq extends JsonCommandBase
{
    private final static String jsonCommandKeyword = "command";
    private final static String jsonParaListKeyword = "paramList";
    private final static String jsonDateListKeyword = "dateList";
    private final static String jsonCommandSeedsByDatesRes = "SeedsByDatesResponse";

    @Override
    public void Execute(JSONObject jsonObj, PrintWriter out)
    {
        try {
            LogUtil.info("Start to Execute SeedsUpdateStatusByDatesRequest");
            String strParaList = jsonObj.getString(jsonParaListKeyword);
            JSONObject paraObj = JSONObject.fromObject(strParaList);

            if (paraObj == null) {
                LogUtil.severe("Invalid SeedsUpdateStatusByDatesRequest command received: " + jsonObj.toString());
                responseInvalidRequest(out);
                return;
            }

            JSONArray dateList = paraObj.getJSONArray(jsonDateListKeyword);
            if (dateList == null || dateList.size() == 0) {
                LogUtil.severe("Invalid SeedsUpdateStatusByDatesRequest command received: " + jsonObj.toString());
                responseInvalidRequest(out);
                return;
            }

            responseNormalRequest(dateList, out);
        } catch (Exception e) {
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
        strBuilder.append("}\n}");

        out.write(strBuilder.toString());
        LogUtil.info("Response SeedsUpdateStatusByDatesRequest successfully: " + strDateList);

        /*
         * if (strBuilder.length() > 200) { LogUtil.info(strBuilder.toString());
         * } else { LogUtil.info(strBuilder.substring(0, 200)); }
         */
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
        strBuilder.append(jsonCommandKeyword);
        strBuilder.append("\":\"");
        strBuilder.append(jsonCommandSeedsByDatesRes);
        strBuilder.append("\",\n");

        strBuilder.append("\"");
        strBuilder.append(jsonParaListKeyword);
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
        String sql = "Select seedId,type,source,publishDate,name,size,format, torrentLink, hash,mosaic, memo " + " from Seed"
                + " where publishDate = '" + strDate + "'";
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
	        strBuilder.deleteCharAt(strBuilder.length() - 2);
        }
    }

    private void responsePictureLinks(Long seedId, StringBuilder strBuilder)
    {
        strBuilder.append("\"piclinks\":[\n");
        String sql = "select pictureId, seedId, pictureLink, memo " + "from PreviewPic where seedId = " + seedId.toString()
                + " order by pictureId";

        List<PreviewPic> pics = DaoWrapper.query(sql, PreviewPic.class);
        
        if (pics != null)
        {
	        Iterator<PreviewPic> it = pics.iterator();
	        PreviewPic prePic;
	        while (it.hasNext()) {
	            prePic = it.next();
	            strBuilder.append("\"");
	            strBuilder.append(prePic.getPictureLink());
	            strBuilder.append("\",\n");
	        }
	        strBuilder.deleteCharAt(strBuilder.length() - 2); // Remove last ","
        }
        strBuilder.append("]\n");
    }

    private void responseOneSeedFields(Seed seed, StringBuilder strBuilder)
    {
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
