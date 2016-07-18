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

#import <AdobeCreativeSDKAssetUX/AdobeCreativeSDKAssetUX.h>
#import <Cordova/CDV.h>
#import "CDVAssetBrowser.h"

@implementation CDVAssetBrowser

@synthesize callbackId;

- (void) getFileMetadata:(CDVInvokedUrlCommand*)command
{
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
}

- (void) downloadFiles:(CDVInvokedUrlCommand*)command
{
    __weak CDVPlugin* weakSelf = self;

    NSDictionary* options = [command.arguments firstObject];
    CGSize renditionSize = FULL_SIZE_RENDITION;
    AdobeAssetFileRenditionType renditionType = AdobeAssetFileRenditionTypeJPEG;

    if (options != nil && [options isKindOfClass:[NSDictionary class]]) {
        NSNumber* rWidth = [options objectForKey:@"width"];
        NSNumber* rHeight = [options objectForKey:@"height"];
        NSNumber* rType = [options objectForKey:@"type"];

        if (rType != nil) {
            renditionType = [rType integerValue];
        }

        if (rWidth != nil && rHeight != nil) {
            renditionSize = CGSizeMake([rWidth floatValue], [rHeight floatValue]);
        }
    }

    void(^downloadFailure)(NSString*, NSString*)= ^(NSString* href, NSString* errorMessage) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"%@ (%@)", errorMessage, href]];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };

    void(^downloadInit)(NSString*, AdobeAssetFile*)= ^(NSString* href, AdobeAssetFile* assetFile) {
        NSDictionary* dict = @{
            @"href" : href,
            @"metadata" : [assetFile propertiesAsDictionary]
        };
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                           messageAsDictionary:dict];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };

    void(^downloadProgress)(NSString*, double)= ^(NSString* href, double fractionCompleted) {
        NSDictionary* dict = @{
            @"href" : href,
            @"fractionCompleted" : [NSNumber numberWithDouble:fractionCompleted]
        };

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsDictionary:dict];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };

    void(^downloadCompleted)(NSString*, NSData*, BOOL)= ^(NSString* href, NSData* data, BOOL fromCache) {
        // Save the file to NSTemporaryDirectory() location, with uuid filename
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
        NSString* filePath = [NSString stringWithFormat:@"%@/%@", [NSTemporaryDirectory() stringByStandardizingPath], uuidString];
        CFRelease(uuidString);
        CFRelease(uuidRef);

        [data writeToFile:filePath atomically:YES];
        NSURL* fileURL = [NSURL fileURLWithPath:filePath];

        NSDictionary* dict = @{
            @"href" : href,
            @"result" : [fileURL absoluteString],
            @"cached" : [NSNumber numberWithBool:fromCache]
        };

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsDictionary:dict];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    };

    [[AdobeUXAssetBrowser sharedBrowser]
        popupFileBrowserWithParent:self.viewController withExclusionList:nil
        onSuccess: ^(NSArray* itemSelections) {
            AdobeSelectionAsset* itemSelection = [itemSelections lastObject];
            AdobeAsset* item = (AdobeAsset*)itemSelection.selectedItem;

            if (IsAdobeAssetFile(item)) {
                AdobeAssetFile* file = (AdobeAssetFile*)item;
                downloadInit(file.href, file);

                [file getRenditionWithType: renditionType
                               withSize: renditionSize
                           withPriority: NSOperationQueuePriorityNormal
                        onProgress: ^(double fractionCompleted) {
                            downloadProgress(file.href, fractionCompleted);
                        }
                        onCompletion: ^(NSData* data, BOOL fromCache) {
                            downloadCompleted(file.href, data, fromCache);
                        }
                        onCancellation:^ {
                            downloadFailure(file.href, @"Cancelled");
                        }
                        onError:^(NSError* error) {
                            downloadFailure(file.href, [error localizedDescription]);
                        }
                ];
            }
        }
        onError:^(NSError* error) {
            downloadFailure(nil, [error localizedDescription]);
        }
    ];
}

@end
