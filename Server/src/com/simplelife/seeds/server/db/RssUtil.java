/**
 * RssUtil.java 
 * 
 * History:
 *     2013-6-13: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */
package com.simplelife.seeds.server.db;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import com.simplelife.seeds.server.parser.TorrentDownloader;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.DateUtil;
import com.simplelife.seeds.server.util.HttpUtil;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.SqlUtil;
import com.sun.syndication.feed.rss.Channel;
import com.sun.syndication.feed.rss.Description;
import com.sun.syndication.feed.rss.Item;
import com.sun.syndication.io.WireFeedOutput;

public class RssUtil 
{
    /**
     * Return content of given cartId
     * @param cartId: ID of cart
     * @return: content of cart
     */
	public String browseRss(String cartId)
	{
		Channel channel = new Channel("rss_2.0");
		setChannelHeader(cartId, channel);
		String output = "";
		try {
			// Query subscribes of this user
			String sql = SqlUtil.getSelectRssContentSql(cartId);
			List<Seed> seeds = DaoWrapper.query(sql, Seed.class);
			
			if (seeds != null)
			{
				Iterator<Seed> it = seeds.iterator();
				Seed seed;
	
				List<Item> items = new ArrayList<Item>();
				while (it.hasNext()) {
					seed = it.next();
					addSeed(seed, items);
				}
				channel.setItems(items);
			}
			else
			{
			    LogUtil.severe("Null result returned.");
			}
		}
		catch (Exception e) 
		{
			LogUtil.printStackTrace(e);
		}

		try 
		{
			WireFeedOutput out = new WireFeedOutput();
			output = out.outputString(channel);
		}
		catch (Exception e) 
		{
			LogUtil.printStackTrace(e);
		}
		
		String beforeReplace = "<?xml version=\"1.0\" encoding=\"utf-8\"?>";
		String afterReplace = beforeReplace + "\n" + "<?xml-stylesheet type=\"text/xsl\" href=\"" + HttpUtil.getDefaultXsl() + "\"?>";
		
		//int index = output.indexOf(beforeReplace);
		//if ( index > 0)
		{
		    output = output.substring(beforeReplace.length());
		    output = afterReplace + output;
		}
		//output.replace(beforeReplace, afterReplace);
		return output;
	}
	
	/**
	 * Add channel header for given cartID
	 * @param cartId: ID of cart
	 * @param channel: Object of channel for result of client
	 */
	private static void setChannelHeader(String cartId, Channel channel)
	{
	    if (channel == null)
	    {
	        LogUtil.severe("Null channel found.");
	        return;
	    }
	    
		channel.setEncoding("UTF-8");
        channel.setTitle("Seeds - Cart Service");
        channel.setEncoding("UTF-8");
        
        channel.setDescription("");
        channel.setLink(HttpUtil.getFullLink("/cartService?cartId=" + cartId));
        channel.setPubDate(DateUtil.getNowDate());
	}
	
	
	/**
	 * Add information of seed to channel
	 * @param seed: object of seed
	 * @param items: list of RSS items in channel
	 */
	private static void addSeed(Seed seed, List<Item> items)
	{
		if (seed == null)
		{
			LogUtil.severe("Invalid null seed");
			return;
		}
		
		if (items == null)
		{
			LogUtil.severe("Invalid null channel");
			return;
		}
		
		Item item = new Item();
		item.setTitle(seed.getName());
		
		String torrentFile = HttpUtil.getSeedSavePathFile(seed.getSeedId());
		File file = new File(torrentFile);
		if (!file.exists())
		{
		    LogUtil.info("Torrent is not existent, start to download: " + file.getAbsolutePath());
		    TorrentDownloader dl = new TorrentDownloader(seed.getTorrentLink(), torrentFile);
		    dl.start();
		}
		else
		{
		    LogUtil.info("Torrent is existent: " + file.getAbsolutePath());
		}
		
		item.setLink(HttpUtil.getTorrentLink(seed.getSeedId()));
        Description desc = new Description();
        desc.setValue(seed.toRssString());
        item.setDescription(desc);

        items.add(item);
	}
}
