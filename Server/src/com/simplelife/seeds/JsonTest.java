package com.simplelife.seeds;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.concurrent.atomic.AtomicInteger;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.fasterxml.jackson.core.*;

public class JsonTest {
	
	public void Test(HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		final PrintWriter out = response.getWriter();
		
		final String[] FIELD_NAMES = new String[] {
	        "a", "b", "c", "x", "y", "b13", "abcdefg", "a123",
	        "a0", "b0", "c0", "d0", "e0", "f0", "g0", "h0",
	        "x2", "aa", "ba", "ab", "b31", "___x", "aX", "xxx",
	        "a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2",
	        "a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3",
	        "a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1",
	    };
		
		StringBuilder sb = new StringBuilder();
        sb.append("{ ");

        int len = FIELD_NAMES.length;
        for (int i = 0; i < len; ++i) {
            if (i > 0) {
                sb.append(", ");
            }
            sb.append('"');
            sb.append(FIELD_NAMES[len - (i+1)]);
            sb.append("\" : ");
            sb.append(i);
        }
        sb.append(" }");
        String doc = sb.toString();
        out.println(doc);
		
		final JsonFactory jf = new JsonFactory();
		
		byte[] data = doc.getBytes("UTF-8");
		InputStream is = new ByteArrayInputStream(data);
		JsonParser jp = jf.createParser(is);

	    String stemp;
	    int itemp;
        for (int i = 0; i < len; ++i) {
        	JsonToken token = jp.nextToken();
        	
        	out.println("jp.getNumberType()");
        	
    		out.println(jp.getNumberType().toString());
    		out.println("<br>");
    	
        	out.println("jp.getText()");
        	out.println(jp.getText());
        	out.println("<br>");
        	
        	
        	//stemp = token.values().length;
        	
        	//out.println("jp.getIntValue()  ");
        	//out.println(token.asString());
        	//out.println("<br>");

            //out.println("<br>");
        }
        
	}
	
    private void parse(JsonFactory jf, byte[] input) throws IOException
    {
        JsonParser jp = jf.createParser(input, 0, input.length);
        while (jp.nextToken() != null) {
            ;
        }
        jp.close();
    }
}
