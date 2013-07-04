/**
 * TorrentDownloader.java
 * 
 * History:
 *     2013-6-22: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.parser;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import com.simplelife.seeds.server.util.HttpUtil;
import com.simplelife.seeds.server.util.LogUtil;

/**
 * 
 */
public class TorrentDownloader extends Thread
{
    private String urlLink;
    private String strOutputFile;
    public TorrentDownloader(String link, String outputFile)
    {
        urlLink = link;
        strOutputFile = outputFile;
    }
    
    public void run()
    {
        List <NameValuePair> params = HttpUtil.getParaListByLink(urlLink);
        if (params == null)
        {
            LogUtil.severe("Failed to get parameters from link: " + urlLink);
            return;
        }
        
        String postLink = HttpUtil.getPostLink(urlLink);
        HttpUtil.post(postLink, params, strOutputFile);
    }
}
