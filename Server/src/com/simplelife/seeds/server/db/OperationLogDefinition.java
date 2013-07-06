/**
 * OperationLogDefinition.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.db;

public class OperationLogDefinition {
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
	/**
	 * @return the logId
	 */
	public long getLogId() {
		return logId;
	}
	/**
	 * @param logId the logId to set
	 */
	public void setLogId(long logId) {
		this.logId = logId;
	}
	/**
	 * @return the description
	 */
	public String getDescription() {
		return description;
	}
	/**
	 * @param description the description to set
	 */
	public void setDescription(String description) {
		this.description = description;
	}
	private long id;
	private long logId;
	private String description;
}
