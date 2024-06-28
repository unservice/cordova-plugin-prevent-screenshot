#import "ScreenshotBlocker.h"
@interface ScreenshotBlocker() {
    CDVInvokedUrlCommand * _eventCommand;
}
@end

@implementation ScreenshotBlocker
UIImageView* cover;
- (void)pluginInitialize {
    NSLog(@"Starting ScreenshotBlocker plugin");

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(appDidBecomeActive)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(applicationWillResignActive)
                                                name:UIApplicationWillResignActiveNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tookScreeshot)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(goingBackground)
                                                name:UIApplicationWillResignActiveNotification
                                              object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenCaptureStatusChanged)
                                                 name:kScreenRecordingDetectorRecordingStatusChangedNotification
                                               object:nil];

    /*
     userDidTakeScreenshotNotification
     */
}

- (void)enable:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* pluginResult = nil;
    NSLog(@"Abilita observers");
    
    CDVAppDelegate *appDelegate = (CDVAppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *mainWindow = appDelegate.window;

    CDVAppDelegate *appDelegate = (CDVAppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *mainWindow = appDelegate.window;

    self.field = [[UITextField alloc] init];
    self.field.secureTextEntry = YES;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.field.frame.size.width, self.field.frame.size.height)];
    [view addSubview:self.field];
    self.field.leftView = view;
    self.field.leftViewMode = UITextFieldViewModeAlways;
    
    if (self.originalLayer == nil) {
        self.originalLayer = mainWindow.layer;
    }
    [mainWindow.layer.superlayer addSublayer:self.field.layer];
    [[self.field.layer.sublayers lastObject] addSublayer:mainWindow.layer];
   
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    
    /*
     [[NSNotificationCenter defaultCenter]addObserver:self
     selector:@selector(appDidBecomeActive)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self
     selector:@selector(applicationWillResignActive)
     name:UIApplicationWillResignActiveNotification
     object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(screenCaptureStatusChanged)
     name:kScreenRecordingDetectorRecordingStatusChangedNotification
     object:nil];
     pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
     */
}

- (void)disable:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* pluginResult = nil;
    NSLog(@"Abilita observers");

    if (self.field == nil) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    } else {
        [self.field.layer.superlayer addSublayer:self.originalLayer];
        [self.field.layer removeFromSuperlayer];
        self.field = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
}

- (void)listen:(CDVInvokedUrlCommand*)command {
    _eventCommand = command;
}


-(void) goingBackground {
    NSLog(@"Me la scattion in bck");
    if(_eventCommand!=nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"background"];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_eventCommand.callbackId];
    }
}
-(void)tookScreeshot {
    NSLog(@"fatta la foto?");
    if(_eventCommand!=nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"tookScreenshot"];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_eventCommand.callbackId];
    }

}

-(void)setupView {
    BOOL isCaptured = [[UIScreen mainScreen] isCaptured];
    NSLog(@"Is screen captured? %@", (isCaptured?@"SI":@"NO"));

    if ([[ScreenRecordingDetector sharedInstance] isRecording]) {
        [self webView].alpha = 0.f;
        NSLog(@"Registro o prendo screenshots");
    } else {
        [self webView].alpha = 1.f;
        NSLog(@"Non registro");

    }
}

-(void)appDidBecomeActive {
    [ScreenRecordingDetector triggerDetectorTimer];
    if(cover!=nil) {
        [cover removeFromSuperview];
        cover = nil;
    }
}
-(void)applicationWillResignActive {
    [ScreenRecordingDetector stopDetectorTimer];
    if(cover == nil) {
        cover = [[UIImageView alloc] initWithFrame:[self.webView frame]];
        cover.backgroundColor = [UIColor blackColor];
        [self.webView addSubview:cover];
    }
}
-(void)screenCaptureStatusChanged {
    [self setupView];
}


@end
