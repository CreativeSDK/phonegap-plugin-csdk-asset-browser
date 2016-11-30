/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
*/

/* global cordova:false */
/* globals window */

var exec = cordova.require('cordova/exec'),
    utils = cordova.require('cordova/utils');

/**
    @description A global object that lets you interact with the Creative SDK Asset Browser.
    @global
*/
var CSDKAssetBrowser = {
    /** @private */
    getFileMetadata: function(successCallback, failureCallback) {
        exec(successCallback, failureCallback, 'CSDKAssetBrowser', 'getFileMetadata', []);
    },

    /**
     * @description Downloads a file from the Creative Cloud.
     * @function downloadFiles
     * @memberof CSDKAssetBrowser
     * @param {!successCallback} successCallback - See type definition.
     * @param {!errorCallback} errorCallback - See type definition.
     * @param {?DownloadOptions} options An object containing optional property/value pairs.
     */
    downloadFiles: function(successCallback, failureCallback, options) {
        options = options || {};
        options.dataSource = [CSDKAssetBrowser.DataSourceType.FILES];
        var dataSourceTypes = CSDKAssetBrowser.getDataSources(options.dataSource);
        var outputFile = options.outputFile || '';
        exec(successCallback, failureCallback, 'CSDKAssetBrowser', 'downloadFiles', [ dataSourceTypes, outputFile ]);
    },

    /**
     * @description Uploads a file to the Creative Cloud.
     * @function uploadFile
     * @memberof CSDKAssetBrowser
     * @param {!successCallback} successCallback - See type definition.
     * @param {!errorCallback} errorCallback - See type definition.
     * @param {!string} url path to the asset to be uploaded.
     * @param {?UploadOptions} options An object containing optional property/value pairs.
     */
    uploadFile: function(successCallback, failureCallback, url, options) {
        options = options || {};
        var uploadName = options.uploadName || '';
        var overwrite = !!options.overwrite;
        exec(successCallback, failureCallback, 'CSDKAssetBrowser', 'uploadFile', [ url, uploadName, overwrite ]);
    },

    /** @private */
    getDataSources: function(types) {
        var validTypes = [];
        if (types) {
            for(var i=0; i<types.length; i++) {
                if (types[i] >= 0 && types[i] <= 8) {
                    validTypes.push(types[i]);
                }
            }
        }
        return validTypes;
    },

    /**
     * @readonly
     * @enum {number}
     */
    DataSourceType:{
        COMPOSITIONS: 0,
        DRAW: 1,
        FILES: 2,
        LIBRARY: 3,
        PHOTOS: 4,
        PSMIX: 5,
        SKETCHES: 6,
        LINE: 7,
        BRUSH: 8
    }
};

/**
 * @description A callback to be used upon successful upload or download of an image.
 *
 * @callback successCallback
 * @param {string} newUrl - The URL of the new downloaded image.
 */

/**
 * @description A callback to handle errors when attempting to upload or download an image.
 *
 * @callback errorCallback
 * @param {Object} error - Error object.
 */

/**
 * @typedef {Object} DownloadOptions - An object for configuring Asset Browser download behavior.
 * @property {string} [outputFile=''] - Path to save the file. If not specified the system default is used.
 */

/**
 * @typedef {Object} UploadOptions - An object for configuring Asset Browser upload behavior.
 * @property {string} [uploadName=''] - The name your want the file to have in the Creative Cloud. If not specified the current file name is used.
 * @property {boolean} [overwrite=false] - Sets whether or not to overwrite the existing file or create a copy.
 */

module.exports = CSDKAssetBrowser;
