#import <Cordova/CDVPlugin.h>

enum CDVDataSourceType {
    DataSourceTypeComp = 0,
    DataSourceTypeDraw,
    DataSourceTypeFiles,
    DataSourceTypeLibrary,
    DataSourceTypePhotos,
    DataSourceTypePSMix,
    DataSourceTypeSketch,
    DataSourceTypeLine,
    DataSourceTypeBrush
};
typedef NSUInteger CDVDataSourceType;


@interface CDVAssetBrowser : CDVPlugin
{
    NSString *callbackId;
}

@property (nonatomic, retain) NSString *callbackId;

- (void)getFileMetadata:(CDVInvokedUrlCommand*)command;
- (void)downloadFiles:(CDVInvokedUrlCommand*)command;
- (void)uploadFile:(CDVInvokedUrlCommand*)command;

@end
