package com.simplelife.seeds.android.Utils.ImageProcess;

import com.simplelife.seeds.android.R;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;

public class SeedsImageLoadingDialog extends Dialog {

	public SeedsImageLoadingDialog(Context context) {
		super(context, R.style.SeedsImageloadingDialogStyle);
		//setOwnerActivity((Activity) context);
	}

	private SeedsImageLoadingDialog(Context context, int theme) {
		super(context, theme);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_seeds_details_dialog);
	}

}
