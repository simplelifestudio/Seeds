/**
 * HttpUtil.java 
 * 
 * History:
 *     2013-6-21: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */
package com.simplelife.seeds.server.util;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.URL;
import java.net.URLEncoder;
import java.util.List;
import java.util.Map;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;

/**
 * 
 */
public class HttpUtil
{
	private static Proxy proxy;
	private static String charSet = "UTF-8";
	private static final int BUFFER_SIZE = 4096;
	private static final String SEEDS_SERVER_DOWNLOADPHP = "http://www.maxp2p.com/load.php";
	
	public static void setHttpProxy(String ipAddress, int port)
	{
		proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress(ipAddress, port));
	}
	
	public static void removeHttpProxy()
	{
		proxy = null;
	}
	
	/**
     * ÉèÖÃ±àÂë
     * @param strCharSet ±àÂë×Ö·û´®£¬Èç£ºGBK¡¢UTF-8µÈ
     */
    public static void setCharSet(String strCharSet)
    {
        charSet = strCharSet;
        if (charSet == null || charSet.equals(""))
        {
            charSet = System.getProperty("file.encoding");
            if (charSet == null || charSet.equals(""))
            {
                charSet = "UTF-8";
            }
        }
    }
	
	
	public static HttpURLConnection getHttpUrlConnection(String urlStr)
	{
		HttpURLConnection conn = null;
		try
		{
			URL url = new URL(urlStr);
			
			if (proxy != null)
			{
				conn = (HttpURLConnection) url.openConnection(proxy);
			}
			else
			{
				conn = (HttpURLConnection) url.openConnection();
			}
		}
		catch(Exception e)
		{
			return null;
		}
		return conn;
	}

	public static void post(String urlStr, List <NameValuePair> params)
	{
	    try
	    {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost request = new HttpPost(urlStr);
            request.setEntity(new UrlEncodedFormEntity(params, "utf-8"));

            HttpResponse response = httpClient.execute(request);

            byte data[] = new byte[BUFFER_SIZE];
	    }
	    catch (Exception e)
	    {
	        LogUtil.printStackTrace(e);
	    }
    }
}
