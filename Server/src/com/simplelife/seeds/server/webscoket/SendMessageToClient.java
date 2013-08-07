package com.simplelife.seeds.server.webscoket;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.simplelife.seeds.server.util.LogUtil;

/**
 * Servlet implementation class SendMessageToClient
 */
@WebServlet("/sendMessageToClient")
public class SendMessageToClient extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public SendMessageToClient() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		LogUtil.info("Enter doPost of SendMessageToClient");
	    String message = request.getParameter("message").trim();
	    String clientId = request.getParameter("clientId").trim();
		
		if (message == null || message.length() == 0)
		{
		    return;
		}
		ClientCollection.sendMsgToClient(clientId, message);
	}

}
