package com.simplelife.seeds.android.utils.httpserver.http.workers;

import java.io.IOException;
import java.net.Socket;
import java.util.Vector;

import com.simplelife.seeds.android.utils.httpserver.http.Server;
import com.simplelife.seeds.android.utils.httpserver.http.utils.HttpMethod;
import com.simplelife.seeds.android.utils.httpserver.http.utils.HttpStatus;
import com.simplelife.seeds.android.utils.httpserver.http.utils.headers.ContentTypeHttpHeader;
import com.simplelife.seeds.android.utils.httpserver.http.utils.headers.HttpHeader;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleRequest;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleResponse;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleWorkerInterface;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleWorkerException;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.implementations.SimpleDirectoryWorker;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.implementations.SimpleDownloadWorker;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.implementations.SimpleFileWorker;
import com.simplelife.seeds.android.utils.httpserver.utils.Logger;

import android.os.Looper;

/**
 * <p>
 * Dispatches requests to simple workers
 * </p>
 * @author Matt
 *
 */
public class SimpleWorkerDispatcher extends AbstractWorker {

	private Socket mSocket;
	private SimpleRequest mRequest;
	
	@Override
	public void InitialiseWorker(HttpMethod pMethod, String pResource, Socket pSocket) {
		mRequest = new SimpleRequest(pMethod, pResource);
		mSocket = pSocket;
	}
	
	/**
	 * <p>
	 * Takes a request from the AbstractWorker and calls the appropriate SimpleWorkerImplementation
	 * </p>
	 */
	@Override
	public void run() {
		
		if (Looper.myLooper() == null) {
			Looper.prepare();
		}
        		
		if (mSocket == null || mSocket.isClosed()) {
			Logger.warn("Socket was null or closed when trying to serve thread!");
			return;
		}
		
		try {
				SimpleWorkerInterface sp;
				
				if (mRequest.getResource().endsWith("/")) {
					sp = new SimpleDirectoryWorker();
				} else if(mRequest.getResource().endsWith(Server.SUFFIX_ZIP)) {					
					sp = new SimpleDownloadWorker();					
				}else{
					sp = new SimpleFileWorker();
				}
								
				SimpleResponse response = sp.handlePackage(mRequest);
				
				Vector<HttpHeader> headers = new Vector<HttpHeader>();
				headers.add(new ContentTypeHttpHeader(response.getMimeType()));
				
				// Trigger event
				triggerRequestServedEvent(mRequest.getResource());
				
				writeResponse(response.getResponse(), mSocket, headers, HttpStatus.HTTP200);
				if (mSocket != null && !mSocket.isClosed()) {
					mSocket.close();
				}
			
		} catch (SimpleWorkerException e) {
			Logger.debug("PackWorker threw exception: " + e.getStatus().toString());
			writeStatus(mSocket, e.getStatus());
		} catch (IOException e) {
			Logger.debug("IOException when trying to close SimpleWorker socket.");
		}

	}
	
}
