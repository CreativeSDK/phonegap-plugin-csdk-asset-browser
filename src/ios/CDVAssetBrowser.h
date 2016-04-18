#import <Cordova/CDVPlugin.h>


@interface CDVAssetBrowser : CDVPlugin
{
    NSString *callbackId;
}

@property (nonatomic, retain) NSString *callbackId;

- (void)getFileMetadata:(CDVInvokedUrlCommand*)command;
- (void)downloadFiles:(CDVInvokedUrlCommand*)command;

@end
