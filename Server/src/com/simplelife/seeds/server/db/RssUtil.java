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

public class RssUtil {
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
		} catch (Exception e) {
			LogUtil.printStackTrace(e);
		}

		try {
			WireFeedOutput out = new WireFeedOutput();
			output = out.outputString(channel);
		} catch (Exception e) {
			LogUtil.printStackTrace(e);
		}
		
		return output;
	}
	
	private static void setChannelHeader(String cartId, Channel channel)
	{
		channel.setEncoding("UTF-8");
        channel.setTitle("Seeds");
        channel.setEncoding("UTF-8");
        
        channel.setDescription("在这里，可以发现属于你的精彩内容");
        
        // TODO: update link of  here
        channel.setLink("http://xxxx.com/rss/userName");
        channel.setPubDate(DateUtil.getNowDate());
	}
	
	
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
		
		String torrentFile = "torrent/" + seed.getSeedId() + ".torrent";
		File file = new File(HttpUtil.getAbsolutePath(torrentFile));
		if (!file.exists())
		{
		    LogUtil.info("Torrent is not existent: " + file.getAbsolutePath());
		    TorrentDownloader dl = new TorrentDownloader(seed.getTorrentLink(), torrentFile);
		    dl.start();
		}
		
		item.setLink(HttpUtil.getFullLink(torrentFile));
        Description desc = new Description();
        desc.setValue(seed.toString());
        item.setDescription(desc);

        items.add(item);
	}
}
