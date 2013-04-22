package com.simplelife.seeds;

import java.util.Date;


public class Seed {
	private Long ID;
	private String Name;
	private String Size;
	private String Format;
	private String Hash;
	private String Mosaic;
	private String TorrentLink;
	private Date SaveDate;
	private String Memo;
	/**
	 * @return the iD
	 */
	public Long getID() {
		return ID;
	}
	/**
	 * @param iD the iD to set
	 */
	public void setID(Long iD) {
		ID = iD;
	}
	/**
	 * @return the size
	 */
	public String getSize() {
		return Size;
	}
	/**
	 * @param size the size to set
	 */
	public void setSize(String size) {
		Size = size;
	}
	/**
	 * @return the name
	 */
	public String getName() {
		return Name;
	}
	/**
	 * @param name the name to set
	 */
	public void setName(String name) {
		Name = name;
	}
	/**
	 * @return the hash
	 */
	public String getHash() {
		return Hash;
	}
	/**
	 * @param hash the hash to set
	 */
	public void setHash(String hash) {
		Hash = hash;
	}
	/**
	 * @return the mosaic
	 */
	public String getMosaic() {
		return Mosaic;
	}
	/**
	 * @param mosaic the mosaic to set
	 */
	public void setMosaic(String mosaic) {
		Mosaic = mosaic;
	}
	/**
	 * @return the format
	 */
	public String getFormat() {
		return Format;
	}
	/**
	 * @param format the format to set
	 */
	public void setFormat(String format) {
		Format = format;
	}
	/**
	 * @return the torrentLink
	 */
	public String getTorrentLink() {
		return TorrentLink;
	}
	/**
	 * @param torrentLink the torrentLink to set
	 */
	public void setTorrentLink(String torrentLink) {
		TorrentLink = torrentLink;
	}
	/**
	 * @return the saveDate
	 */
	public Date getSaveDate() {
		return SaveDate;
	}
	/**
	 * @param saveDate the saveDate to set
	 */
	public void setSaveDate(Date saveDate) {
		SaveDate = saveDate;
	}
	/**
	 * @return the memo
	 */
	public String getMemo() {
		return Memo;
	}
	/**
	 * @param memo the memo to set
	 */
	public void setMemo(String memo) {
		Memo = memo;
	}

}
