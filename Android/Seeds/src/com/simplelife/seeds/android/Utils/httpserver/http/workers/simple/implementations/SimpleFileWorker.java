package com.simplelife.seeds.android.utils.httpserver.http.workers.simple.implementations;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URLDecoder;

import com.simplelife.seeds.android.utils.httpserver.http.Server;
import com.simplelife.seeds.android.utils.httpserver.http.utils.HttpMethod;
import com.simplelife.seeds.android.utils.httpserver.http.utils.HttpStatus;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleRequest;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleResponse;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleWorkerInterface;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleWorkerException;
import com.simplelife.seeds.android.utils.httpserver.utils.Logger;

import android.webkit.MimeTypeMap;

/**
 * <p>
 * A very simple worker that provides basic file serving capabilities.  Could be optimised by reading in files
 * in blocks rather than optimistically eating as much memory as it likes!
 * </p>
 * @author Matt
 *
 */
public class SimpleFileWorker implements SimpleWorkerInterface {

	/**
	 * <p>
	 * Process the request and serves back the requested file with the appropriate mimetype
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
					throw new SimpleWorkerException(HttpStatus.HTTP404, resource.toString() + " can not be read.");
				} else {								
					FileInputStream fileReader = new FileInputStream(resource);
					byte[] fileContent = new byte[(int) resource.length()];
					fileReader.read(fileContent, 0, (int) resource.length());
					fileReader.close();
					String ext = MimeTypeMap.getFileExtensionFromUrl(resource.getAbsolutePath());
					String type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext);
					if (null == type || "".equals(type)) {
						type = "text/html";
					}		
					
					response = new SimpleResponse(type, fileContent);
				}
			}
		
		
		} catch (IOException e) {
			Logger.error("IOException when trying to serve " + pRequest.getResource() + e.toString());
			throw new SimpleWorkerException(HttpStatus.HTTP500, e);
		} catch (OutOfMemoryError e) {
			Logger.error("OutOfMemoryError when trying to serve " + pRequest.getResource() + e.toString());
			throw new SimpleWorkerException(HttpStatus.HTTP503);
		}
		
		return response;
	}
	
}
