/**
 * SqlUtil.java
 * 
 * History:
 *     2013-6-26: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.util;

/**
 * 
 */
public class SqlUtil
{
    public final static String cartId = "cartId";
    public final static String description = "description";
    public final static String deviceId = "deviceId";
    public final static String format = "format";
    public final static String hash = "hash";
    public final static String id = "id";
    public final static String logDate = "logDate";
    public final static String logInfo = "logInfo";
    public final static String memo = "memo";
    public final static String mosaic = "mosaic";
    public final static String name = "name";
    public final static String operationCode = "operationCode";
    public final static String pictureId = "pictureId";
    public final static String pictureLink = "pictureLink";
    public final static String publishDate = "publishDate";
    public final static String seedId = "seedId";
    public final static String size = "size";
    public final static String source = "source";
    public final static String status = "status";
    public final static String torrentLink = "torrentLink";
    public final static String type = "type";

    public static String getPublishDateCondition(String date)
    {
    	return publishDate + " = '" + date + "'";
    }
    
    public static String getSeedIdCondition(long longSeedId)
    {
    	return seedId + " = " + Long.toString(longSeedId); 
    }
    
    public static String getSelectCaptureLogSql(String strCondition)
    {
    	StringBuilder strBui = new StringBuilder();
        strBui.append("select ");
        
        strBui.append(id);
        strBui.append(", ");
        
        strBui.append(publishDate);
        strBui.append(", ");
        
        strBui.append(status);
        
        strBui.append(" from ");
        strBui.append(TableName.SeedCaptureLog);
        
        strBui.append(" where 1=1 ");
        if (strCondition != null && strCondition.length() > 0)
        {
        	strBui.append(" and ");
        	strBui.append(strCondition);
        }
        
        return strBui.toString();
    }
    
    public static String getSelectSeedPictureSql(String strCondition)
    {
        StringBuilder strBui = new StringBuilder();
        strBui.append("select ");
        
        strBui.append(pictureId);
        strBui.append(", ");
        
        strBui.append(seedId);
        strBui.append(", ");
        
        strBui.append(pictureLink);
        strBui.append(", ");
        
        strBui.append(memo);
        
        strBui.append(" from ");
        strBui.append(TableName.SeedPicture);

        strBui.append(" where 1=1 ");
        if (strCondition != null && strCondition.length() > 0)
        {
        	strBui.append(" and ");
        	strBui.append(strCondition);
        }
        
        strBui.append(" order by ");
        strBui.append(pictureId);
        
        
        return strBui.toString();
    }
    
    public static String getSelectSeedSql(String strCondition)
    {
        StringBuilder strBui = new StringBuilder();
        strBui.append("select ");
        
        strBui.append(seedId);
        strBui.append(", ");
        
        strBui.append(type);
        strBui.append(", ");
        
        strBui.append(source);
        strBui.append(", ");
        
        strBui.append(publishDate);
        strBui.append(", ");

        strBui.append(name);
        strBui.append(", ");

        strBui.append(size);
        strBui.append(", ");

        strBui.append(format);
        strBui.append(", ");

        strBui.append(torrentLink);
        strBui.append(", ");

        strBui.append(hash);
        strBui.append(", ");

        strBui.append(mosaic);
        strBui.append(", ");

        strBui.append(memo);
        
        strBui.append(" from ");
        strBui.append(TableName.Seed);
        
        strBui.append(" where 1=1 ");
        if (strCondition != null && strCondition.length() > 0)
        {
        	strBui.append(" and ");
        	strBui.append(strCondition);
        }
        
        return strBui.toString();
    }
    
    public static String getSelectRssContentSql(String userCartId)
    {
    	StringBuilder strBui = new StringBuilder();
        strBui.append("select ");
        
        strBui.append(TableName.Seed);
        strBui.append(".");
        strBui.append(seedId);
        strBui.append(", ");
        
        strBui.append(type);
        strBui.append(", ");
        
        strBui.append(source);
        strBui.append(", ");
        
        strBui.append(publishDate);
        strBui.append(", ");

        strBui.append(name);
        strBui.append(", ");

        strBui.append(size);
        strBui.append(", ");

        strBui.append(format);
        strBui.append(", ");

        strBui.append(torrentLink);
        strBui.append(", ");

        strBui.append(hash);
        strBui.append(", ");

        strBui.append(mosaic);
        strBui.append(", ");

        strBui.append(memo);
        
        strBui.append(" from ");
        strBui.append(TableName.Seed);
        strBui.append(", ");
        strBui.append(TableName.Cart);
        
        strBui.append(" where ");
        strBui.append(TableName.Cart);
        strBui.append(".");
        strBui.append(cartId);
        strBui.append(" = '");
        strBui.append(userCartId);
        strBui.append("' and ");
        strBui.append(TableName.Seed);
        strBui.append(".");
        strBui.append(seedId);
        strBui.append(" = ");
        strBui.append(TableName.Cart);
        strBui.append(".");
        strBui.append(seedId);
        
        return strBui.toString();
    }
    
}
