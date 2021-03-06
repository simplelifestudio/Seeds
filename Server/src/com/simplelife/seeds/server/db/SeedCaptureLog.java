/**
 * SeedCaptureLog.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.db;

public class SeedCaptureLog {
	/**
	 * @return the publishDate
	 */
	public String getPublishDate() {
		return publishDate;
	}
	/**
	 * @param publishDate the publishDate to set
	 */
	public void setPublishDate(String publishDate) {
		this.publishDate = publishDate;
	}
	/**
	 * @return the status
	 */
	public long getStatus() {
		return status;
	}
	/**
	 * @param status the status to set
	 */
	public void setStatus(long status) {
		this.status = status;
	}
	/**
	 * @return the id
	 */
	public long getId() {
		return id;
	}
	/**
	 * @param id the id to set
	 */
	public void setId(long id) {
		this.id = id;
	}
	private String publishDate;
	private long status;
	private long id;
	
	public String toString()
	{
		String tmpStr;
		
		tmpStr = "id: " + Long.toString(id) + "\n";
		tmpStr += "publishDate: " + publishDate + "\n";
		tmpStr += "status: " + Long.toString(status) + "\n";
		return tmpStr;
	}
}
