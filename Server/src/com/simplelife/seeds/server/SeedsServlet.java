/**
 * SeedsServlet.java 
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

import com.simplelife.seeds.server.json.IJsonCommand;
import com.simplelife.seeds.server.json.JsonCommandFactory;
import com.simplelife.seeds.server.util.LogUtil;

import net.sf.json.JSONObject;

/**
 * Servlet implementation class SeedsServlet
 */
@WebServlet("/messageListener")
public class SeedsServlet extends HttpServlet {
	private final String _seedsMIME = "application/json";
	// private final String _jsonRequestKeyword = "command";

	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public SeedsServlet() {
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
		response.setContentType(_seedsMIME);

		if (request.getContentType() != _seedsMIME) {
			LogUtil.warning("Invalid MIME found from client: " + request.getContentType());
		}

		String command = readCommand(request);

		LogUtil.info("JSON command received: " + command);
		
		JSONObject jsonObj = createJsonObject(command);
		if (jsonObj == null) {
			LogUtil.severe( "Invalid command received: \n" + command);
			return;
		}

		response.setCharacterEncoding("UTF-8");
		response.setContentType(_seedsMIME);
		PrintWriter out = response.getWriter();
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
		
		//return "{\n    \"command\": \"AlohaRequest\",\n    \"paramList\":\n    {\n    		\"content\":\"Hello Seeds Server!\"\n    }\n}\n";
		
		
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
	 * Check if JSON command from client is valid, including if it matches
	 * format of JSON
	 * 
	 * @param command
	 *            : string of command
	 * @return: null if it's invalid JSON command, else, return constructed JSON
	 *          object
	 */
	public JSONObject createJsonObject(String command) {
		if (command.length() == 0) {
			return null;
		}

		if (command.indexOf("{") == -1) {
			return null;
		}

		JSONObject jsonObj = null;
		try {
			jsonObj = JSONObject.fromObject(command);
		} catch (Exception e) {
			//LogUtil.severe( "Error occurred when try to decode JSON command from client: " + e.getMessage());
			LogUtil.printStackTrace(e);
			return null;
		}

		return jsonObj;
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
		IJsonCommand jsonCmd = JsonCommandFactory.CreateJsonCommand(jsonObj, request);
		
		if (jsonCmd == null)
		{
			return; 
		}
		
		jsonCmd.Execute(jsonObj, out);
	}
}
