/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsSetPasswordActivity.java
 *  Seeds
 *
 *  Created by Chris Li on 13-5-20. 
 */

package com.simplelife.seeds.android;

import com.simplelife.seeds.android.utils.password.LocusPassWordView;
import com.simplelife.seeds.android.utils.password.LocusPassWordView.OnCompleteListener;
import com.simplelife.seeds.android.utils.password.StringUtil;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.Toast;

public class SeedsSetPasswordActivity extends Activity {
	private LocusPassWordView mPwdView;
	private String mPassword;
	private boolean mNeedverify = true;
	private Toast mToast;
	
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
		setContentView(R.layout.activity_seeds_login_setpassword);
		mPwdView = (LocusPassWordView) this.findViewById(R.id.mLocusPassWordView);
		mPwdView.setOnCompleteListener(new OnCompleteListener() {
			@Override
			public void onComplete(String _password) {
				mPassword = _password;
				if (mNeedverify) {
					if (mPwdView.verifyPassword(_password)) {
						showToast(R.string.seeds_setpassword_correct);
						mPwdView.clearPassword();
						mNeedverify = false;
					} else {
						showToast(R.string.seeds_setpassword_wrong);
						mPwdView.clearPassword();
						mPassword = "";
					}
				}
			}
		});

		OnClickListener mOnClickListener = new OnClickListener() {
			@Override
			public void onClick(View v) {
				switch (v.getId()) {
				case R.id.tvSave:
					if (StringUtil.isNotEmpty(mPassword)) {
						mPwdView.resetPassWord(mPassword);
						mPwdView.clearPassword();
						showToast(R.string.seeds_setpassword_success);
						startActivity(new Intent(SeedsSetPasswordActivity.this,
								SeedsPasswordActivity.class));
						finish();
					} else {
						mPwdView.clearPassword();
						showToast(R.string.seeds_setpassword_failed);
					}
					break;
				case R.id.tvReset:
					mPwdView.clearPassword();
					break;
				}
			}
		};
		Button buttonSave = (Button) this.findViewById(R.id.tvSave);
		buttonSave.setOnClickListener(mOnClickListener);
		Button tvReset = (Button) this.findViewById(R.id.tvReset);
		tvReset.setOnClickListener(mOnClickListener);
		if (mPwdView.isPasswordEmpty()) {
			this.mNeedverify = false;
			showToast(R.string.seeds_setpassword_enterpwd);
		}

	}	

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_seeds_start_display_message, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case android.R.id.home:
			// This ID represents the Home or Up button. In the case of this
			// activity, the Up button is shown. Use NavUtils to allow users
			// to navigate up one level in the application structure. For
			// more details, see the Navigation pattern on Android Design:
			//
			// http://developer.android.com/design/patterns/navigation.html#up-vs-back
			//
			NavUtils.navigateUpFromSameTask(this);
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

}