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
	
	/**
	 * Constructor
	 * @param jsonObj: Object of JSON command which will be executed
	 * @param out: PrintWriter for output, normally it's response for client
	 */
	public JsonResponseSeeds(JSONObject jsonObj, PrintWriter out)
	{
	    super(jsonObj, out);
		addHeader(JsonKey.commandSeedsByDatesResponse);
	}
	
	/**
	 * Normal response for client
	 */
    @Override
    public void responseNormalRequest()
    {
        if (dateList == null)
        {
            LogUtil.severe("Null dateList in responseNormalRequest.");
        }
        
        int size = dateList.size();
        for (int i = 0; i < size; i++) 
        {
            addSeeds(dateList.get(i).toString());
        }

        outPrintWriter.write(toString());
        LogUtil.info("Response SeedsUpdateStatusByDatesRequest successfully: " + dateList.toString());
    }

    /**
     * Return list of seeds for given date, create new one if nonexistent
     * @param date: string of date 
     * @return List of seeds for given date
     */
    private ArrayList<Object> getSeedsList(String date)
    {
        if (!body.containsKey(date))
        {
            body.put(date, new ArrayList<Object> ());
        }
        
        return (ArrayList<Object>) body.get(date);
    }

    /**
     * Query seeds in DB of given date and append to seed list
     * @param strDate: string of date
     */
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
    
    /**
     * Add one seed into list
     * @param date: string of date
     * @param seed: object of seed queried from DB
     */
    private void addSeed(String date, Seed seed)
    {
    	List<Object> seedList = getSeedsList(date);
    	
    	if (seed != null)
    	{
    		addSeedFields(seedList, seed);
    	}
    }
    
    /**
     * Add seed details into reponse
     * @param seedList: list of seed
     * @param seed: object of seed queried from DB
     */
    private void addSeedFields(List<Object> seedList, Seed seed)
    {
    	Hashtable<String, Object> seedFields = new Hashtable<String, Object>();
    	seedList.add(seedFields);
    	
        responseField(seedFields, TableColumnName.seedId, Long.toString(seed.getSeedId()));
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

    /**
     * Add value of field into response, only non-null value will be added
     * @param seedFields: Hashtable of fields
     * @param fieldName: name of field
     * @param fieldValue: value of field
     */
    private void responseField(Hashtable<String, Object> seedFields, String fieldName, String fieldValue)
    {
        if ((fieldValue != null) && (fieldValue.length() > 0)) 
        {
        	seedFields.put(fieldName, fieldValue);
        }
    }
    
    /**
     * Add preview pictures into response
     * @param seedId: ID of seed
     * @param seedFields: Hashtable of fields
     */
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
