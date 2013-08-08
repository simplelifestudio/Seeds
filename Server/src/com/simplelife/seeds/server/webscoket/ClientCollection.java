/**
 * ClientDelegate.java
 * 
 * History:
 *     2013-8-6: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.webscoket;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.simplelife.seeds.server.util.LogUtil;

/**
 * 
 */
public class ClientCollection
{
    private static HashMap <String, SeedsMessageInbound> clients = new HashMap <String, SeedsMessageInbound>();
    
    public static HashMap <String, SeedsMessageInbound> getClients()
    {
        return clients;
    }
    
    
    public static boolean empty()
    {
        return clients.size() == 0;
    }
    
    public static SeedsMessageInbound getClient(String clientId)
    {
        return clients.get(clientId);
    }
    
    public static synchronized void addClient(String clientId, SeedsMessageInbound msgInbound)
    {
        msgInbound.setClientId(clientId);
        clients.put(clientId, msgInbound);
        LogUtil.info("Client was added with id: " + clientId + ", client list size now is: " + clients.size());
    }
    
    public static synchronized void removeClient(String clientId)
    {
        if (!clients.containsKey(clientId))
        {
            LogUtil.warning("Client can't be found by clientID: " + clientId);
            return;
        }
        clients.remove(clientId);
        LogUtil.info("Client was removed with clientID: " + clientId + ", client list size now is: " + clients.size());
    }
    
    public static void sendMsgToClient(String clientId, String message)
    {
        if (empty())
        {
            LogUtil.info("Client collection is empty");
            return;
        }
        
        SeedsMessageInbound msgInbound = clients.get(clientId);
        if (msgInbound == null)
        {
            LogUtil.warning("Client can't be found by clientID: " + clientId);
            return;
        }
        msgInbound.sendMessage(message);
    }
}
