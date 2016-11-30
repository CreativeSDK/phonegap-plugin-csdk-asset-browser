/*
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
*/

package com.adobe.phonegap.csdk;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.annotation.SuppressLint;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import android.webkit.MimeTypeMap;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;

import com.adobe.creativesdk.foundation.storage.AdobeAssetException;
import com.adobe.creativesdk.foundation.storage.AdobeAssetFile;
import com.adobe.creativesdk.foundation.storage.AdobeAssetFolder;
import com.adobe.creativesdk.foundation.storage.AdobePhotoAsset;
import com.adobe.creativesdk.foundation.storage.AdobePhotoException;
import com.adobe.creativesdk.foundation.storage.AdobePhotoAssetRendition;
import com.adobe.creativesdk.foundation.storage.AdobeSelection;
import com.adobe.creativesdk.foundation.storage.AdobeSelectionAsset;
import com.adobe.creativesdk.foundation.storage.AdobeSelectionAssetFile;
import com.adobe.creativesdk.foundation.storage.AdobeSelectionLibraryAsset;
import com.adobe.creativesdk.foundation.storage.AdobeSelectionDrawAsset;
import com.adobe.creativesdk.foundation.storage.AdobeSelectionSketchAsset;
import com.adobe.creativesdk.foundation.storage.AdobeSelectionCompFile;
import com.adobe.creativesdk.foundation.storage.AdobeSelectionPSMixFile;
import com.adobe.creativesdk.foundation.storage.AdobeSelectionPhotoAsset;
import com.adobe.creativesdk.foundation.storage.AdobeUXAssetBrowser;
import com.adobe.creativesdk.foundation.storage.IAdobeGenericRequestCallback;
import com.adobe.creativesdk.foundation.internal.utils.AdobeCSDKException;


/**
* This class exposes methods in Cordova that can be called from JavaScript.
*/
public class AssetBrowser extends CordovaPlugin {
    private static final String LOG_TAG = "CreativeSDK_AssetBrowser";

    public CallbackContext callbackContext;
    private String downloadLocation;

    private IAdobeGenericRequestCallback<Boolean, AdobeAssetException> downloadCallBack = new IAdobeGenericRequestCallback<Boolean, AdobeAssetException>() {
        @Override
        public void onCancellation() {
            Log.d(LOG_TAG, "Asset Browser Cancelled");
            callbackContext.error("Asset Browser Cancelled");
        }

        @Override
        public void onError(AdobeAssetException e) {
            Log.d(LOG_TAG, "Asset Browser Error: " + e.getLocalizedMessage());
            callbackContext.error("Asset Browser Error: " + e.getLocalizedMessage());
        }

        @Override
        public void onProgress(double v) {
            Log.d(LOG_TAG, "Progress: " + v);
        }

        @Override
        public void onCompletion(Boolean aBoolean) {
            Log.d(LOG_TAG, "Yay");
            if (!downloadLocation.startsWith("file://")) {
              downloadLocation = "file://" + downloadLocation;
            }
            callbackContext.success(downloadLocation);
        }
    };

    private IAdobeGenericRequestCallback<AdobeAssetFile, AdobeCSDKException> uploadCallback = new IAdobeGenericRequestCallback<AdobeAssetFile, AdobeCSDKException>() {
        @Override
        public void onCancellation() {
            Log.d(LOG_TAG, "Upload Cancelled");
            callbackContext.error("Upload Cancelled");
        }

        @Override
        public void onError(AdobeCSDKException e) {
            Log.d(LOG_TAG, "Asset Browser Upload Error: " + e.getLocalizedMessage());
            Log.e(LOG_TAG, e.getLocalizedMessage(), e);
            callbackContext.error("Asset Browser Upload Error: " + e.getLocalizedMessage());
        }

        @Override
        public void onProgress(double v) {
            Log.d(LOG_TAG, "Upload Progress: " + v);
        }

        @Override
        public void onCompletion(AdobeAssetFile file) {
            Log.d(LOG_TAG, "Yay");
            JSONObject obj = new JSONObject();

            try {
                obj.put("created", file.getCreationDate());
                obj.put("guid", file.getGUID());
                obj.put("href", file.getHref());
                obj.put("md5", file.getMd5Hash());
                obj.put("modified", file.getModificationDate());
                obj.put("type", file.getType());
                obj.put("version", file.getCurrentVersion());
            } catch(JSONException e) {
                // never happens
            }

            callbackContext.success(obj);
        }
    };

    /**
     * Executes the request and returns PluginResult.
     *
     * @param action            The action to execute.
     * @param args              JSONArry of arguments for the plugin.
     * @param callbackContext   The callback context from which we were invoked.
     */
    @SuppressLint("NewApi")
    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;

        if (action.equals("downloadFiles")) {
            // setup data source types
            JSONArray dataSourceTypes = args.getJSONArray(0);
            int typeLength = dataSourceTypes.length();
            int[] sources = new int[typeLength];
            for (int i = 0; i < typeLength; i++) {
                sources[i] = dataSourceTypes.getInt(i);
            }

            // setup output file name
            downloadLocation = args.getString(1);

            Intent i = new Intent(cordova.getActivity(), AssetBrowserActivity.class);
            i.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
            i.putExtra("dataSources", sources);
            cordova.startActivityForResult(this, i, 0);

            PluginResult r = new PluginResult(PluginResult.Status.NO_RESULT);
            r.setKeepCallback(true);
            callbackContext.sendPluginResult(r);
        } else if (action.equals("uploadFile")) {
            String url = args.getString(0);
            URL assetUrl = !url.startsWith("content") ? createURL(url) : createURL(FileHelper.getRealPath(cordova.getActivity(), Uri.parse(url)));
            String filepath = assetUrl.getFile();
            String filename = filepath.substring( filepath.lastIndexOf('/') + 1, filepath.length() );
            String mimeType = FileHelper.getMimeType(url, cordova);
            String uploadName = args.getString(1);
            if (uploadName == null || "".equals(uploadName)) {
                uploadName = filename;
            }
            boolean overwrite = args.getBoolean(2);

            Log.d(LOG_TAG, "url: " + url);
            Log.d(LOG_TAG, "filename: " + filename);
            Log.d(LOG_TAG, "mimeType: " + mimeType);
            Log.d(LOG_TAG, "uploadName: " + uploadName);

            AdobeAssetFile.create(uploadName, AdobeAssetFolder.getRoot(), assetUrl, mimeType, uploadCallback, null);

        } else {
            return false;
        }
        return true;
    }

    /**
     *
     * Called when the asset browser exits.
     *
     * @param requestCode       The request code originally supplied to startActivityForResult(),
     *                          allowing you to identify who this result came from.
     * @param resultCode        The integer result code returned by the child activity through its setResult().
     * @param intent            An Intent, which can return result data to the caller (various data can be attached to Intent "extras").
     */
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        Log.d(LOG_TAG, "onActivityResult");
        if (resultCode == Activity.RESULT_OK) {
            Log.d(LOG_TAG, "requestCode: " + requestCode);
            switch (requestCode) {
                case 0:
                    AdobeSelection selection = getSelection(intent);

                    if(selection instanceof AdobeSelectionPhotoAsset) {
                        Log.d(LOG_TAG, "AdobeSelectionPhotoAsset");
                    }
                    else if (selection instanceof AdobeSelectionLibraryAsset) {
                        Log.d(LOG_TAG, "AdobeSelectionLibraryAsset");
                    }
                    else if (selection instanceof AdobeSelectionDrawAsset) {
                        Log.d(LOG_TAG, "AdobeSelectionDrawAsset");
                    }
                    else if (selection instanceof AdobeSelectionSketchAsset) {
                        Log.d(LOG_TAG, "AdobeSelectionSketchAsset");
                    }
                    else if (selection instanceof AdobeSelectionCompFile) {
                        Log.d(LOG_TAG, "AdobeSelectionCompFile");
                    }
                    else if (selection instanceof AdobeSelectionPSMixFile) {
                        Log.d(LOG_TAG, "AdobeSelectionPSMixFile");
                    }
                    else if (selection instanceof AdobeSelectionAssetFile) {
                        Log.d(LOG_TAG, "AdobeSelectionAsset");
                        downloadSelectionAssetFile((AdobeSelectionAssetFile) selection);
                    }
                    else if(selection instanceof AdobeSelectionAsset) {
                        Log.d(LOG_TAG, "AdobeSelectionAsset");
                    }

                    break;
            }
        } else if (resultCode == Activity.RESULT_CANCELED) {
            //this.callbackContext.error("Asset Browser Canceled");
            Log.d(LOG_TAG, "Asset Browser Canceled");
        }
    }

    private void downloadSelectionAssetFile(AdobeSelectionAssetFile selectionAssetFile) {
        AdobeAssetFile asset = selectionAssetFile.getSelectedItem();

        // if no download location specified use default
        if ("".equals(downloadLocation)) {
            downloadLocation = (new File(cordova.getActivity().getFilesDir(), asset.getName())).getAbsolutePath();
        }

        Log.d(LOG_TAG, downloadLocation);

        asset.downloadAssetFile(createURI(downloadLocation), downloadCallBack);
    }

    private URI createURI(String url) {
        URI external = null;
        try {
            external = url.startsWith("file://") ? new URI(url) : new URI("file://" + url);
        } catch (URISyntaxException e) {
            Log.e(LOG_TAG, e.getLocalizedMessage(), e);
        }
        return external;
    }


    private URL createURL(String url) {
        URL external = null;
        try {
            external = url.startsWith("file://") ? new URL(url) : new URL("file://" + url);
        } catch (MalformedURLException e) {
            Log.e(LOG_TAG, e.getLocalizedMessage(), e);
        }
        return external;
    }

    private AdobeSelection getSelection(Intent data) {
        AdobeUXAssetBrowser.ResultProvider assetBrowserResult = new AdobeUXAssetBrowser.ResultProvider(data);
        ArrayList listOfSelectedAssetFiles = assetBrowserResult.getSelectionAssetArray();
        Log.d(LOG_TAG, "list = " + listOfSelectedAssetFiles.size());
        return (AdobeSelection) listOfSelectedAssetFiles.get(0);
    }

    private static String getMimeType(String fileUrl) {
        String extension = MimeTypeMap.getFileExtensionFromUrl(fileUrl);
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
    }
}
