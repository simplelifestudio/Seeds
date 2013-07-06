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
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;

/**
 * 
 */
public class HttpUtil
{
	private static Proxy proxy;
	private static String charSet = "UTF-8";
	private static final int BUFFER_SIZE = 4096;
	private static String hostIPAddress;
	private static int httpPort = 80;
	private static String webappsRoot;
	
	public static void setHttpPort(int port)
	{
	    httpPort = port;
	}
	
	public static int getHttpPort(int port)
    {
        return httpPort;
    }
	
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
    
    public static void setHostIP(String hostIP)
    {
        hostIPAddress = hostIP;
    }
    
    public static String getHostIP()
    {
        if (hostIPAddress != null && hostIPAddress.length() > 0)
        {
            return hostIPAddress;
        }
        
        
        try
        {
            //java.net.InetAddress ad = java.net.InetAddress.getLocalHost();
            java.util.Enumeration<java.net.NetworkInterface> en = java.net.NetworkInterface.getNetworkInterfaces();
            while (en.hasMoreElements())
            {
                java.net.NetworkInterface ni = en.nextElement();
                java.util.Enumeration<java.net.InetAddress> ads = ni.getInetAddresses();
                while (ads.hasMoreElements())
                {
                    java.net.InetAddress ip = ads.nextElement();
                    if (!ip.isSiteLocalAddress() && !ip.isLoopbackAddress() && !(ip.getHostAddress().indexOf(":") == -1))
                    {
                        hostIPAddress = ip.getHostAddress();
                    }
                }
            }
            
            if (hostIPAddress == null)
            {
                hostIPAddress = InetAddress.getLocalHost().getHostAddress();
            }
        }
        catch (Exception e)
        {
            LogUtil.printStackTrace(e);
        }
        return hostIPAddress;
    }
    
    public static String getFullLink(String relativePath)
    {
        String fullLink = "http://" + getHostIP() + ":" + Integer.toString(httpPort);
        if (relativePath.charAt(0) == '/')
        {
            fullLink += relativePath;
        }
        else
        {
            fullLink += "/" + relativePath;
        }
        return fullLink;
    }

    public static String getPostLink(String urlStr)
    {
        String postLink = "";
        if (urlStr.contains("http://www.maxp2p.com/"))
        {
            postLink = "http://www.maxp2p.com/load.php";
        }
        return postLink;
    }
    
	public static List <NameValuePair> getParaListByLink(String link)
	{
	    String orgLink = link;
	    int paraStart = link.indexOf("?");
	    if (paraStart == -1)
	    {
	        LogUtil.warning("Invalid link: " + orgLink);
	        return null;
	    }
	    if (paraStart == (link.length() - 1))
	    {
	        LogUtil.warning("Invalid link: " + orgLink);
            return null;
        }
	    
	    int index = link.indexOf("=");
        if (index == -1)
        {
            LogUtil.warning("Invalid link: " + orgLink);
            return null;
        }
	    
        List <NameValuePair> params = new ArrayList<NameValuePair>();
        link = link.substring(paraStart + 1);
        
        String para="";
        String value="";
        while (link.length() > 0)
        {
            index = link.indexOf("="); 
            if (index <= 0)
            {
                LogUtil.warning("Invalid link: " + orgLink);
                break;
            }
            
            para = link.substring(0, index);
            link = link.substring(index + 1);
            if (link.length() == 0)
            {
                LogUtil.warning("Invalid link: " + orgLink);
                break;
            }
            
            index = link.indexOf("&"); 
            if (index == -1)
            {
                value = link;
                params.add(new BasicNameValuePair(para, value));
                break;
            }
            else
            {
                value = link.substring(0, index-1);
                params.add(new BasicNameValuePair(para, value));
                link = link.substring(index + 1);
            }
        }
        return params;
	}
	
	public static void post(String urlStr, List <NameValuePair> params, String outputFile)
	{
	    try
	    {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost request = new HttpPost(urlStr);
            request.setEntity(new UrlEncodedFormEntity(params, "utf-8"));

            HttpResponse response = httpClient.execute(request);
            handleResponse(response, outputFile);
	    }
	    catch (Exception e)
	    {
	        LogUtil.printStackTrace(e);
	    }
    }
	
	public static String getAbsolutePath(String relativePath)
	{
	    if (webappsRoot == null)
	    {
	        webappsRoot = System.getProperty("user.dir");
	        //String webappsRoot = new File("").getAbsolutePath();
	        webappsRoot = webappsRoot.replaceAll("bin", "webapps");
	    }
	    
	    String absPath = webappsRoot; 
	    if (relativePath.charAt(0) == '/')
        {
            absPath += relativePath;
        }
        else
        {
            absPath += "/" + relativePath;
        }
	    
	    return absPath;
	}
	
	private static void handleResponse(HttpResponse response, String outputFile)
	{
	    try
	    {
	        byte data[] = new byte[BUFFER_SIZE];
            InputStream entityStream = response.getEntity().getContent();
            //Header header = response.getFirstHeader("Content-Disposition");

            //String absPath = System.getProperty("user.dir");
            
            //absPath = absPath.replaceAll("/bin", "/webapps");
            
            
            File file = new File(getAbsolutePath(outputFile));
            if (!file.exists())
            {
                File path = file.getParentFile();
                if ((path != null) && (!path.exists()))
                {
                    path.mkdirs();
                }
                
                //LogUtil.severe("File does not exist: " + file.getAbsolutePath()); 
                //return;
            }
            
            FileOutputStream fs = new FileOutputStream(file.getAbsolutePath());
            for (;;) {
                int bytesRead = entityStream.read(data);
                if (bytesRead == -1) { // success, end of stream already reached
                    break;
                }
                fs.write(data, 0, bytesRead);
            }
            fs.close();
            LogUtil.info("Torrent downloading succeed: " + file.getAbsolutePath());
	    }
	    catch(Exception e)
	    {
	        LogUtil.printStackTrace(e);
	    }
    }
}
