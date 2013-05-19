package com.simplelife.seeds.android;

import java.util.ArrayList;

public class SeedsEntity {
	
	// Seed ID primary key of table Seed
	public int seedId;
	
	// The type of the seed, movie av or else
	public String type;
	
	// The source url where the seeds come from
	public String source;
	
	// The date when the seed is published
	public String publishDate;
	
	// The name of the seed
	public String name;
	
	// The size of the movie
	public String size;
	
	// The video format of the movie
	public String format;
	
	// The url of the torrent
	public String torrentLink;
	
	// The hash verification of the seed
	public String hash;
	
	// With mosaic or without
	public boolean mosaic;
	
	// For further use
	public String memo;
	
	// Favorite tag for the seed
	public boolean favorite;
	
	// The picture array for the seed
	public ArrayList<String> picLinks;
	
	public SeedsEntity(){
		picLinks = new ArrayList<String>();
	}
	
	public void addPicLink(String inPicLink){
		picLinks.add(inPicLink);
	}
	
	public void setSeedType(String inType){
		this.type = inType;
	}
	
	public void setSeedSource(String inSource){
		this.source = inSource;
	}
	
	public void setSeedPublishDate(String inPublishDate){
		this.publishDate = inPublishDate;
	}
	
	public void setSeedName(String inName){
		this.name = inName;
	}
	
	public void setSeedSize(String inSize){
		this.size = inSize;
	}
	
	public void setSeedFormat(String inFormat){
		this.format = inFormat;
	}
	
	public void setSeedTorrentLink(String inTorrentLink){
		this.torrentLink = inTorrentLink;
	}
	
	public void setSeedHash(String inHash){
		this.hash = inHash;
	}
	
	public void setSeedMosaic(String inMosaic){
		//this.mosaic = inMosaic;
		this.mosaic = false;
	}
	
	public void setSeedMemo(String inMemo){
		this.memo = inMemo;
	}
	
	public void setSeedFavorite(boolean inFavorite){
		this.favorite = inFavorite;
	}
	public String getSeedType(){
		return this.type;
	}
	
	public String getSeedSource(){
		return this.source;
	}
	
	public String getSeedPublishDate(){
		return this.publishDate;
	}
	
	public String getSeedName(){
		return this.name;
	}
	
	public String getSeedSize(){
		return this.size;
	}
	
	public String getSeedFormat(){
		return this.format;
	}
	
	public String getSeedTorrentLink(){
		return this.torrentLink;
	}
	
	public String getSeedHash(){
		return this.hash;
	}
	
	public boolean getSeedMosaic(){
		//this.mosaic = inMosaic;
		return this.mosaic;
	}
	
	public String getSeedMemo(){
		return this.memo;
	}
	
	public boolean getSeedFavorite(){
		return this.favorite;
	}
	
	public ArrayList<String> getPicLinks(){
		return this.picLinks;
	}
	
}
