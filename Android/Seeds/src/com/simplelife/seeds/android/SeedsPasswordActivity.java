/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsPasswordActivity.java
 *  Seeds
 *
 *  Created by Chris Li on 13-5-20. 
 */

package com.simplelife.seeds.android;

import com.simplelife.seeds.android.utils.password.LocusPassWordView;
import com.simplelife.seeds.android.utils.password.LocusPassWordView.OnCompleteListener;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.TextView;
import android.widget.Toast;

public class SeedsPasswordActivity extends Activity {
	
	private LocusPassWordView mPwdView;
	private Toast mToast;	
	public final static String EXTRA_MESSAGE = "com.simplelife.seeds.android.MESSAGE";

	private void showToast(int _messageId) {
		if (null == mToast) {
			mToast = Toast.makeText(this, _messageId, Toast.LENGTH_SHORT);
			// toast.setGravity(Gravity.CENTER, 0, 0);
		} else {
			mToast.setText(_messageId);
		}
		mToast.show();
	}
	
	@Override
    protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_seeds_login_password);
		mPwdView = (LocusPassWordView) this.findViewById(R.id.mLocusPassWordView);
		mPwdView.setOnCompleteListener(new OnCompleteListener() {
			@Override
			public void onComplete(String mPassword) {
				// If the password is correct, direct to the datelist activity
				if (mPwdView.verifyPassword(mPassword)) {
					showToast(R.string.seeds_password_logincorrect);
					Intent intent = new Intent(SeedsPasswordActivity.this, SeedsDateListActivity.class);
					startActivity(intent);
					finish();
				} else {
					showToast(R.string.seeds_password_loginfailed);
					mPwdView.clearPassword();
				}
			}
		});        
    }
	
	@Override
	protected void onStart() {
		super.onStart();
		View noSetPassword = (View) this.findViewById(R.id.tvNoSetPassword);
		TextView toastTv = (TextView) findViewById(R.id.login_toast);
		if (mPwdView.isPasswordEmpty()) {
			mPwdView.setVisibility(View.GONE);
			noSetPassword.setVisibility(View.VISIBLE);
			toastTv.setText(R.string.seeds_password_drawstatus);
			noSetPassword.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					Intent intent = new Intent(SeedsPasswordActivity.this,
							SeedsSetPasswordActivity.class);
					startActivity(intent);
					finish();
				}

			});
		} else {
			toastTv.setText(R.string.seeds_password_inputpwd);
			mPwdView.setVisibility(View.VISIBLE);
			noSetPassword.setVisibility(View.GONE);
		}
	}

	@Override
	protected void onStop() {
		super.onStop();
	}

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_seeds_start_verify_menu, menu);
        return true;
    }
    
    
}
