/**
 * GlobalSetting.java
 * 
 * History:
 *     2013-7-18: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.util;

import java.util.logging.Level;

/**
 * Global setting
 */
public class GlobalSetting
{
    private static int torrentExpireDays = 30;
    private static String hostIP = "192.81.135.31";
    //private static Level logLevel = Level.INFO;
    /**
     * @return the torrentexpiredays
     */
    public static int getTorrentExpiredays()
    {
        return torrentExpireDays;
    }
    /**
     * @param torrentexpiredays the torrentexpiredays to set
     */
    public static void setTorrentExpiredays(int torrentexpiredays)
    {
        torrentExpireDays = torrentexpiredays;
    }
    /**
     * @return the hostip
     */
    public static String getHostIP()
    {
        return hostIP;
    }
    /**
     * @param hostip the hostip to set
     */
    public static void setHostIP(String hostip)
    {
        hostIP = hostip;
    }
    /**
     * @return the loglevel
     */
    public static Level getLogLevel()
    {
        return LogUtil.getLevel();
    }
    /**
     * @param loglevel the loglevel to set
     */
    public static void setLogLevel(Level loglevel)
    {
        LogUtil.setLevel(loglevel);
    }

}
