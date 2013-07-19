/**
 * SeedCaptureTask.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server;

import java.util.TimerTask;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import com.simplelife.seeds.server.parser.HtmlParser;
import com.simplelife.seeds.server.util.LogUtil;

public class SeedCaptureTask extends TimerTask {
    private final static Lock l = new ReentrantLock();
    
	@Override
	public void run() {
		LogUtil.info("Seed capture task launched.");
		l.lock();
		HtmlParser parser = new HtmlParser();
		parser.Parse();
		LogUtil.info("Seed capture task finished.");
		l.unlock();
	}
}
