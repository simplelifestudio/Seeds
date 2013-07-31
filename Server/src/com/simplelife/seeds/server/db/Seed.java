/**
 * Seed.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */


package com.simplelife.seeds.server.db;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import com.simplelife.seeds.server.util.DaoWrapper;
import com.simplelife.seeds.server.util.SqlUtil;


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
	public Set<SeedPicture> getPictures() {
		return pictures;
	}

	/**
	 * @param pictures the pictures to set
	 */
	public void setPictures(Set<SeedPicture> pictures) {
		this.pictures = pictures;
	}

	private Set<SeedPicture> pictures = new LinkedHashSet<SeedPicture>();

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
	
	/**
	 * Append a picture
	 * @param picLink: link of picture
	 */
	public void addPicture(String picLink)
	{
		SeedPicture pic = new SeedPicture();
		pic.setPictureLink(picLink);
		
		pictures.add(pic);
	}
	
	/**
	 * Append a picture
	 * @param pic: object of SeedPicture
	 */
	public void addPicture(SeedPicture pic)
	{
		if (pictures.contains(pic))
		{
			return;
		}
		
		pictures.add(pic);
	}
	
	/**
	 * Convert into string for RSS publish, some fields are hidden
	 * @return String of fields
	 */
	public String toRssString()
	{
		StringBuilder strBuilder = new StringBuilder();

        strBuilder.append("影片名称: ");
        strBuilder.append(getName());
        strBuilder.append("\n");

		strBuilder.append("影片大小: ");
		strBuilder.append(getSize());
		strBuilder.append("\n");

		strBuilder.append("影片格式: ");
		strBuilder.append(getFormat());
		strBuilder.append("\n");

		strBuilder.append("有码无码: ");
		strBuilder.append(getMosaic());
		strBuilder.append("\n");

		strBuilder.append("发布日期: ");
        strBuilder.append(getPublishDate());
        strBuilder.append("\n");

		String sql = SqlUtil.getSelectSeedPictureSql(SqlUtil.getSeedIdCondition(seedId));
        List<SeedPicture> pics = DaoWrapper.query(sql, SeedPicture.class);
        
		java.util.Iterator<SeedPicture> it = pics.iterator();
		SeedPicture pic;
		String strSeedId = Long.toString(this.seedId);
		int i = 0;
		while (it.hasNext())
		{
			pic = it.next();
			//strBuilder.append("<a href=\"");
			//strBuilder.append(pic.getPictureId());
			
			//strBuilder.append(": ");
			//strBuilder.append(pic.getPictureLink());
			//strBuilder.append("\">");
			i++;
			strBuilder.append("图片[" + Integer.toString(i) + "]");
			strBuilder.append(pic.getPictureLink());
			strBuilder.append("\n");
			//strBuilder.append("</a><br>");
		}
		return strBuilder.toString();
	}
	
	/**
	 * Convert values of fields into string
	 */
	public String toString()
	{
		StringBuilder strBuilder = new StringBuilder();
		
		strBuilder.append("\n类    型: ");
		strBuilder.append(getType());
		strBuilder.append("\n");

		strBuilder.append("来    源: ");
		strBuilder.append(getSource());
		strBuilder.append("\n");

		strBuilder.append("发布日期: ");
		strBuilder.append(getPublishDate());
		strBuilder.append("\n");

		strBuilder.append("影片名称: ");
		strBuilder.append(getName());
		strBuilder.append("\n");

		strBuilder.append("影片大小: ");
		strBuilder.append(getSize());
		strBuilder.append("\n");

		strBuilder.append("影片格式: ");
		strBuilder.append(getFormat());
		strBuilder.append("\n");

		strBuilder.append("影片链接: ");
		strBuilder.append(getTorrentLink());
		strBuilder.append("\n");

		strBuilder.append("哈 希 码: ");
		strBuilder.append(getHash());
		strBuilder.append("\n");

		strBuilder.append("有码无码: ");
		strBuilder.append(getMosaic());
		strBuilder.append("\n");

		strBuilder.append("备注信息: ");
		strBuilder.append(getMemo());
		strBuilder.append("\n");

		strBuilder.append("预览图片: \n");
		String sql = SqlUtil.getSelectSeedPictureSql(SqlUtil.getSeedIdCondition(seedId));
        List<SeedPicture> pics = DaoWrapper.query(sql, SeedPicture.class);
        
		java.util.Iterator<SeedPicture> it = pics.iterator();
		SeedPicture pic;
		while (it.hasNext())
		{
			pic = it.next();
			strBuilder.append("   - ");
			//strBuilder.append(pic.getPictureId());
			
			//strBuilder.append(": ");
			strBuilder.append(pic.getPictureLink());
			strBuilder.append("\n");
		}
		return strBuilder.toString();
	}
}
