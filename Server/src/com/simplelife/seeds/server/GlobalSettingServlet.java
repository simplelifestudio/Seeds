package com.simplelife.seeds.server;

import java.io.IOException;
import java.util.logging.Level;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.simplelife.seeds.server.parser.HtmlParser;
import com.simplelife.seeds.server.util.GlobalSetting;
import com.simplelife.seeds.server.util.LogUtil;

/**
 * Servlet implementation class GlobalSettingServlet
 */
@WebServlet("/globalSettingService")
public class GlobalSettingServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public GlobalSettingServlet() {
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    doPost(request, response);
	}

	public void parseIpAddress(String ipAddress)
	{
	    if (ipAddress != null && ipAddress.length() > 0)
        {
            String regex = "^(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|[1-9])\\." 
               + "(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\."
               + "(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\."
               + "(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)$";
            
            if (ipAddress.matches(regex))
            {
                GlobalSetting.setHostIP(ipAddress);
                System.out.print("Set host IP to: " + ipAddress + "\n");
            }
        }
	}
	
	public void parseTorrentExpireDays(String torrentExpireDays)
    {
	    if (torrentExpireDays != null && torrentExpireDays.length() > 0)
        {
            int days = Integer.parseInt(torrentExpireDays);
            GlobalSetting.setTorrentExpiredays(days);
            System.out.print("Set torrentExpireDays to: " + torrentExpireDays + "\n");
        }
    }
	
	public void parseLogLevel(String logLevel)
	{
	    boolean flag = false;
	    if (logLevel != null && logLevel.length() > 0)
        {
	        if (logLevel.equalsIgnoreCase(LogUtil.LogLevelFine))
            {
                LogUtil.setLevel(Level.FINE);
                flag = true;
            }
            else if (logLevel.equalsIgnoreCase(LogUtil.LogLevelInfo))
            {
                LogUtil.setLevel(Level.INFO);
                flag = true;
            }
            else if (logLevel.equalsIgnoreCase(LogUtil.LogLevelWarning))
            {
                LogUtil.setLevel(Level.WARNING);
                flag = true;
            }
            else if (logLevel.equalsIgnoreCase(LogUtil.LogLevelSevere))
            {
                LogUtil.setLevel(Level.SEVERE);
                flag = true;
            }
	        
	        if (flag)
	        {
	            System.out.print("Set logLevel to: " + logLevel + "\n");
	        }
        }
	}
	
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    try {
            String ipAddress = request.getParameter("ipAddress");
            String torrentExpireDays = request.getParameter("torrentExpireDays");
            String logLevel = request.getParameter("logLevel");
            
            parseIpAddress(ipAddress);
            parseTorrentExpireDays(torrentExpireDays);
            parseLogLevel(logLevel);
            
            response.getOutputStream().print("Setting changed successfully.");
        }
	    catch (Exception e) {
            LogUtil.printStackTrace(e);
            response.getOutputStream().print("Error occurred");
        }
	}

}
