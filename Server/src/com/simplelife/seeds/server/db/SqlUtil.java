/**
 * SqlUtil.java
 * 
 * History:
 *     2013-6-26: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.db;

import com.simplelife.seeds.server.util.TableName;

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


    
    public static String getSelectSeedSql()
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
        strBui.append(", ");
        
        strBui.append(" from ");
        strBui.append(TableName.Seed);
        
        return strBui.toString();
    }
    
    public static String getRssContentSql(String cartId)
    {
    	StringBuilder strBui = new StringBuilder();
    	String sql = "Select Seed.seedId,type,source,publishDate,name,size,format, torrentLink, hash,mosaic, memo "
				+ "from Seed, Cart "
		        + "where Cart.cartId = '" + cartId + "' and Seed.seedId = Cart.seedId";
		
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
        strBui.append(", ");
        
        strBui.append(" from ");
        strBui.append(TableName.Seed);
        strBui.append(", ");
        strBui.append(TableName.Cart);
        
        strBui.append(" where ");
        strBui.append(TableName.Cart);
        strBui.append(".");
        strBui.append(seedId);
        strBui.append(" = '");
        strBui.append(cartId);
        strBui.append("' and ");
        strBui.append(TableName.Seed);
        strBui.append(".");
        strBui.append(seedId);
        strBui.append(" = ");
        strBui.append(TableName.Cart);
        strBui.append(".");
        strBui.append(seedId);
        
        
        //+ "where Cart.cartId = '" + cartId + "' and Seed.seedId = Cart.seedId";
        
        return strBui.toString();
    }
    
}
