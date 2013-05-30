package com.simplelife.seeds.server;

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
	public int getStatus() {
		return status;
	}
	/**
	 * @param status the status to set
	 */
	public void setStatus(int status) {
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
	private int status;
	private long id;
	
	public String toString()
	{
		String tmpStr;
		
		tmpStr = "id: " + Long.toString(id) + "\n";
		tmpStr += "publishDate: " + publishDate + "\n";
		tmpStr += "status: " + Integer.toString(status) + "\n";
		return tmpStr;
	}
}
