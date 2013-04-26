package com.simplelife.Seeds;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import com.simplelife.Seeds.Utils.DBProcess.SeedsDBManager;

public class SeedsStartActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		final View startView = View.inflate(this,R.layout.activity_seeds_start,null);
		//setContentView(R.layout.activity_seeds_start);
		setContentView(startView);
		
		// Fade in and fade out
		AlphaAnimation fadeShow = new AlphaAnimation(0.3f,1.0f);
		fadeShow.setDuration(2000);
		startView.startAnimation(fadeShow);
		
		// Start the DB process
		SeedsDBManager.initManager(getApplication()); 
		
		// Stay for a moments and redirect
		fadeShow.setAnimationListener(new AnimationListener()
		{
			@Override
			public void onAnimationEnd(Animation arg0) {
				redirectTo();
			}
			@Override
			public void onAnimationRepeat(Animation animation) {}
			@Override
			public void onAnimationStart(Animation animation) {}			
		});
		
	}
	
	private void redirectTo(){       
		Intent intent = new Intent(this, SeedsDateListActivity.class);
		startActivity(intent);
		finish();
	}

}