/**
 * TorrentCheckTask.java
 * 
 * History:
 *     2013-7-18: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server;

import java.io.File;
import java.io.FilenameFilter;
import java.util.Date;
import java.util.TimerTask;

import com.simplelife.seeds.server.util.DBExistResult;
import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.DateUtil;
import com.simplelife.seeds.server.util.GlobalSetting;
import com.simplelife.seeds.server.util.HttpUtil;
import com.simplelife.seeds.server.util.LogUtil;
import com.simplelife.seeds.server.util.TableColumnName;
import com.simplelife.seeds.server.util.TableName;

/**
 * 
 */
public class TorrentCheckTask extends TimerTask
{
    @Override
    public void run()
    {
        checkExpiredRssInDb();
        checkExpiredTorrentFile();
    }
    
    /**
     * Remove expired RSS record in DB
     */
    public void checkExpiredRssInDb()
    {
        String deleteDate = DateUtil.getDateStringByDayBack(GlobalSetting.torrentExpireDays);
        String sql = "delete from " + TableName.Cart + " where " + TableColumnName.date + " <= '" + deleteDate + "'";
        DaoWrapper.executeSql(sql);
    }
    
    /**
     * Remove expired torrent file
     */
    public void checkExpiredTorrentFile()
    {
        LogUtil.info("Start to check expired torrent file.");
        String strPath = HttpUtil.getSeedSavePath();
        File seedPath = new File(strPath);
        
        if (!seedPath.exists())
        {
            LogUtil.warning("Seed save path is not existent: " + strPath);
            return;
        }
        
        if (!seedPath.isDirectory())
        {
            LogUtil.severe("Seed save path is invalid: " + strPath);
            return;
        }
        
        checkAndDeleteFile(seedPath);
        LogUtil.info("Finished check expired torrent file.");
    }
    
    /**
     * Check and delete file under given path
     * @param seedPath: path to be checked
     */
    public void checkAndDeleteFile(File seedPath)
    {
        File[] torrentFiles = seedPath.listFiles();
        File torrentFile;
        Date date;
        long dayDiff;
        for (int i = 0; i < torrentFiles.length; i++)
        {
            torrentFile = torrentFiles[i];
            if (torrentFile.getName().endsWith(".torrent"))
            {
                date = new Date(torrentFile.lastModified());
                dayDiff = DateUtil.getDaysFromToday(date); 
                if (dayDiff < -GlobalSetting.torrentExpireDays)
                {
                    torrentFile.delete();
                }
            }
        }
    }
}
