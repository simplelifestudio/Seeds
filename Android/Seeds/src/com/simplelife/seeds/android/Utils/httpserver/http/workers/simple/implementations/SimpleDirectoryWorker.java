package com.simplelife.seeds.android.utils.httpserver.http.workers.simple.implementations;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Date;

import android.util.Log;

import com.simplelife.seeds.android.R;
import com.simplelife.seeds.android.SeedsHttpServiceActivity;
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
				
				String target = null;
				try {
					target = URLDecoder.decode(pRequest.getResource(), "UTF-8");
				} catch (UnsupportedEncodingException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				resource = new File(Server.getRoot() + URLDecoder.decode(pRequest.getResource()));
				
				if (!resource.exists() || !resource.canRead()) {
					throw new SimpleWorkerException(HttpStatus.HTTP404);
				} else if (!resource.isDirectory()) {
					throw new SimpleWorkerException(HttpStatus.HTTP500);			
				} else {	
					
					//File[] children = resource.listFiles();
					StringBuffer buffer = new StringBuffer();
					
					//buffer.append("<h1>").append(pRequest.getResource()).append("</h1>");
					Log.i("Testing", "Name: "+SeedsHttpServiceActivity.getHttpActivityContext().getString(R.string.seeds_http_webtitlename));
					
					buffer.append("<html>\n<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n<title>");
					buffer.append(null == target ? resource.getAbsolutePath() : target);
					buffer.append("Seeds Http Server</title>\n");
					buffer.append("<link rel=\"shortcut icon\" href=\"/mnt/sdcard/.SeedsWebService/img/favicon.ico\">\n");
					buffer.append("<link rel=\"stylesheet\" type=\"text/css\" href=\"/mnt/sdcard/.SeedsWebService/css/seedsWebService.css\">\n");
					buffer.append("<link rel=\"stylesheet\" type=\"text/css\" href=\"/mnt/sdcard/.SeedsWebService/css/examples.css\">\n");
					buffer.append("<script type=\"text/javascript\" src=\"/mnt/sdcard/.SeedsWebService/js/jquery-1.7.2.min.js\"></script>\n");
					buffer.append("<script type=\"text/javascript\" src=\"/mnt/sdcard/.SeedsWebService/js/jquery-impromptu.4.0.min.js\"></script>\n");
					buffer.append("<script type=\"text/javascript\" src=\"/mnt/sdcard/.SeedsWebService/js/seedsWebService.js\"></script>\n");
					buffer.append("</head>\n<body>\n<h1 id=\"header\">");
					buffer.append(null == target ? resource.getAbsolutePath() : target);
					buffer.append("Seeds Http Server</h1>\n<table id=\"table\">\n");
					buffer.append("<tr class=\"header\">\n<td>Name</td>\n<td class=\"detailsColumn\">Size</td>\n<td class=\"detailsColumn\">Date</td>\n<td class=\"detailsColumn\">Operations</td>\n</tr>\n");
					
					if (!isSamePath(resource.getAbsolutePath(), Server.getRoot().getAbsolutePath())) {
						buffer.append("<tr>\n<td><a class=\"icon up\" href=\"..\">[BACK]</a></td>\n<td></td>\n<td></td>\n<td></td>\n</tr>\n");
					}
					
					File[] files = resource.listFiles();
					if (null != files) {
						sort(files);
						for (File f : files) {
							appendRow(buffer, f);
						}
					}
					buffer.append("</table>\n<hr noshade>\n<em>Welcome to <a target=\"_blank\" href=\"http://SEEDSCLOUD.tk/\">Seeds App Server</a>!</em>\n</body>\n</html>");					
										
					/*
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
					}*/
					
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
	
	private void sort(File[] files) {
		Arrays.sort(files, new Comparator<File>() {
			@Override
			public int compare(File f1, File f2) {
				if (f1.isDirectory() && !f2.isDirectory()) {
					return -1;
				} else if (!f1.isDirectory() && f2.isDirectory()) {
					return 1;
				} else {
					return f1.toString().compareToIgnoreCase(f2.toString());
				}
			}
		});
	}
	
	private boolean isSamePath(String a, String b) {
		String left = a.substring(b.length(), a.length());
		if (left.length() >= 2) {
			return false;
		}
		if (left.length() == 1 && !left.equals("/")) {
			return false;
		}
		return true;
	}
	
	private SimpleDateFormat sdf = new SimpleDateFormat("yy-MM-dd ahh:mm");
	
	private void appendRow(StringBuffer sb, File f) {
		String clazz, link, size;
		if (f.isDirectory()) {
			clazz = "icon dir";
			link = f.getName() + "/";
			size = "";
		} else {
			clazz = "icon file";
			link = f.getName();
			size = formatFileSize(f.length());
		}
		sb.append("<tr>\n<td><a class=\"");
		sb.append(clazz);
		sb.append("\" href=\"");
		sb.append(link);
		sb.append("\">");
		sb.append(link);
		sb.append("</a></td>\n");
		sb.append("<td class=\"detailsColumn\">");
		sb.append(size);
		sb.append("</td>\n<td class=\"detailsColumn\">");
		sb.append(sdf.format(new Date(f.lastModified())));
		sb.append("</td>\n<td class=\"operateColumn\">");
		sb.append("<span><a href=\"");
		sb.append(link);
		sb.append(Server.SUFFIX_ZIP);
		sb.append("\">Download  </a></span>");
		if (f.canWrite() && !haSeedsWebDir(f)) {
			sb.append("<span><a href=\"");
			sb.append(link);
			sb.append(Server.SUFFIX_DEL);
			sb.append("\" onclick=\"return confirmDelete('");
			sb.append(link);
			sb.append(Server.SUFFIX_DEL);
			sb.append("')\">Delete</a></span>");
		}
		sb.append("</td>\n</tr>\n");
	}
	
	public static boolean haSeedsWebDir(File f) {
		String path = f.isDirectory() ? f.getAbsolutePath() + "/" : f
				.getAbsolutePath();
		return path.indexOf("/.SeedsWebService/") != -1;
	}
	
	private String formatFileSize(long len) {
		if (len < 1024)
			return len + " B";
		else if (len < 1024 * 1024)
			return len / 1024 + "." + (len % 1024 / 10 % 100) + " KB";
		else if (len < 1024 * 1024 * 1024)
			return len / (1024 * 1024) + "." + len % (1024 * 1024) / 10 % 100
					+ " MB";
		else
			return len / (1024 * 1024 * 1024) + "." + len
					% (1024 * 1024 * 1024) / 10 % 100 + " MB";
	}
	
}
