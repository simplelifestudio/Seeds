package com.simplelife.seeds.server;

import java.util.TimerTask;
import java.util.logging.Logger;

public class SeedCaptureTask extends TimerTask {
	private Logger logger = Logger.getLogger("SeedCaptureTask");
	
	@Override
	public void run() {
		logger.info("Seed capture task launched!");
		
		SeedCaptureListener.scheduleNextCapture();
		HtmlParser parser = new HtmlParser();
		parser.Parse(); 
	}

}
