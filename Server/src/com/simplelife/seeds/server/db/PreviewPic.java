/**
 * PreviewPic.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.db;

public class PreviewPic {
	/**
	 * @return the seedId
	 */
	public long getSeedId() {
		return seedId;
	}
	
	/**
	 * @param seedId the seedId to set
	 */
	public void setSeedId(long seedId) {
		this.seedId = seedId;
	}
	
	/**
	 * @return the pictureLink
	 */
	public String getPictureLink() {
		return pictureLink;
	}
	
	/**
	 * @param pictureLink the pictureLink to set
	 */
	public void setPictureLink(String pictureLink) {
		this.pictureLink = pictureLink;
	}
	
	/**
	 * @return the memo
	 */
	public String getMemo() {
		return memo;
	}
	
	/**
	 * @param memo the memo to set
	 */
	public void setMemo(String memo) {
		this.memo = memo;
	}
	/**
	 * @return the pictureId
	 */
	public long getPictureId() {
		return pictureId;
	}

	/**
	 * @param pictureId the pictureId to set
	 */
	public void setPictureId(long pictureId) {
		this.pictureId = pictureId;
	}
	private long pictureId;
	private long seedId;
	private String pictureLink;
	private String memo;
	
}
