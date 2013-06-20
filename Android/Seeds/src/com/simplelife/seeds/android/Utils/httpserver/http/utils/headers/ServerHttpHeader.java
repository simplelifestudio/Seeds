package com.simplelife.seeds.android.utils.httpserver.http.utils.headers;

/**
 * <p>
 * Standard Server HTTP header response
 * </p>
 * @author Matt
 *
 */
public class ServerHttpHeader extends HttpHeader {

	public String toString() {
		return "Server: AndroidHTTPServer (android/linux)" + HEADER_LINE_SEPARATOR;
	}
	
}
