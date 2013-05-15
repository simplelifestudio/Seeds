package com.simplelife.Seeds;

public class SeedsEntity {
	
	// Seed ID primary key of table Seed
	public int seedId;
	
	// The type of the seed, movie av or else
	public String type;
	
	// The source url where the seeds come from
	public String source;
	
	// The date when the seed is published
	public String publichDate;
	
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

}
