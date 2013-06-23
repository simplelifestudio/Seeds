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

import com.simplelife.seeds.server.parser.HtmlParser;
import com.simplelife.seeds.server.util.LogUtil;

public class SeedCaptureTask extends TimerTask {
	
	@Override
	public void run() {
		LogUtil.info("Seed capture task launched!");
		HtmlParser parser = new HtmlParser();
		parser.Parse();
		SeedCaptureListener.scheduleNextCapture();
	}

}
