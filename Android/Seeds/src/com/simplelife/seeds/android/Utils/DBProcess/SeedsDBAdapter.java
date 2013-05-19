package com.simplelife.seeds.android.Utils.DBProcess;

import com.simplelife.seeds.android.SeedsEntity;

import android.content.ContentValues;
import android.content.Context;  
import android.database.*;  
import android.database.sqlite.*;  
import android.database.sqlite.SQLiteDatabase.CursorFactory;
import android.util.Log;  

/** 
 * This is a Assets Database Adapter 
 * Use it, you can operate the database via interfaces 
 *  
 *  
 * How to use: 
 * 1.   
 *  
 * Using example: 
 */  

public class SeedsDBAdapter {

	// The name of database file
	public static final String DATABASE_NAME = "Seeds_App_Database.db";
		
	// The table name of the database
	public static final String DATABASE_TABLE_SEED = "Seed";
	public static final String DATABASE_TABLE_SEEDPIC = "SeedPicture";
		
	// The key ID of the database seed
	public static final String KEY_ID_SEED = "seedId";

	// The key ID of the database seedPicture
	public static final String KEY_ID_SEEDPIC = "pictureId";
	
	// The name of the database item
	public static final String KEY_TYPE = "type";
	public static final String KEY_SOURCE = "source";
	public static final String KEY_PUBLISHDATE = "publishDate";
	public static final String KEY_NAME = "name";
	public static final String KEY_SIZE = "size";
	public static final String KEY_FORMAT = "format";
	public static final String KEY_TORRENTLINK = "torrentLink";
	public static final String KEY_HASH = "hash";
	public static final String KEY_MOSAIC = "mosaic";
	public static final String KEY_MEMO = "memo";
	public static final String KEY_FAVORITE = "favorite";
	public static final String KEY_PICLINKS = "piclinks";
	public static final String KEY_PICTURELINK = "pictureLink";
	
	// The version the database
	public static final int DATABASE_VERSION = 1;
 
	public static final int NAME_COLUMN = 1;
 
	// TODO: Create public field for each column in your table.  
	// SQL Statement to create a new database.
	// Another option is that we leave the db file inside the package,
	// and let it be released together with the binary. Hence below
	// two commands might be useless, anyway we will leave it here
	// for further reference
	private static final String DATABASE_CREATE_SEED = "create table " +   
			DATABASE_TABLE_SEED + " (" + KEY_ID_SEED + " integer primary key autoincrement, " +  
					KEY_NAME + " text not null);";  

	private static final String DATABASE_CREATE_SEEDPIC = "create table " +   
			DATABASE_TABLE_SEEDPIC + " (" + KEY_ID_SEEDPIC + " integer primary key autoincrement, " +  
					KEY_NAME + " text not null);";  
	
	// Variable to hold the database instance 	
 	private static SQLiteDatabase mSQLiteDatabase = null;
 	 
 	// Context of the application using the database.  
 	private final Context context; 
 	
    // Singleton Pattern  
    private static SeedsDBAdapter adpInstance = null;  
      
    /** 
     * Initialize SeedsDBManager 
     * @param context, context of application 
     */  
    public static void initAdapter(Context context){  
    	Log.i("SeedsDBAdapter", "Initialize the DB Adapter!");
    	if(adpInstance == null){  
        	adpInstance = new SeedsDBAdapter(context);  
        }  
        
    	Log.i("SeedsDBAdapter", "Initialize the DB Manager!");
        // Initialize the DB Manager
 		SeedsDBManager.initManager(context); 
 		
		// Retrieve the DB process handler to get data 
		SeedsDBManager mDBHandler = SeedsDBManager.getManager();
		
		Log.i("SeedsDBAdapter", "Initialize the mSQLiteDatabase!");
		// Put a warning info here in case the DBHandler is null
		mSQLiteDatabase = mDBHandler.getDatabase(DATABASE_NAME); 
    }  
      
    public static SeedsDBAdapter getAdapter(){  
        return adpInstance;  
    } 
  
 	public SeedsDBAdapter (Context _context) { 		
 		context = _context; 		
 	}  
 
 	public void close() {   
 		mSQLiteDatabase.close();   
 	}  
 
	public long insertEntryToSeed(SeedsEntity _seedsEntity)
	{	    
		ContentValues initialValues = new ContentValues();
	    initialValues.put(KEY_TYPE, _seedsEntity.type);
	    initialValues.put(KEY_SOURCE, _seedsEntity.source);
	    initialValues.put(KEY_PUBLISHDATE, _seedsEntity.publichDate);
	    initialValues.put(KEY_NAME, _seedsEntity.name);
	    initialValues.put(KEY_SIZE, _seedsEntity.size);
	    initialValues.put(KEY_FORMAT, _seedsEntity.format);
	    initialValues.put(KEY_TORRENTLINK, _seedsEntity.torrentLink);
	    initialValues.put(KEY_HASH, _seedsEntity.hash);
	    initialValues.put(KEY_MOSAIC, _seedsEntity.mosaic);
	    initialValues.put(KEY_MEMO, _seedsEntity.memo);
	    initialValues.put(KEY_FAVORITE, _seedsEntity.favorite);
	    
	    return mSQLiteDatabase.insert(DATABASE_TABLE_SEED, null, initialValues);
	}
	
	public long insertEntryToSeedPic(int _seedId, String _picUrl)
	{
	    ContentValues initialValues = new ContentValues();
	    initialValues.put(KEY_ID_SEEDPIC, _seedId);
	    initialValues.put(KEY_PICTURELINK, _picUrl);
	    
	    return mSQLiteDatabase.insert(DATABASE_TABLE_SEEDPIC, null, initialValues);
	} 	
 
 	public boolean removeSeedEntry(int _seedId) {  
 
 		return mSQLiteDatabase.delete(DATABASE_TABLE_SEED, KEY_ID_SEEDPIC + "=" + _seedId, null) > 0;  
 	}  
 
 	public Cursor getAllSeedEntries () {  
 
 		return mSQLiteDatabase.query(DATABASE_TABLE_SEED, 
 				new String[] { 
 				KEY_TYPE, KEY_SOURCE, KEY_PUBLISHDATE, KEY_NAME,
 				KEY_SIZE, KEY_FORMAT},  
 				null, null, null, null, null, null);  
 	}  
 
 	public Cursor getSeedEntryViaPublishDate(String _pdDate) throws SQLException
	{
 		Cursor mCursor = mSQLiteDatabase.query(true, 
	    		DATABASE_TABLE_SEED, 
	    		new String[]{KEY_ID_SEED, KEY_NAME, KEY_SIZE, KEY_FORMAT, KEY_TORRENTLINK}, 
	    		KEY_PUBLISHDATE+ "='" + _pdDate + "'",
	    		null,null,null,null,null);

 		if(mCursor!=null)
	    {
	        mCursor.moveToFirst();
	    }
	   
	    return mCursor;
	}
 	
 	public Cursor getSeedEntryViaFavTag() throws SQLException
 	{
 		Cursor mCursor = mSQLiteDatabase.query(true, 
	    		DATABASE_TABLE_SEED, 
	    		new String[]{KEY_ID_SEED, KEY_NAME, KEY_SIZE, KEY_FORMAT, KEY_TORRENTLINK}, 
	    		KEY_FAVORITE+ "=1",
	    		null,null,null,null,null);

 		if(mCursor!=null)
	    {
	        mCursor.moveToFirst();
	    }
	   
	    return mCursor;
 		
 	}

 	public Cursor getSeedPicFirstEntryViaSeedId(int _seedId) throws SQLException
	{
	    Cursor mCursor = mSQLiteDatabase.query(true, 
	    		DATABASE_TABLE_SEEDPIC, 
	    		new String[]{KEY_ID_SEEDPIC,KEY_PICTURELINK}, 
	    		KEY_ID_SEED+ "=" + _seedId,
	    		null,null,null,null,null);
	    
	    if(mCursor!=null)
	    {
	        mCursor.moveToFirst();
	    }
	   
	    return mCursor;
	}
 	
 	public Cursor getSeedPicEntryViaSeedId(int _seedId) throws SQLException
	{
	    Cursor mCursor = mSQLiteDatabase.query(true, 
	    		DATABASE_TABLE_SEEDPIC, 
	    		new String[]{KEY_PICTURELINK}, 
	    		KEY_ID_SEED+ "=" + _seedId,
	    		null,null,null,null,null);
	    
	    if(mCursor!=null)
	    {
	        mCursor.moveToFirst();
	    }
	   
	    return mCursor;
	}
 	
 	public boolean updateSeedEntryFav(int _seedId, boolean _favTag) {  
 
 		String where = KEY_ID_SEED + "=" + _seedId;
 		
 		ContentValues contentValues = new ContentValues();  
 		// Fill in the ContentValue based on the new object  
 		contentValues.put(KEY_FAVORITE, _favTag);

 		return mSQLiteDatabase.update(DATABASE_TABLE_SEED, contentValues, where, null) > 0;  
 	}
 	
 	public boolean isSeedSaveToFavorite(int _seedId){
	    
 		Cursor mCursor = mSQLiteDatabase.query(true, 
	    		DATABASE_TABLE_SEED, 
	    		new String[]{KEY_FAVORITE}, 
	    		KEY_ID_SEED+ "=" + _seedId,
	    		null,null,null,null,null);
	    
	    if(mCursor!=null)
	    {
	        mCursor.moveToFirst();
	    }
	    
	    if (1 == mCursor.getInt(mCursor.getColumnIndex(KEY_FAVORITE)))
	    	return true;
	    else
	    	return false;
 	}
 	 
}