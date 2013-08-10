package com.simplelife.seeds.android.utils.httpserver;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLConnection;
import java.net.URLDecoder;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Date;

import org.apache.http.HttpEntity;
import org.apache.http.HttpException;
import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.entity.FileEntity;
import org.apache.http.entity.StringEntity;
import org.apache.http.protocol.HttpContext;
import org.apache.http.protocol.HttpRequestHandler;

import android.annotation.SuppressLint;

import com.simplelife.seeds.android.R;
import com.simplelife.seeds.android.SeedsHttpServiceActivity;
import com.simplelife.seeds.android.utils.httpserver.utils.Logger;

public class HttpFileHandler implements HttpRequestHandler {

	private String webRoot;

	public HttpFileHandler(final String webRoot) {
		this.webRoot = webRoot;
	}

	@Override
	public void handle(HttpRequest request, HttpResponse response,
			HttpContext context) throws HttpException, IOException {

		String target = URLDecoder.decode(request.getRequestLine().getUri(),
				"UTF-8");
		final File file = new File(this.webRoot, target);

		if (!file.exists()) { 
			response.setStatusCode(HttpStatus.SC_NOT_FOUND);
			StringEntity entity = new StringEntity(
					"<html><body><h1>Error 404, file not found.</h1></body></html>",
					"UTF-8");
			response.setHeader("Content-Type", "text/html");
			response.setEntity(entity);
		} else if (file.canRead()) { 
			response.setStatusCode(HttpStatus.SC_OK);
			HttpEntity entity = null;
			if (file.isDirectory()) { 
				entity = createDirListHtml(file, target);
				response.setHeader("Content-Type", "text/html");
			} else { 
				String contentType = URLConnection
						.guessContentTypeFromName(file.getAbsolutePath());
				contentType = null == contentType ? "charset=UTF-8"
						: contentType + "; charset=UTF-8";
				entity = new FileEntity(file, contentType);
				response.setHeader("Content-Type", contentType);
			}
			response.setEntity(entity);
		} else { 
			response.setStatusCode(HttpStatus.SC_FORBIDDEN);
			StringEntity entity = new StringEntity(
					"<html><body><h1>Error 403, access denied.</h1></body></html>",
					"UTF-8");
			response.setHeader("Content-Type", "text/html");
			response.setEntity(entity);
		}
	}

	private StringEntity createDirListHtml(File dir, String target)
			throws UnsupportedEncodingException {
		
		StringBuffer sb = new StringBuffer();
		sb.append("<html>\n<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n<title>");
		sb.append(null == target ? dir.getAbsolutePath() : target);
		sb.append("Seeds Http Server</title>\n");
		sb.append("<link rel=\"shortcut icon\" href=\"/.SeedsWebService/img/favicon.ico\">\n");
		sb.append("<link rel=\"stylesheet\" type=\"text/css\" href=\"/.SeedsWebService/css/seedsWebService.css\">\n");
		sb.append("<link rel=\"stylesheet\" type=\"text/css\" href=\"/.SeedsWebService/css/examples.css\">\n");
		sb.append("<script type=\"text/javascript\" src=\"/.SeedsWebService/js/jquery-1.7.2.min.js\"></script>\n");
		sb.append("<script type=\"text/javascript\" src=\"/.SeedsWebService/js/jquery-impromptu.4.0.min.js\"></script>\n");
		sb.append("<script type=\"text/javascript\" src=\"/.SeedsWebService/js/seedsWebService.js\" charset=\"gbk\"></script>\n");
		sb.append("</head>\n<body>\n<h1 id=\"header\">");
		sb.append(null == target ? dir.getAbsolutePath() : target);
		sb.append("</h1>\n<table id=\"table\">\n");
		sb.append("<tr class=\"header\">\n<td>");
		sb.append(SeedsHttpServiceActivity.getHttpActivityContext().getString(R.string.seeds_http_webtitlename));
		sb.append("</td>\n<td class=\"detailsColumn\">");
		sb.append(SeedsHttpServiceActivity.getHttpActivityContext().getString(R.string.seeds_http_webtitlesize));
		sb.append("</td>\n<td class=\"detailsColumn\">");
		sb.append(SeedsHttpServiceActivity.getHttpActivityContext().getString(R.string.seeds_http_webtitledate));
		sb.append("</td>\n<td class=\"detailsColumn\">");
		sb.append(SeedsHttpServiceActivity.getHttpActivityContext().getString(R.string.seeds_http_webtitleopera));
		sb.append("</td>\n</tr>\n");
		
		Logger.debug("getAbsolutePath() : "+dir.getAbsolutePath() + " webRoot:"+this.webRoot);
		if (!isSamePath(dir.getAbsolutePath(), this.webRoot)) {
			sb.append("<tr>\n<td><a class=\"icon up\" href=\"..\">[Back]</a></td>\n<td></td>\n<td></td>\n<td></td>\n</tr>\n");
		}
		
		File[] files = dir.listFiles();
		if (null != files) {
			sort(files); 
			for (File f : files) {
				appendRow(sb, f);
			}
		}
		sb.append("</table>\n<hr noshade>\n<em>Welcome to <a target=\"_blank\" href=\"http://SEEDSCLOUD.tk/\">Simplelife Studio</a>!</em>\n</body>\n</html>");
		return new StringEntity(sb.toString(), "UTF-8");
	}

	private boolean isSamePath(String a, String b) {
		int aLength = a.length();
		int bLength = b.length();
		String left;
		
		if(aLength >= bLength)
			left = a.substring(b.length(), a.length());
		else
			left = b.substring(a.length(), b.length());
			
		if (left.length() >= 2) {
			return false;
		}
		if (left.length() == 1 && !left.equals("/")) {
			return false;
		}
		return true;
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

	@SuppressLint("SimpleDateFormat")
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
		sb.append(WebServer.SUFFIX_ZIP);
		sb.append("\">");
		sb.append(SeedsHttpServiceActivity.getHttpActivityContext().getString(R.string.seeds_http_webdownloadbtn));
		sb.append("</a></span>");
		sb.append("<span style=\"font-size:12px;\">&nbsp;&nbsp;&nbsp;</span>");
		if (f.canWrite() && !hasSeedsWebDir(f)) {
			sb.append("<span><a href=\"");
			sb.append(link);
			sb.append(WebServer.SUFFIX_DEL);
			sb.append("\" onclick=\"return confirmDelete('");
			sb.append(link);
			sb.append(WebServer.SUFFIX_DEL);
			sb.append("')\">");
			sb.append(SeedsHttpServiceActivity.getHttpActivityContext().getString(R.string.seeds_http_webdeletebtn));
			sb.append("</a></span>");
		}
		sb.append("</td>\n</tr>\n");
	}

	public static boolean hasSeedsWebDir(File f) {
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
