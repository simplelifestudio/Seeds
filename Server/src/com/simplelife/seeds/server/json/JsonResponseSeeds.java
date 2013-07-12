/**
 * JsonResponseSeeds.java 
 * 
 * History:
 *     2013-7-5: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */
package com.simplelife.seeds.server.json;

import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import com.simplelife.seeds.server.db.Seed;
import com.simplelife.seeds.server.db.SeedPicture;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.JsonKey;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.SqlUtil;
import com.simplelife.seeds.server.util.TableColumnName;
import com.simplelife.seeds.server.util.TableName;


/**
 * 
 */
public class JsonResponseSeeds extends JsonResponseBase
{
    protected JSONArray dateList;
	
	public JsonResponseSeeds(JSONObject jsonObj, PrintWriter out)
	{
	    super(jsonObj, out);
		addHeader(JsonKey.commandSeedsByDatesResponse);
	}
	
    @Override
    public void responseNormalRequest()
    {
        if (dateList == null)
        {
            LogUtil.severe("Null dateList in responseNormalRequest.");
        }
        
        int size = dateList.size();
        for (int i = 0; i < size; i++) {
            addSeeds(dateList.get(i).toString());
        }

        outPrintWriter.write(toString());
        LogUtil.info("Response SeedsUpdateStatusByDatesRequest successfully: " + dateList.toString());
    }

    private ArrayList<Object> getSeedsTable(String date)
    {
        if (!body.containsKey(date))
        {
            body.put(date, new ArrayList<Object> ());
        }
        
        return (ArrayList<Object>) body.get(date);
    }

    private void addSeeds(String strDate)
    {
        String sql = SqlUtil.getSelectSeedSql(SqlUtil.getPublishDateCondition(strDate));
        List<Seed> seeds = DaoWrapper.query(sql, Seed.class);
        
        if (seeds != null)
        {
            if (seeds.isEmpty())
            {
                addSeed(strDate, null);
                return;
            }
            
            Iterator<Seed> it = seeds.iterator();
            Seed seed;
            while (it.hasNext()) {
                seed = it.next();
                addSeed(strDate, seed);
            }
        }
    }
    
    private void addSeed(String date, Seed seed)
    {
    	List<Object> seedList = getSeedsTable(date);
    	
    	if (seed != null)
    	{
    		addSeedFields(seedList, seed);
    	}
    }
    
    private void addSeedFields(List<Object> seedList, Seed seed)
    {
    	Hashtable<String, Object> seedFields = new Hashtable<String, Object>();
    	seedList.add(seedFields);
    	
        responseField(seedFields, Long.toString(seed.getSeedId()), TableColumnName.seedId);
        responseField(seedFields, TableColumnName.type, seed.getType());
        responseField(seedFields, TableColumnName.source, seed.getSource());
        responseField(seedFields, TableColumnName.publishDate, seed.getPublishDate());
        responseField(seedFields, TableColumnName.name, seed.getName());
        responseField(seedFields, TableColumnName.size, seed.getSize());
        responseField(seedFields, TableColumnName.format, seed.getFormat());
        responseField(seedFields, TableColumnName.torrentLink, seed.getTorrentLink());
        responseField(seedFields, TableColumnName.hash, seed.getHash());
        responseField(seedFields, TableColumnName.mosaic, seed.getMosaic());
        responseField(seedFields, TableColumnName.memo, seed.getMemo());
        
        addPictureLinks(seed.getSeedId(), seedFields);
    }

    private void responseField(Hashtable<String, Object> seedFields, String fieldName, String fieldValue)
    {
        if ((fieldValue != null) && (fieldValue.length() > 0)) 
        {
        	seedFields.put(fieldName, fieldValue);
        }
    }
    
    private void addPictureLinks(long seedId, Hashtable<String, Object> seedFields)
    {
        String sql = SqlUtil.getSelectSeedPictureSql(SqlUtil.getSeedIdCondition(seedId));
        //String sql = "select " + TableColumnName.pictureLink + " from " + TableName.SeedPicture 
        //        + " where " + TableColumnName.seedId + " = " + Long.toString(seedId);
        List<SeedPicture> pics = DaoWrapper.query(sql, SeedPicture.class);
        
        List<String> picLinks = new ArrayList<String> ();
        Iterator<SeedPicture> it = pics.iterator();
        while(it.hasNext())
        {
            picLinks.add(it.next().getPictureLink());
        }
        seedFields.put(JsonKey.piclinks, picLinks);
    }
    
    /**
     * @return the dateList
     */
    public JSONArray getDateList()
    {
        return dateList;
    }

    /**
     * @param dateList the dateList to set
     */
    public void setDateList(JSONArray dateList)
    {
        this.dateList = dateList;
    }
}
