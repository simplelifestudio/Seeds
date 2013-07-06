/**
 * CartServiceServlet.java
 * 
 * History:
 *     2013-6-12: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.simplelife.seeds.server.db.RssUtil;
import com.simplelife.seeds.server.util.LogUtil;


@WebServlet("/cartService")
public class CartServiceServlet extends HttpServlet
{
    private static final long serialVersionUID = 2L;
    
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        super.service(request, response);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        doPost(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        try {
            String cartId = request.getParameter("cartId");
            
            LogUtil.info("Procceed seed RSS request for cartID<" + cartId + "> from IP: " + request.getLocalAddr() );
            
            if (cartId == null || cartId.length() == 0)
            {
                LogUtil.severe("Parameter of cartId is not provided");
                response.getOutputStream().print("Parameter of cartId is not provided");
                return;
            }
            
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            
            rssContent(out, cartId);
        } catch (Exception e) {
            LogUtil.printStackTrace(e);
            response.getOutputStream().print(e.getMessage());
        }
    }
    
    private void rssContent(PrintWriter out, String cartId)
    {
    	RssUtil rssUtil = new RssUtil();
        String rssContent = rssUtil.browseRss(cartId);
        out.print(rssContent);
        //LogUtil.info(rssContent);
    }
}
