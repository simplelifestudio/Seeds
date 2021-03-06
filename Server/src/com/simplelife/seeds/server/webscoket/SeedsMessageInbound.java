/**
 * Ma.java
 * 
 * History:
 *     2013-8-6: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.webscoket;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.util.Hashtable;

import net.sf.json.JSONObject;

import com.simplelife.seeds.server.json.IJsonRequest;
import com.simplelife.seeds.server.json.JsonRequestFactory;
import com.simplelife.seeds.server.util.DateUtil;
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
        LogUtil.info("Binary data received on: " + this.clientId);
        getWsOutbound().writeBinaryMessage(message);
    }

    @Override
    protected void onTextMessage(CharBuffer message) throws IOException {
        LogUtil.info("Text Message received on: " + this.clientId);
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
        
        /*
        Hashtable<String, Object> response = new Hashtable<String, Object>();
        Hashtable<String, Object> body = new Hashtable<String, Object>();
        
        response.put(JsonKey.id, "WSChatMessage");
        response.put(JsonKey.body, body);
        
        body.put("content", "Are you there?");
        body.put("time", DateUtil.getNow());
        
        */
        
        ByteArrayOutputStream byteArray = new ByteArrayOutputStream(); 
        PrintWriter out = new PrintWriter(byteArray);
        IJsonRequest jsonCmd = JsonRequestFactory.CreateJsonCommand(out, jsonObj, this.clientId);
        
        if (jsonCmd == null)
        {
            LogUtil.warning("Illegal command received from client: " + jsonObj.toString());
            return;
        }
        
        jsonCmd.Execute();
        out.flush();
        
        //LogUtil.info("out: "+ out.toString());
        //LogUtil.info("byteArray: "+ byteArray.size());
        
        String strResponse = byteArray.toString();
        //LogUtil.info("strResponse: "+ strResponse);
        
        CharBuffer buffer = CharBuffer.allocate(strResponse.length());
        buffer.put(strResponse);
        buffer.flip();
        
        if (strResponse.length() > 100)
        {
            LogUtil.info("Response: "+ strResponse.substring(0, 100));
        }
        else
        {
            LogUtil.info("Response: "+ strResponse);
        }
        try
        {
            getWsOutbound().writeTextMessage(buffer);
        } 
        catch (IOException e)
        {
            LogUtil.printStackTrace(e);
        }
    }
    
    public void ping()
    {
        ByteBuffer pingData = ByteBuffer.allocate(5);
        //pingData.putChar('c');
        //pingData.putChar('h');
        //pingData.putChar('e');
        //pingData.putChar('n');
        //pingData.flip();
        try
        {
            getWsOutbound().ping(pingData);
        } catch (IOException e)
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
    protected void onPing(ByteBuffer payload)
    {
        String temp = new String(payload.array());
        LogUtil.info("onPing triggerred, content: " + temp + ", clientID: " + this.clientId);
        super.onPong(payload);
    }
    
    @Override
    protected void onPong(ByteBuffer payload)
    {
        String temp = new String(payload.array());
        LogUtil.info("onPong triggerred, content: " + temp+ ", clientID: " + this.clientId);
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