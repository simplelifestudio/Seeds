/**
 * Phone.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.db;

public class Phone {
	private long id;
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
	 * @return the serialNo
	 */
	public String getSerialNo() {
		return serialNo;
	}
	/**
	 * @param serialNo the serialNo to set
	 */
	public void setSerialNo(String serialNo) {
		this.serialNo = serialNo;
	}
	/**
	 * @return the os
	 */
	public int getOs() {
		return os;
	}
	/**
	 * @param os the os to set
	 */
	public void setOs(int os) {
		this.os = os;
	}
	/**
	 * @return the osVersion
	 */
	public String getOsVersion() {
		return osVersion;
	}
	/**
	 * @param osVersion the osVersion to set
	 */
	public void setOsVersion(String osVersion) {
		this.osVersion = osVersion;
	}
	/**
	 * @return the appVersion
	 */
	public String getAppVersion() {
		return appVersion;
	}
	/**
	 * @param appVersion the appVersion to set
	 */
	public void setAppVersion(String appVersion) {
		this.appVersion = appVersion;
	}
	
	
	private String serialNo;
	private int os;
	private String osVersion;
	private String appVersion;
}
