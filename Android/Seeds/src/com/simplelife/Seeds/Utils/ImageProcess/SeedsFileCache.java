package com.simplelife.Seeds.Utils.ImageProcess;

import java.io.File;
import android.content.Context;
 
public class SeedsFileCache {
     
    private File cacheDir;
     
    public SeedsFileCache(Context context){
        
    	// Find a place to cache the images
        if (android.os.Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED))
            cacheDir = new File(android.os.Environment.getExternalStorageDirectory(),"SeedsList");
        else
            cacheDir=context.getCacheDir();
        if(!cacheDir.exists())
            cacheDir.mkdirs();
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
