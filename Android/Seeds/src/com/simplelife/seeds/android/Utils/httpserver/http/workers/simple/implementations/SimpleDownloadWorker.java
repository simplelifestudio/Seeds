package com.simplelife.seeds.android.utils.httpserver.http.workers.simple.implementations;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.entity.ContentProducer;
import org.apache.http.entity.EntityTemplate;

import com.simplelife.seeds.android.utils.httpserver.http.Server;
import com.simplelife.seeds.android.utils.httpserver.http.utils.HttpMethod;
import com.simplelife.seeds.android.utils.httpserver.http.utils.HttpStatus;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleRequest;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleResponse;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleWorkerInterface;
import com.simplelife.seeds.android.utils.httpserver.http.workers.simple.SimpleWorkerException;
import com.simplelife.seeds.android.utils.httpserver.utils.ByteUtils;
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
public class SimpleDownloadWorker implements SimpleWorkerInterface {
	
	private static final int BUFFER_LENGTH = 1048576;

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
				String target = null;
				try {
					target = URLDecoder.decode(pRequest.getResource(), "UTF-8");
				} catch (UnsupportedEncodingException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
				target = target.substring(0,
						target.length() - Server.SUFFIX_ZIP.length());
				Logger.debug("Downloading " + target);
				
				final File file = new File(Server.getRoot(), target);
				HttpEntity entity = new EntityTemplate(new ContentProducer() {
					@Override
					public void writeTo(OutputStream outstream) throws IOException {
						zip(file, outstream);
					}
				});
				
				HttpResponse tResponse = null;
			    tResponse.setHeader("Content-Type", "application/octet-stream");
				tResponse.addHeader("Content-Disposition",
						"attachment;filename=" + file.getName() + ".zip");
				tResponse.addHeader("Location", target);
				tResponse.setEntity(entity);
				
				String tContent = tResponse.toString();
				String type = "application/octet-stream";
				
				response = new SimpleResponse(type, ByteUtils.getBytesFromString(entity.toString()));
			}				
		} catch (OutOfMemoryError e) {
			Logger.error("OutOfMemoryError when trying to serve " + pRequest.getResource() + e.toString());
			throw new SimpleWorkerException(HttpStatus.HTTP503);
		}
		
		return response;
	}
	
	
	private void zip(File inputFile, OutputStream outstream) throws IOException {
		ZipOutputStream zos = null;
		try {
			
			zos = new ZipOutputStream(outstream);
			
			zip(zos, inputFile, inputFile.getName());
		} catch (IOException e) {
			throw e; 
		}
		try {
			if (null != zos) {
				zos.close();
			}
		} catch (IOException e) {
		}
	}

	private void zip(ZipOutputStream zos, File file, String base)
			throws IOException {
		if (file.isDirectory()) { 
			File[] files = file.listFiles();
			zos.putNextEntry(new ZipEntry(base + "/"));
			base = base.length() == 0 ? "" : base + "/";
			if (null != files && files.length > 0) {
				for (File f : files) {
					zip(zos, f, base + f.getName()); 
				}
			}
		} else {
			zos.putNextEntry(new ZipEntry(base)); 
			FileInputStream fis = new FileInputStream(file); 
			int count; 
			byte[] buffer = new byte[BUFFER_LENGTH]; 
			
			while ((count = fis.read(buffer)) != -1) {
				zos.write(buffer, 0, count);
				zos.flush();
			}
			fis.close(); 
		}
	}
	
}

