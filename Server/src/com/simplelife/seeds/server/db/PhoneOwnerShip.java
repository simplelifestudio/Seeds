/**
 * PhoneOwnerShip.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.db;

public class PhoneOwnerShip {
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
	 * @return the userId
	 */
	public long getUserId() {
		return userId;
	}
	/**
	 * @param userId the userId to set
	 */
	public void setUserId(long userId) {
		this.userId = userId;
	}
	/**
	 * @return the phoneId
	 */
	public long getPhoneId() {
		return phoneId;
	}
	/**
	 * @param phoneId the phoneId to set
	 */
	public void setPhoneId(long phoneId) {
		this.phoneId = phoneId;
	}
	
	
	private long id;
	private long userId;
	private long phoneId;
}
