/*
 *  Copyright (C) 2013 SimpleLife Studio All rights reserved
 *  
 *  SeedsSetPasswordActivity.java
 *  Seeds
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
import android.widget.TextView;
import android.widget.Toast;

public class SeedsSetPasswordActivity extends Activity {
	private LocusPassWordView mPwdView;
	private String mPassword;
	private String mFirstPassword;
	private boolean mNeedVerify = true;
	private boolean mFirstTryFlag = false;
	private boolean mSecondTryFlag = false;
	private boolean mIsFirstCreation = false;
	private Toast mToast;
	private TextView mTitle;
	private TextView mCancel;
	private TextView mSave;
	
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
		mCancel  = (TextView) this.findViewById(R.id.setpwd_reset);
		mSave    = (TextView) this.findViewById(R.id.setpwd_save);
		mTitle   = (TextView) this.findViewById(R.id.setpwd_title);
		
		// Confirm if there is already a password
		if (!mPwdView.isPasswordEmpty())
		{
			mCancel.setVisibility(View.GONE);
			mSave.setVisibility(View.GONE);
			mTitle.setText(R.string.seeds_setpassword_entercurrnt);
		}
		else
		{
			this.mNeedVerify = false;
			this.mIsFirstCreation = true;
			mTitle.setText(R.string.seeds_password_drawstatus);
			//showToast(R.string.seeds_setpassword_enterpwd);		
		}
		mSave.setTextColor(getResources().getColor(R.color.actionbar_title_sleep));
		mCancel.setOnClickListener(mOnClickListener);

		mPwdView.setOnCompleteListener(new OnCompleteListener() {
			@Override
			public void onComplete(String _password) {
				mPassword = _password;
				if (mNeedVerify) {
					if (mPwdView.verifyPassword(_password)) {
						mTitle.setText(R.string.seeds_password_drawstatus);
						showToast(R.string.seeds_setpassword_correct);
						mPwdView.clearPassword();
						mCancel.setVisibility(View.VISIBLE);
						mSave.setVisibility(View.VISIBLE);
						mNeedVerify = false;
					} else {
						showToast(R.string.seeds_setpassword_wrong);
						mPwdView.clearPassword();
						mPassword = "";
					}
				}
				else{
					if (!mFirstTryFlag){
						mTitle.setText(R.string.seeds_password_drawsrecorded);
						mSave.setTextColor(getResources().getColor(R.color.actionbar_title));
						mSave.setOnClickListener(mOnClickListener);
						mCancel.setText(R.string.seeds_password_redraw);
						mFirstTryFlag = true;
					}
					else if (!mSecondTryFlag){
						if (verifyLocalPassword(_password)){
							mTitle.setText(R.string.seeds_password_confirmdrawstatusdone);
							mSave.setTextColor(getResources().getColor(R.color.actionbar_title));
							mSave.setOnClickListener(mOnClickListener);
							mCancel.setText(R.string.seeds_password_redraw);
							mSecondTryFlag = true;
						} else {
							showToast(R.string.seeds_setpassword_wrong);
							mPwdView.clearPassword();
							mPassword = "";
						}

					}					
				}
					

			}
		});

	}
	
	private OnClickListener mOnClickListener = new OnClickListener() {
		@Override
		public void onClick(View v) {
			switch (v.getId()) {
			case R.id.setpwd_save:
				if ((mFirstTryFlag)&&(!mSecondTryFlag))
				{
					if (StringUtil.isNotEmpty(mPassword)) {
						//mPwdView.resetPassWord(mPassword);
						mPwdView.clearPassword();
						mFirstPassword = mPassword;
						mTitle.setText(R.string.seeds_password_confirmdrawstatus);
						mSave.setText(R.string.seeds_password_save);
						mSave.setTextColor(getResources().getColor(R.color.actionbar_title_sleep));
						mSave.setClickable(false);
						mCancel.setText(R.string.seeds_password_cancel);
					} else {
						mPwdView.clearPassword();
						showToast(R.string.seeds_setpassword_failed);
					}
				}
				else if(mSecondTryFlag){
					if (StringUtil.isNotEmpty(mPassword)) {
						mPwdView.resetPassWord(mPassword);
						mPwdView.clearPassword();
						if(mIsFirstCreation)
							showToast(R.string.seeds_setpassword_firstsuccess);
						else
							showToast(R.string.seeds_setpassword_success);
						startActivity(new Intent(SeedsSetPasswordActivity.this,
								SeedsPasswordActivity.class));
						finish();
					} else {
						mPwdView.clearPassword();
						showToast(R.string.seeds_setpassword_failed);
					}					
				}

				break;
			case R.id.setpwd_reset:
				if(mCancel.getText().equals(getString(R.string.seeds_password_cancel)))
				{
					finish();
				}
				else{
					if((mFirstTryFlag)&&(!mSecondTryFlag))
					{
						mTitle.setText(R.string.seeds_password_drawstatus);
						mCancel.setText(R.string.seeds_password_cancel);
						mSave.setTextColor(getResources().getColor(R.color.actionbar_title_sleep));
						mSave.setClickable(false);
						mPwdView.clearPassword();
						mFirstTryFlag = false;
					}else if(mSecondTryFlag){
						mTitle.setText(R.string.seeds_password_confirmdrawstatus);
						mCancel.setText(R.string.seeds_password_cancel);
						mSave.setTextColor(getResources().getColor(R.color.actionbar_title_sleep));
						mSave.setClickable(false);
						mPwdView.clearPassword();	
						mSecondTryFlag = false;
					}					
				}
				break;
			}
		}
	};
	
	public boolean verifyLocalPassword(String _password) {
		boolean verify = false;
		if (StringUtil.isNotEmpty(_password)) {
			if (_password.equals(mFirstPassword)) 
			{
				verify = true;
			}
		}
		return verify;
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