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

#import <MobileCoreServices/MobileCoreServices.h>
#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h>
#import <AdobeCreativeSDKAssetModel/AdobeCreativeSDKAssetModel.h>
#import <AdobeCreativeSDKAssetUX/AdobeCreativeSDKAssetUX.h>
#import <Cordova/CDV.h>
#import "CDVAssetBrowser.h"

#define ADB_PHOTO_PREFIX @"adb_photo_"

@implementation CDVAssetBrowser

@synthesize callbackId;

- (void) getFileMetadata:(CDVInvokedUrlCommand*)command
{
    /*
    __weak CDVPlugin* weakSelf = self;

    void(^getSuccess)(AdobeSelectionAssetArray*)= ^(AdobeSelectionAssetArray* items) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsArray:[items arrayWithItemsAsDictionaries]];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };

    void(^getFailure)(NSString*)= ^(NSString* errorMessage) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };

    [[AdobeUXAssetBrowser sharedBrowser]
         popupFileBrowser:^(AdobeSelectionAssetArray* itemSelections) {
             NSMutableArray* m = [NSMutableArray arrayWithCapacity:[itemSelections count]];
             for(id item in itemSelections) {
                 AdobeAsset* it = ((AdobeSelectionAsset*)item).selectedItem;
                 [m addObject:it];
             }
             getSuccess(m);
         }
         onError:^(NSError *error) {
             getFailure([error localizedDescription]);
         }
    ];
     */
}

- (void) downloadFiles:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;

    NSArray *dataSources = [self createDataSourceArray:[command.arguments objectAtIndex:0]];

    // Create a datasource filter object that excludes the Libraries and Photos datasources. For
    // the purposes of this demo, we'll only deal with non-complex datasources like the Files
    // datasource.
    AdobeAssetDataSourceFilter *dataSourceFilter = nil;
    if ([dataSources count] > 0) {
        NSLog((@"include"));
        dataSourceFilter = [[AdobeAssetDataSourceFilter alloc] initWithDataSources:dataSources
                                                                        filterType:AdobeAssetDataSourceFilterInclusive];
    } else {
        NSLog((@"exclude"));
        dataSourceFilter = [[AdobeAssetDataSourceFilter alloc] initWithDataSources:dataSources
                                                                        filterType:AdobeAssetDataSourceFilterExclusive];
    }

    // Create an Asset Browser configuration object and set the datasource filter object.
    AdobeUXAssetBrowserConfiguration *assetBrowserConfiguration = [AdobeUXAssetBrowserConfiguration new];
    assetBrowserConfiguration.dataSourceFilter = dataSourceFilter;

    // Create an instance of the Asset Browser view controller
    AdobeUXAssetBrowserViewController *assetBrowserViewController =
    [AdobeUXAssetBrowserViewController assetBrowserViewControllerWithConfiguration:assetBrowserConfiguration
                                                                          delegate:self];

    // Present the Asset Browser view controller
    [self.viewController presentViewController:assetBrowserViewController animated:YES completion:nil];
}

- (void) uploadFile:(CDVInvokedUrlCommand *)command
{
    self.callbackId = command.callbackId;

    NSURL *assetURL = [NSURL URLWithString:[command.arguments objectAtIndex:0]];
    NSString *filename = [assetURL lastPathComponent];
    NSString *mimeType = [self fileMIMEType:filename];
    NSString *uploadName = [command.arguments objectAtIndex:1];
    if ([uploadName length] != 0) {
        filename = uploadName;
    }
    BOOL overwrite = [[command argumentAtIndex:2 withDefault:@(YES)] boolValue];
    AdobeAssetFileCollisionPolicy policy = overwrite ? AdobeAssetFileCollisionPolicyOverwriteWithNewVersion : AdobeAssetFileCollisionPolicyAppendUniqueNumber;

    NSLog(@"url: %@", assetURL);
    NSLog(@"filename: %@", filename);
    NSLog(@"mimeType: %@", mimeType);
    NSLog(@"uploadName: %@", uploadName);
    NSLog(@"overwrite: %hhd", overwrite);

    AdobeAssetFolder *selectedFolder = [AdobeAssetFolder root];

    /**
     * TODO:
     *   folder to upload to
     */
    [AdobeAssetFile create:filename
                    folder:selectedFolder
                  dataPath:assetURL
               contentType:mimeType
           collisionPolicy: policy
             progressBlock:^(double fractionCompleted) {
                    NSLog(@"Progress: %f", fractionCompleted);
         }
              successBlock:^(AdobeAssetFile *file) {
                    NSString *description = [file description];
                    NSLog(@"Upload success: %@", description);

                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:7];
                    [dict setObject:[NSDateFormatter localizedStringFromDate:file.creationDate
                                                                 dateStyle:NSDateFormatterShortStyle
                                                                 timeStyle:NSDateFormatterFullStyle] forKey:@"created"];
                    [dict setObject:file.GUID forKey:@"guid"];
                    [dict setObject:file.href forKey:@"href"];
                    [dict setObject:file.md5Hash forKey:@"md5"];
                    [dict setObject:[NSDateFormatter localizedStringFromDate:file.modificationDate
                                                                 dateStyle:NSDateFormatterShortStyle
                                                                 timeStyle:NSDateFormatterFullStyle] forKey:@"modified"];
                    [dict setObject:file.type forKey:@"type"];
                    [dict setObject:[NSNumber numberWithInteger:file.currentVersion] forKey:@"version"];

                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
         }
         cancellationBlock:^{
                    NSLog(@"The rendition request was cancelled.");

                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"Cancelled"]];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
         }
                errorBlock:^(NSError *error){
                    NSLog(@"The rendition request was cancelled.");

                    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"%@", error]];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
        }];
}

- (void)assetBrowserDidSelectAssets:(AdobeSelectionAssetArray *)itemSelections
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];

    if (itemSelections.count == 0)
    {
        // Nothing selected so there is nothing to do.
        return;
    }

    NSLog(@"yay, something selected");

    // Get the first asset-selection object.
    AdobeSelectionAsset *assetSelection = itemSelections.firstObject;

    // Grab the generic AdobeAsset object from the selection object.
    AdobeAsset *selectedAsset = assetSelection.selectedItem;


    // Make sure it's an AdobeAssetFile object.
    if (!IsAdobeAssetFile(selectedAsset))
    {
        return;
    }

    AdobeAssetFile *selectedAssetFile = (AdobeAssetFile *)selectedAsset;

    // Download a thumbnail for common image formats
    if ([selectedAssetFile.type isEqualToString:kAdobeMimeTypeJPEG] ||
        [selectedAssetFile.type isEqualToString:kAdobeMimeTypePNG] ||
        [selectedAssetFile.type isEqualToString:kAdobeMimeTypeGIF] ||
        [selectedAssetFile.type isEqualToString:kAdobeMimeTypeBMP])
    {
        [selectedAssetFile downloadData:NSOperationQueuePriorityNormal
                          progressBlock:^(double fractionCompleted) {
                                           NSLog(@"Progress: %f", fractionCompleted);
                                       }
                           successBlock:^(NSData *data, BOOL fromCache) {
             NSLog(@"Successfully downloaded a thumbnail.");

             CDVPluginResult *pluginResult = nil;
             NSString* filePath = [self tempFilePath:@"png"];
             NSError* err = nil;

             NSLog(@"file path %@", filePath);

             // save file
             if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
             } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[[NSURL fileURLWithPath:filePath] absoluteString]];
             }

             [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
         } cancellationBlock:^{
             NSLog(@"The rendition request was cancelled.");

             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"Cancelled"]];
             [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
         } errorBlock:^(NSError *error) {
             NSLog(@"There was a problem downloading the file rendition: %@", error);

             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"%@", error]];
             [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
         } ];
    }
    /*
    else
    {
        NSString *message = @"The selected file type isn't a common image format so no "
        "thumbnail will be fetched from the server.\n\nTry selecting a JPEG, PNG or BMP file.";

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Demo Project"
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:NULL];

        [alertController addAction:okAction];

        [self presentViewController:alertController animated:YES completion:nil];
    }
     */
}

- (void)assetBrowserDidEncounterError:(NSError *)error
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];

    NSLog(@"An error occurred: %@", error);

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];

}

- (void)assetBrowserDidClose
{
    NSLog(@"User closed the Asset Browser view controller.");

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"User clicked closed"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

- (NSString*)fileMIMEType:(NSString*)file
{
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)CFBridgingRetain([file pathExtension]), NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    return (NSString *)CFBridgingRelease(MIMEType);
}

- (NSString*)tempFilePath:(NSString*)extension
{
    NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
    NSFileManager* fileMgr = [[NSFileManager alloc] init]; // recommended by Apple (vs [NSFileManager defaultManager]) to be threadsafe
    NSString* filePath;

    // generate unique file name
    int i = 1;
    do {
        filePath = [NSString stringWithFormat:@"%@/%@%03d.%@", docsPath, ADB_PHOTO_PREFIX, i++, extension];
    } while ([fileMgr fileExistsAtPath:filePath]);

    return filePath;
}

- (NSArray*) createDataSourceArray:(NSArray*)sourceOptions
{
    NSMutableArray *sources = [NSMutableArray array];

    for (NSNumber *tempNumber in sourceOptions) {
        int toolId = [tempNumber integerValue];
        NSLog(@"Single element: %d", toolId);
        switch(toolId){
            case DataSourceTypeDraw:
                [sources addObject: AdobeAssetDataSourceDraw];
                break;
            case DataSourceTypeLine:
                [sources addObject: AdobeAssetDataSourceLine];
                break;
            case DataSourceTypePhotos:
                [sources addObject: AdobeAssetDataSourcePhotos];
                break;
            case DataSourceTypePSMix:
                [sources addObject: AdobeAssetDataSourceMix];
                break;
            case DataSourceTypeFiles:
                [sources addObject: AdobeAssetDataSourceFiles];
                break;
            case DataSourceTypeComp:
                [sources addObject: AdobeAssetDataSourceCompCC];
                break;
            case DataSourceTypeSketch:
                [sources addObject: AdobeAssetDataSourceSketch];
                break;
            case DataSourceTypeBrush:
                [sources addObject: AdobeAssetDataSourceBrushCC];
                break;
            default:
                // Ignore any source not from the above
                break;
        }
    }

    return [sources copy];
}

@end
