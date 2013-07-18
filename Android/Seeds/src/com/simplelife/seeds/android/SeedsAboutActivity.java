/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsAboutActivity.java
 *  Seeds
 *
 *  Created by Chris Li on 13-5-20. 
 */

package com.simplelife.seeds.android;

import android.app.AlertDialog;
import android.content.Context;
import android.view.View;

public class SeedsAboutActivity {
	
	public static class SeedsAboutDialog extends AlertDialog {  
	    public SeedsAboutDialog(Context context) {  
	        super(context);  
	        final View view = getLayoutInflater().inflate(R.layout.activity_seeds_about,  
	                null);    
	        //setIcon(R.drawable.icon_about);  
	        
	        setTitle(SeedsDefinitions.RELEASE_NAME + SeedsDefinitions.RELEASE_VERSION);  
	        setView(view);  
	    }  
	}  

}
