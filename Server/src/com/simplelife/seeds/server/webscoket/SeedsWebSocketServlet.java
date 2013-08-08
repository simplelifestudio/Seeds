package com.simplelife.seeds.server.webscoket;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class SeedsWebSocketServlet
 */
@WebServlet("/websocket")
public class SeedsWebSocketServlet extends WebSocketServlet {
	private static final long serialVersionUID = 1L;
    private volatile int byteBufSize;
    private volatile int charBufSize;
    
       
    /**
     * @see WebSocketServlet#WebSocketServlet()
     */
    public SeedsWebSocketServlet() {
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    super.doGet(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    super.doGet(request, response);
	}

    /* (non-Javadoc)
     * @see org.apache.catalina.websocket.WebSocketServlet#createWebSocketInbound(java.lang.String, javax.servlet.http.HttpServletRequest)
     */
    @Override
    protected StreamInbound createWebSocketInbound(String arg0, HttpServletRequest arg1)
    {
        SeedsMessageInbound msgInbound = new SeedsMessageInbound(byteBufSize,charBufSize);
        ClientCollection.addClient(arg1.getRemoteAddr() + "_" + arg1.getRemotePort(), msgInbound);
        return msgInbound;
    }
    
    
    @Override
    public void init() throws ServletException {
        super.init();
        byteBufSize = getInitParameterIntValue("byteBufferMaxSize", 2097152);
        charBufSize = getInitParameterIntValue("charBufferMaxSize", 2097152);
    }
    
    public int getInitParameterIntValue(String name, int defaultValue) {
        String val = this.getInitParameter(name);
        int result;
        if(null != val) {
            try {
                result = Integer.parseInt(val);
            }catch (Exception x) {
                result = defaultValue;
            }
        } else {
            result = defaultValue;
        }

        return result;
    }
}
