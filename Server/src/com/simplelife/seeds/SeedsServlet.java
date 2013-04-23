package com.simplelife.seeds;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;
import net.sf.json.JSONArray;


/**
 * Servlet implementation class SeedsServlet
 */
@WebServlet("/Request")
public class SeedsServlet extends HttpServlet {
	private final String MIME = "application/json";
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public SeedsServlet() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#service(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void service(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub

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
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doPost(request, response);
	}

	private void test1(PrintWriter out)
	{
		boolean[] boolArray = new boolean[]{true, false, true};
		JSONArray jsonArray1 = JSONArray.fromObject(boolArray);
		out.println(jsonArray1);  //[true,false,true]
		
		List list = new ArrayList();
		list.add("first");
		list.add("second");
		JSONArray jsonArray2 = JSONArray.fromObject(list);
		out.println(jsonArray2);  //["first","second"]
		
		JSONArray jsonArray3 = JSONArray.fromObject("['json','is','easy']");
		out.println(jsonArray3); 
	}
	
	private void test2(PrintWriter out)
	{
		final String[] FIELD_NAMES = new String[] {
			    "a", "b", "c", "x", "y", "b13", "abcdefg", "a123",
			    "a0", "b0", "c0", "d0", "e0", "f0", "g0", "h0",
			    "x2", "aa", "ba", "ab", "b31", "___x", "aX", "xxx",
			    "a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2",
			    "a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3",
			    "a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1",
			};

		StringBuilder sb = new StringBuilder();
        sb.append("{ ");

        int len = FIELD_NAMES.length;
        for (int i = 0; i < len; ++i) {
            if (i > 0) {
                sb.append(", ");
            }
            sb.append('"');
            sb.append(FIELD_NAMES[len - (i+1)]);
            sb.append("\" : ");
            sb.append(i);
        }

        sb.append(" }");
        String doc = sb.toString();
        
        out.println(doc);
        
        JSONObject obj = JSONObject.fromObject(doc);
		out.println(obj);
	}
	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		
		response.setContentType(MIME);
		PrintWriter out = response.getWriter();
		
		if (request.getContentType() != MIME)
		{
			out.println("Invalid MIME found: "+ request.getContentType());
			return;
		}
		
		
		try
		{
			test1(out);
			test2(out);
		}
		catch(Exception e)
		{
			out.println(e.getMessage());
		}
	}
}
