/**
 * SeedCaptureServlet.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.simplelife.seeds.server.parser.HtmlParser;
import com.simplelife.seeds.server.util.LogUtil;

@WebServlet("/SeedCaptureRequest")
public class SeedCaptureServlet extends HttpServlet {
		private static final long serialVersionUID = 1L;

		public SeedCaptureServlet() {
			super();
		}

		protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
			super.service(request, response);
		}

		protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
			doPost(request, response);
		}

	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		try {
			String keyWord = request.getParameter("keyWord");
			String startDate = request.getParameter("startDate");
			String endDate = request.getParameter("endDate");

			String baseLink = request.getParameter("baseLink");
			String startPage = request.getParameter("startPage");
			String endPage = request.getParameter("endPage");
			
			HtmlParser parser = new HtmlParser();
			parser.getkeyWordList().clear();
			parser.getkeyWordList().add(keyWord);
			parser.setbaseLink(baseLink);
			parser.setstartDate(startDate);
			parser.setendDate(endDate);
			
			parser.setPageStart(Integer.parseInt(startPage));
			parser.setPageEnd(Integer.parseInt(endPage));
			
			parser.Parse();
			response.getOutputStream().print("Seed capture request is submitted successfully!");
			
		} catch (Exception e) {
			LogUtil.printStackTrace(e);
			response.getOutputStream().print(e.getStackTrace().toString());
		}

	}
}
