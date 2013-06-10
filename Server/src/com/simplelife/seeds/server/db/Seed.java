/**
 * Seed.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.db;

import java.util.HashSet;
import java.util.Set;


public class Seed {
	private long seedId;
	private String type;
	private String source;
	private String publishDate;
	private String name;
	private String size;
	private String format;
	private String torrentLink;
	private String hash;
	private String mosaic;
	private String memo;
	
	/**
	 * @return the pictures
	 */
	public Set<PreviewPic> getPictures() {
		return pictures;
	}

	/**
	 * @param pictures the pictures to set
	 */
	public void setPictures(Set<PreviewPic> pictures) {
		this.pictures = pictures;
	}

	private Set<PreviewPic> pictures = new HashSet<PreviewPic>();

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
	 * @return the type
	 */
	public String getType() {
		return type;
	}

	/**
	 * @param type the type to set
	 */
	public void setType(String type) {
		this.type = type;
	}

	/**
	 * @return the source
	 */
	public String getSource() {
		return source;
	}

	/**
	 * @param source the source to set
	 */
	public void setSource(String source) {
		this.source = source;
	}

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
	 * @return the name
	 */
	public String getName() {
		return name;
	}

	/**
	 * @param name the name to set
	 */
	public void setName(String name) {
		this.name = name;
	}

	/**
	 * @return the size
	 */
	public String getSize() {
		return size;
	}

	/**
	 * @param size the size to set
	 */
	public void setSize(String size) {
		this.size = size;
	}

	/**
	 * @return the format
	 */
	public String getFormat() {
		return format;
	}

	/**
	 * @param format the format to set
	 */
	public void setFormat(String format) {
		this.format = format;
	}

	/**
	 * @return the torrentLink
	 */
	public String getTorrentLink() {
		return torrentLink;
	}

	/**
	 * @param torrentLink the torrentLink to set
	 */
	public void setTorrentLink(String torrentLink) {
		this.torrentLink = torrentLink;
	}

	/**
	 * @return the hash
	 */
	public String getHash() {
		return hash;
	}

	/**
	 * @param hash the hash to set
	 */
	public void setHash(String hash) {
		this.hash = hash;
	}

	/**
	 * @return the mosaic
	 */
	public String getMosaic() {
		return mosaic;
	}

	/**
	 * @param mosaic the mosaic to set
	 */
	public void setMosaic(String mosaic) {
		this.mosaic = mosaic;
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
	
	public void addPicture(String picLink)
	{
		PreviewPic pic = new PreviewPic();
		pic.setPictureLink(picLink);
		
		pictures.add(pic);
	}
	
	public void addPicture(PreviewPic pic)
	{
		if (pictures.contains(pic))
		{
			return;
		}
		
		pictures.add(pic);
	}
	
	public String toString()
	{
		StringBuilder strBuilder = new StringBuilder();
		
		strBuilder.append("type:");
		strBuilder.append(getType());
		strBuilder.append("\n");

		strBuilder.append("source:");
		strBuilder.append(getSource());
		strBuilder.append("\n");

		strBuilder.append("publishDate:");
		strBuilder.append(getPublishDate());
		strBuilder.append("\n");

		strBuilder.append("name:");
		strBuilder.append(getName());
		strBuilder.append("\n");

		strBuilder.append("size:");
		strBuilder.append(getSize());
		strBuilder.append("\n");

		strBuilder.append("format:");
		strBuilder.append(getFormat());
		strBuilder.append("\n");

		strBuilder.append("torrentLink:");
		strBuilder.append(getTorrentLink());
		strBuilder.append("\n");

		strBuilder.append("hash:");
		strBuilder.append(getHash());
		strBuilder.append("\n");

		strBuilder.append("mosaic:");
		strBuilder.append(getMosaic());
		strBuilder.append("\n");

		strBuilder.append("memo:");
		strBuilder.append(getMemo());
		strBuilder.append("\n");

		java.util.Iterator<PreviewPic> it = pictures.iterator();
		PreviewPic pic;
		while (it.hasNext())
		{
			pic = it.next();
			strBuilder.append("PictureId: ");
			strBuilder.append(pic.getPictureId());
			strBuilder.append("\n");
			
			strBuilder.append("Picture Link: ");
			strBuilder.append(pic.getPictureLink());
			strBuilder.append("\n");
			
			strBuilder.append("SeedId: ");
			strBuilder.append(pic.getSeedId());
			strBuilder.append("\n");
			
			strBuilder.append("Memo: ");
			strBuilder.append(pic.getMemo());
			strBuilder.append("\n");
		}
		return strBuilder.toString();
	}
}
