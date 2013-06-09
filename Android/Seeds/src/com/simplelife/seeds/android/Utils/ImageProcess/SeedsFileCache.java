package com.simplelife.seeds.android.utils.imageprocess;

import java.io.File;

import android.content.Context;
import android.util.Log;
 
public class SeedsFileCache {
     
    private File cacheDir;
     
    public SeedsFileCache(Context context){
        
    	// Find a place to cache the images
        if (android.os.Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED))
            cacheDir = new File(android.os.Environment.getExternalStorageDirectory(),"Seeds");
        else
            cacheDir=context.getCacheDir();
        if(!cacheDir.exists())
            cacheDir.mkdirs();
        Log.i("SeedsFileCache","Working on creating the cache folder " + cacheDir);
    }
     
    public File getFile(String url){
         
        String filename = String.valueOf(url.hashCode());
        File f = new File(cacheDir, filename);
        return f;
         
    }
     
    public void clear(){
        File[] files = cacheDir.listFiles();
        if(files == null)
            return;
        for(File f:files)
            f.delete();
    }
 
}
