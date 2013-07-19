/**
 * SeedServiceServlet.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.simplelife.seeds.server.json.IJsonRequest;
import com.simplelife.seeds.server.json.JsonRequestBase;
import com.simplelife.seeds.server.json.JsonRequestFactory;
import com.simplelife.seeds.server.json.JsonResponseBase;
import com.simplelife.seeds.server.util.ErrorCode;
import com.simplelife.seeds.server.util.JsonUtil;
import com.simplelife.seeds.server.util.LogUtil;

import net.sf.json.JSONObject;

/**
 * Servlet implementation class SeedServiceServlet
 */
@WebServlet("/seedService")
public class SeedServiceServlet extends HttpServlet {
	private final String seedsMIME = "application/json";

	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public SeedServiceServlet() {
		super();
	}

	/**
	 * @see HttpServlet#service(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		/*
		 * String password = request.getParameter("password");
		 * 
		 * response.setContentType("text/html"); PrintWriter out =
		 * response.getWriter(); out.println("Service() is called<br>");
		 * out.println("password: " + password + "<br>");
		 */

		super.service(request, response);
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		LogUtil.info("Beginning of doPost, proceed request from client");
		response.setCharacterEncoding("UTF-8");
		response.setContentType(seedsMIME);

		String clientContentType = request.getContentType(); 
		if (!clientContentType.contains(seedsMIME)) {
			LogUtil.warning("Invalid MIME found from client: " + clientContentType);
		}

		String command = readCommand(request);

		LogUtil.info("JSON command received: " + command);
		
		JSONObject jsonObj = JsonUtil.createJsonObject(command);
		PrintWriter out = response.getWriter();
		if (jsonObj == null) {
			LogUtil.warning( "Invalid command received: \n" + command);
			JsonResponseBase responseBase = new JsonResponseBase(null, out);
			responseBase.responseError(ErrorCode.IllegalMessage, "Illegal message.", command,out);
			return;
		}

		executeCommand(jsonObj, out, request);
	}


	/**
	 * Read JSON command from client
	 * 
	 * @param request
	 *            : http request from client
	 * @return: complete string of JSON command from client
	 */
	private String readCommand(HttpServletRequest request) {
		StringBuffer strBuf = new StringBuffer();
		String line = null;
		try {
			BufferedReader reader = request.getReader();
			while ((line = reader.readLine()) != null) {
				strBuf.append(line);
			}
		} catch (Exception e) {
			System.out.println(e.toString());
			LogUtil.printStackTrace(e);
		}
		return strBuf.toString();
		
	}

	

	/**
	 * Execute command bases on JSON object
	 * 
	 * @param jsonObj
	 *            : JSON object which contains command from client
	 * @param out
	 *            : output stream of http response
	 */
	private void executeCommand(JSONObject jsonObj, PrintWriter out, HttpServletRequest request) {
		IJsonRequest jsonCmd = JsonRequestFactory.CreateJsonCommand(out, jsonObj, request.getLocalAddr());
		
		if (jsonCmd == null)
		{
		    LogUtil.warning("Illegal command received from client: " + jsonObj.toString());
			return;
		}
		
		jsonCmd.Execute();
	}
}
