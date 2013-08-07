/**
 * Ma.java
 * 
 * History:
 *     2013-8-6: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.webscoket;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.util.Hashtable;

import net.sf.json.JSONObject;

import org.apache.catalina.websocket.MessageInbound;
import org.apache.catalina.websocket.WsOutbound;

import com.simplelife.seeds.server.json.JsonRequestBase;
import com.simplelife.seeds.server.json.JsonResponseBase;
import com.simplelife.seeds.server.util.DateUtil;
import com.simplelife.seeds.server.util.ErrorCode;
import com.simplelife.seeds.server.util.JsonKey;
import com.simplelife.seeds.server.util.JsonUtil;
import com.simplelife.seeds.server.util.LogUtil;

/**
 * 
 */
public class SeedsMessageInbound extends MessageInbound 
{
    private String clientId;
    
    
    /**
     * @return the clientId
     */
    public String getClientId()
    {
        return clientId;
    }

    /**
     * @param clientId the clientId to set
     */
    public void setClientId(String clientId)
    {
        this.clientId = clientId;
    }

    public SeedsMessageInbound(int byteBufferMaxSize, int charBufferMaxSize) {
        super();
        setByteBufferMaxSize(byteBufferMaxSize);
        setCharBufferMaxSize(charBufferMaxSize);
    }

    @Override
    protected void onBinaryMessage(ByteBuffer message) throws IOException {
         getWsOutbound().writeBinaryMessage(message);
    }

    @Override
    protected void onTextMessage(CharBuffer message) throws IOException {
        LogUtil.info("Message received on websocket!");
        echoMessage(message);
    }
    
    
    public void echoMessage(CharBuffer message)
    {
        String request = message.toString().trim();
        if (request == null || request.length() == 0)
        {
            LogUtil.warning("Empty message received from client by websocket");
            return;
        }
        
        JSONObject jsonObj = JsonUtil.createJsonObject(request);
        if (jsonObj == null) {
            LogUtil.warning( "Invalid command received: \n" + request);
            
            request += "<" + DateUtil.getNow() + ">";
            CharBuffer buffer = CharBuffer.allocate(request.length());
            buffer.put(request);
            buffer.flip();
            
            try
            {
                getWsOutbound().writeTextMessage(buffer);
            } 
            catch (IOException e)
            {
                LogUtil.printStackTrace(e);
            }
            
            
            return;
        }
        
        if (!jsonObj.containsKey(JsonKey.id))
        {
            String err = "Illegal message: " + JsonKey.id +" can't be found.";
            LogUtil.warning(err);
            
            
            return;
        }
        
        String command = jsonObj.getString(JsonKey.id);
        if (!command.equals("WSChatMessage"))
        {
            String err = "Illegal message id : " + command +" found.";
            LogUtil.warning(err);
            return;
        }
        
        Hashtable<String, Object> response = new Hashtable<String, Object>();
        Hashtable<String, Object> body = new Hashtable<String, Object>();
        
        response.put(JsonKey.id, "WSChatMessage");
        response.put(JsonKey.body, body);
        
        body.put("content", "Are you there?");
        body.put("time", DateUtil.getNow());
        
        String strResponse = response.toString(); 
        CharBuffer buffer = CharBuffer.allocate(strResponse.length());
        buffer.put(strResponse);
        buffer.flip();
        LogUtil.info("Response: "+ strResponse);
        //LogUtil.info("buffer: " + buffer.toString());
        //getWsOutbound().writeTextMessage(buffer);
        try
        {
            getWsOutbound().writeTextMessage(buffer);
        } 
        catch (IOException e)
        {
            LogUtil.printStackTrace(e);
        }
    }
    
    @Override
    protected void onClose(int status)
    {
        ClientCollection.removeClient(this.clientId);
        LogUtil.info("Onclose, status: " + status);
        super.onClose(status);
    }
    
    @Override
    protected void onOpen(WsOutbound outbound)
    {
        LogUtil.info("onOpen triggerred.");
        super.onOpen(outbound);
    }
    
    @Override
    protected void onPong(ByteBuffer payload)
    {
        LogUtil.info("onPong triggerred, payload length: " + payload.capacity());
        super.onPong(payload);
    }
    
    public void sendMessage(String message)
    {
        CharBuffer buffer = CharBuffer.allocate(message.length());
        buffer.put(message);
        buffer.flip();
        
        try
        {
            getWsOutbound().writeTextMessage(buffer);
        } 
        catch (IOException e)
        {
            LogUtil.printStackTrace(e);
        }
    }
}