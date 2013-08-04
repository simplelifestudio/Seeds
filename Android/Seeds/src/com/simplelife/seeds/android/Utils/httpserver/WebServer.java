package com.simplelife.seeds.android.utils.httpserver;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

import org.apache.http.impl.DefaultConnectionReuseStrategy;
import org.apache.http.impl.DefaultHttpResponseFactory;
import org.apache.http.impl.DefaultHttpServerConnection;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.CoreConnectionPNames;
import org.apache.http.params.CoreProtocolPNames;
import org.apache.http.params.HttpParams;
import org.apache.http.protocol.BasicHttpProcessor;
import org.apache.http.protocol.HttpRequestHandlerRegistry;
import org.apache.http.protocol.HttpService;
import org.apache.http.protocol.ResponseConnControl;
import org.apache.http.protocol.ResponseContent;
import org.apache.http.protocol.ResponseDate;
import org.apache.http.protocol.ResponseServer;

import com.simplelife.seeds.android.utils.httpserver.utils.Logger;

public class WebServer extends Thread {

	static final String SUFFIX_ZIP = "..zip";
	static final String SUFFIX_DEL = "..del";

	private int port;
	private String webRoot;
	private boolean isLoop = false;

	public WebServer(int port, final String webRoot) {
		super();
		this.port = port;
		this.webRoot = webRoot;
	}

	@Override
	public void run() {
		ServerSocket serverSocket = null;
		try {
			
			serverSocket = new ServerSocket(port);
			
			BasicHttpProcessor httpproc = new BasicHttpProcessor();
			
			httpproc.addInterceptor(new ResponseDate());
			httpproc.addInterceptor(new ResponseServer());
			httpproc.addInterceptor(new ResponseContent());
			httpproc.addInterceptor(new ResponseConnControl());
			
			HttpService httpService = new HttpService(httpproc,
					new DefaultConnectionReuseStrategy(),
					new DefaultHttpResponseFactory());
			
			HttpParams params = new BasicHttpParams();
			params.setIntParameter(CoreConnectionPNames.SO_TIMEOUT, 5000)
					.setIntParameter(CoreConnectionPNames.SOCKET_BUFFER_SIZE,
							8 * 1024)
					.setBooleanParameter(
							CoreConnectionPNames.STALE_CONNECTION_CHECK, false)
					.setBooleanParameter(CoreConnectionPNames.TCP_NODELAY, true)
					.setParameter(CoreProtocolPNames.ORIGIN_SERVER,
							"WebServer/1.1");
			
			httpService.setParams(params);
			
			HttpRequestHandlerRegistry reqistry = new HttpRequestHandlerRegistry();
			
			reqistry.register("*" + SUFFIX_ZIP, new HttpZipHandler(webRoot));
			reqistry.register("*" + SUFFIX_DEL, new HttpDelHandler(webRoot));
			reqistry.register("*", new HttpFileHandler(webRoot));
			
			httpService.setHandlerResolver(reqistry);
			
			Logger.debug("Server thread initialised");
			
			isLoop = true;
			while (isLoop && !Thread.interrupted()) {				
				Socket socket = serverSocket.accept();				
				DefaultHttpServerConnection conn = new DefaultHttpServerConnection();
				conn.bind(socket, params);				
				Thread t = new WorkerThread(httpService, conn);
				t.setDaemon(true); 
				t.start();
			}
		} catch (IOException e) {
			isLoop = false;
			e.printStackTrace();
		} finally {
			try {
				if (serverSocket != null) {
					serverSocket.close();
				}
			} catch (IOException e) {
			}
		}
	}

	public void close() {
		isLoop = false;
	}

}
