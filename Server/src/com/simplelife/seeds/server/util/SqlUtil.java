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
    public static String getPublishDateCondition(String date)
    {
    	return TableColumnName.publishDate + " = '" + date + "'";
    }
    
    public static String getSeedIdCondition(long longSeedId)
    {
    	return TableColumnName.seedId + " = " + Long.toString(longSeedId); 
    }
    
    public static String getSelectCaptureLogSql(String strCondition)
    {
    	StringBuilder strBui = new StringBuilder();
        strBui.append("select ");
        
        strBui.append(TableColumnName.id);
        strBui.append(", ");
        
        strBui.append(TableColumnName.publishDate);
        strBui.append(", ");
        
        strBui.append(TableColumnName.status);
        
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
        
        strBui.append(TableColumnName.pictureId);
        strBui.append(", ");
        
        strBui.append(TableColumnName.seedId);
        strBui.append(", ");
        
        strBui.append(TableColumnName.pictureLink);
        strBui.append(", ");
        
        strBui.append(TableColumnName.memo);
        
        strBui.append(" from ");
        strBui.append(TableName.SeedPicture);

        strBui.append(" where 1=1 ");
        if (strCondition != null && strCondition.length() > 0)
        {
        	strBui.append(" and ");
        	strBui.append(strCondition);
        }
        
        strBui.append(" order by ");
        strBui.append(TableColumnName.pictureId);
        
        
        return strBui.toString();
    }
    
    public static String getSelectSeedSql(String strCondition)
    {
        StringBuilder strBui = new StringBuilder();
        strBui.append("select ");
        
        strBui.append(TableColumnName.seedId);
        strBui.append(", ");
        
        strBui.append(TableColumnName.type);
        strBui.append(", ");
        
        strBui.append(TableColumnName.source);
        strBui.append(", ");
        
        strBui.append(TableColumnName.publishDate);
        strBui.append(", ");

        strBui.append(TableColumnName.name);
        strBui.append(", ");

        strBui.append(TableColumnName.size);
        strBui.append(", ");

        strBui.append(TableColumnName.format);
        strBui.append(", ");

        strBui.append(TableColumnName.torrentLink);
        strBui.append(", ");

        strBui.append(TableColumnName.hash);
        strBui.append(", ");

        strBui.append(TableColumnName.mosaic);
        strBui.append(", ");

        strBui.append(TableColumnName.memo);
        
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
        strBui.append(TableColumnName.seedId);
        strBui.append(", ");
        
        strBui.append(TableColumnName.type);
        strBui.append(", ");
        
        strBui.append(TableColumnName.source);
        strBui.append(", ");
        
        strBui.append(TableColumnName.publishDate);
        strBui.append(", ");

        strBui.append(TableColumnName.name);
        strBui.append(", ");

        strBui.append(TableColumnName.size);
        strBui.append(", ");

        strBui.append(TableColumnName.format);
        strBui.append(", ");

        strBui.append(TableColumnName.torrentLink);
        strBui.append(", ");

        strBui.append(TableColumnName.hash);
        strBui.append(", ");

        strBui.append(TableColumnName.mosaic);
        strBui.append(", ");

        strBui.append(TableColumnName.memo);
        
        strBui.append(" from ");
        strBui.append(TableName.Seed);
        strBui.append(", ");
        strBui.append(TableName.Cart);
        
        strBui.append(" where ");
        strBui.append(TableName.Cart);
        strBui.append(".");
        strBui.append(TableColumnName.cartId);
        strBui.append(" = '");
        strBui.append(userCartId);
        strBui.append("' and ");
        strBui.append(TableName.Seed);
        strBui.append(".");
        strBui.append(TableColumnName.seedId);
        strBui.append(" = ");
        strBui.append(TableName.Cart);
        strBui.append(".");
        strBui.append(TableColumnName.seedId);
        
        return strBui.toString();
    }
    
}
