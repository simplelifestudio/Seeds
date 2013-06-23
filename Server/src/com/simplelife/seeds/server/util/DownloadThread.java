/**
 * DownloadThread.java
 * 
 * History:
 *     2013-6-22: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.util;

import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.message.BasicNameValuePair;

/**
 * 
 */
public class DownloadThread
{
    private static class State {
        public String mFilename;
        public FileOutputStream mStream;
        public String mMimeType;
        public boolean mCountRetry = false;
        public int mRetryAfter = 0;
        public int mRedirectCount = 0;
        public String mNewUri;
        public boolean mGotData = false;
        public String mRequestUri;
        public String mRequestRef;

        /*
        public State(DownloadInfo info) {
            mMimeType = sanitizeMimeType(info.mMimeType);
            mRequestUri = info.mUri;
            mFilename = info.mFileName;
            
            String tStringRef = "ref=";
            
            if(mRequestUri.indexOf(tStringRef)!=-1)
            {
                mRequestRef = mRequestUri.substring(mRequestUri.indexOf(tStringRef) + tStringRef.length());
            }
        }
        */
        }
    
    private static final int BUFFER_SIZE = 4096;
    private static final String SEEDS_SERVER_DOWNLOADPHP = "http://www.maxp2p.com/load.php";
    
    
    /*
    public void run() {
        //Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND);

        HttpClient client = null;
        try {
            client = HttpClient.newInstance(userAgent(), mContext);

            boolean finished = false;
            while (!finished) {
                HttpPost request = new HttpPost(SEEDS_SERVER_DOWNLOADPHP);
                List<NameValuePair> params = new ArrayList<NameValuePair>();
                params.add(new BasicNameValuePair("ref", state.mRequestRef));
                request.setEntity(new UrlEncodedFormEntity(params, "utf-8"));

                try {
                    executeDownload(state, client, request);
                    finished = true;
                } catch (RetryDownload exc) {
                    // fall through
                } finally {
                    request.abort();
                    request = null;
                }
            }

            if (Constants.LOGV) {
                Log.v(Constants.TAG, "download completed for " + mInfo.mUri);
            }
            finalizeDestinationFile(state);
            finalStatus = Downloads.STATUS_SUCCESS;
        } catch (StopRequest error) {
            // remove the cause before printing, in case it contains PII
            Log.w(Constants.TAG, "Aborting request for download " + mInfo.mId + ": " + error.getMessage());
            finalStatus = error.mFinalStatus;
            // fall through to finally block
        } catch (Throwable ex) { // sometimes the socket code throws unchecked
            // exceptions
            Log.w(Constants.TAG, "Exception for id " + mInfo.mId + ": " + ex);
            finalStatus = Downloads.STATUS_UNKNOWN_ERROR;
            // falls through to the code that reports an error
        } finally {
            if (wakeLock != null) {
                wakeLock.release();
                wakeLock = null;
            }
            if (client != null) {
                client.close();
                client = null;
            }
            cleanupDestination(state, finalStatus);
            notifyDownloadCompleted(finalStatus, state.mCountRetry, state.mRetryAfter, state.mGotData, state.mFilename,
                    state.mNewUri, state.mMimeType);
            mInfo.mHasActiveThread = false;
        }
    }
    */
}
