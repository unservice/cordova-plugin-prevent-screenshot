#import <Cordova/CDV.h>
#import "ScreenRecordingDetector.h"


@interface ScreenshotBlocker : CDVPlugin
@property (strong, nonatomic) CALayer *originalLayer;
@property (strong, nonatomic) UITextField *field;

- (void)enable:(CDVInvokedUrlCommand*)command;
- (void)disable:(CDVInvokedUrlCommand*)command;
- (void)listen:(CDVInvokedUrlCommand*)command;

@end
