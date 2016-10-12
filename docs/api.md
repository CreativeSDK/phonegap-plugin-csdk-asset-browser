## Members

<dl>
<dt><a href="#CSDKAssetBrowser">CSDKAssetBrowser</a></dt>
<dd><p>A global object that lets you interact with the Creative SDK Asset Browser.</p>
</dd>
</dl>

## Typedefs

<dl>
<dt><a href="#successCallback">successCallback</a> : <code>function</code></dt>
<dd><p>A callback to be used upon successful upload or download of an image.</p>
</dd>
<dt><a href="#errorCallback">errorCallback</a> : <code>function</code></dt>
<dd><p>A callback to handle errors when attempting to upload or download an image.</p>
</dd>
<dt><a href="#DownloadOptions">DownloadOptions</a> : <code>Object</code></dt>
<dd><p>An object for configuring Asset Browser download behavior.</p>
</dd>
<dt><a href="#UploadOptions">UploadOptions</a> : <code>Object</code></dt>
<dd><p>An object for configuring Asset Browser upload behavior.</p>
</dd>
</dl>

<a name="CSDKAssetBrowser"></a>

## CSDKAssetBrowser
A global object that lets you interact with the Creative SDK Asset Browser.

**Kind**: global variable  

* [CSDKAssetBrowser](#CSDKAssetBrowser)
    * [.DataSourceType](#CSDKAssetBrowser.DataSourceType) : <code>enum</code>
    * [.downloadFiles(successCallback, errorCallback, options)](#CSDKAssetBrowser.downloadFiles)
    * [.uploadFile(successCallback, errorCallback, url, options)](#CSDKAssetBrowser.uploadFile)

<a name="CSDKAssetBrowser.DataSourceType"></a>

### CSDKAssetBrowser.DataSourceType : <code>enum</code>
**Kind**: static enum property of <code>[CSDKAssetBrowser](#CSDKAssetBrowser)</code>  
**Read only**: true  
**Properties**

| Name | Type | Default |
| --- | --- | --- |
| COMPOSITIONS | <code>number</code> | <code>0</code> | 
| DRAW | <code>number</code> | <code>1</code> | 
| FILES | <code>number</code> | <code>2</code> | 
| LIBRARY | <code>number</code> | <code>3</code> | 
| PHOTOS | <code>number</code> | <code>4</code> | 
| PSMIX | <code>number</code> | <code>5</code> | 
| SKETCHES | <code>number</code> | <code>6</code> | 
| LINE | <code>number</code> | <code>7</code> | 
| BRUSH | <code>number</code> | <code>8</code> | 

<a name="CSDKAssetBrowser.downloadFiles"></a>

### CSDKAssetBrowser.downloadFiles(successCallback, errorCallback, options)
Downloads a file from the Creative Cloud.

**Kind**: static method of <code>[CSDKAssetBrowser](#CSDKAssetBrowser)</code>  

| Param | Type | Description |
| --- | --- | --- |
| successCallback | <code>[successCallback](#successCallback)</code> | See type definition. |
| errorCallback | <code>[errorCallback](#errorCallback)</code> | See type definition. |
| options | <code>[DownloadOptions](#DownloadOptions)</code> | An object containing optional property/value pairs. |

<a name="CSDKAssetBrowser.uploadFile"></a>

### CSDKAssetBrowser.uploadFile(successCallback, errorCallback, url, options)
Uploads a file to the Creative Cloud.

**Kind**: static method of <code>[CSDKAssetBrowser](#CSDKAssetBrowser)</code>  

| Param | Type | Description |
| --- | --- | --- |
| successCallback | <code>[successCallback](#successCallback)</code> | See type definition. |
| errorCallback | <code>[errorCallback](#errorCallback)</code> | See type definition. |
| url | <code>string</code> | path to the asset to be uploaded. |
| options | <code>[UploadOptions](#UploadOptions)</code> | An object containing optional property/value pairs. |

<a name="successCallback"></a>

## successCallback : <code>function</code>
A callback to be used upon successful upload or download of an image.

**Kind**: global typedef  

| Param | Type | Description |
| --- | --- | --- |
| newUrl | <code>string</code> | The URL of the new downloaded image. |

<a name="errorCallback"></a>

## errorCallback : <code>function</code>
A callback to handle errors when attempting to upload or download an image.

**Kind**: global typedef  

| Param | Type | Description |
| --- | --- | --- |
| error | <code>Object</code> | Error object. |

<a name="DownloadOptions"></a>

## DownloadOptions : <code>Object</code>
An object for configuring Asset Browser download behavior.

**Kind**: global typedef  
**Properties**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| outputFile | <code>string</code> | <code>&quot;&#x27;&#x27;&quot;</code> | Path to save the file. If not specified the system default is used. |

<a name="UploadOptions"></a>

## UploadOptions : <code>Object</code>
An object for configuring Asset Browser upload behavior.

**Kind**: global typedef  
**Properties**

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| uploadName | <code>string</code> | <code>&quot;&#x27;&#x27;&quot;</code> | The name your want the file to have in the Creative Cloud. If not specified the current file name is used. |
| overwrite | <code>boolean</code> | <code>false</code> | Sets whether or not to overwrite the existing file or create a copy. |

