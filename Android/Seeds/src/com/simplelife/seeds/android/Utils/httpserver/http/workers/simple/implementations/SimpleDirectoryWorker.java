package com.simplelife.seeds.android.utils.httpserver.http.workers.simple.implementations;

import java.io.File;
import java.net.URLDecoder;
import java.util.Arrays;

import com.simplelife.seeds.android.utils.httpserver.http.Server;
import com.simplelife.seeds.android.utils.httpserver.http.utils.HttpMethod;
import com.simplelife.seeds.android.utils.httpserver.http.utils.HttpStatus;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleRequest;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleResponse;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleWorkerInterface;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleWorkerException;
import com.simplelife.seeds.android.utils.httpserver.utils.ByteUtils;
import com.simplelife.seeds.android.utils.httpserver.utils.Logger;

/**
 * <p>
 * A very simple worker that provides a simple directory listing.
 * </p>
 * @author Matt
 *
 */
public class SimpleDirectoryWorker implements SimpleWorkerInterface {
	
	/**
	 * <p>
	 * Process the request for a directory and return a HTML directory listing.
	 * </p>
	 * @throws SimpleWorkerException 
	 */
	public SimpleResponse handlePackage(SimpleRequest pRequest) throws SimpleWorkerException {
        		
		SimpleResponse response = null;
		File resource = null;
		
		try {
			
			if (pRequest.getMethod() != HttpMethod.GET) {
				throw new SimpleWorkerException(HttpStatus.HTTP405);
			} else {
				
				resource = new File(Server.getRoot() + URLDecoder.decode(pRequest.getResource()));
				
				if (!resource.exists() || !resource.canRead()) {
					throw new SimpleWorkerException(HttpStatus.HTTP404);
				} else if (!resource.isDirectory()) {
					throw new SimpleWorkerException(HttpStatus.HTTP500);			
				} else {	
					
					File[] children = resource.listFiles();
					StringBuffer buffer = new StringBuffer();
					
					buffer.append("<h1>").append(pRequest.getResource()).append("</h1>");
					
					if (children == null || children.length == 0) {
						buffer.append("This directory has no files.");
					} else {
						Arrays.sort(children);
						for (File child : children) {
			
							if (child.isDirectory()) {
								buffer.append("[dir] <a href=\"").append(pRequest.getResource()).append(child.getName()).append("/\">");
							} else {
								buffer.append("<a href=\"").append(pRequest.getResource()).append(child.getName()).append("\">");
							}
														
							buffer.append(child.getName());
							buffer.append("</a><br />");							
						}
					}
					
					String type = "text/html";
										
					response = new SimpleResponse(type, ByteUtils.getBytesFromString(buffer.toString()));
				}
			}

		} catch (OutOfMemoryError e) {
			Logger.error("OutOfMemoryError when trying to serve " + pRequest.getResource() + e.toString());
			throw new SimpleWorkerException(HttpStatus.HTTP503);
		}
		
		return response;
	}
	
}
