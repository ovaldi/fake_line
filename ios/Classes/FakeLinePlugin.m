#import "FakeLinePlugin.h"

@implementation FakeLinePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"v7lin.github.io/fake_line"
                                     binaryMessenger:[registrar messenger]];
    FakeLinePlugin* instance = [[FakeLinePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

static NSString * const METHOD_ISLINEINSTALLED = @"isLineInstalled";
static NSString * const METHOD_SHARETEXT = @"shareText";
static NSString * const METHOD_SHAREIMAGE = @"shareImage";

static NSString * const ARGUMENT_KEY_TEXT = @"text";
static NSString * const ARGUMENT_KEY_IMAGEURI = @"imageUri";

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([METHOD_ISLINEINSTALLED isEqualToString:call.method]) {
        result([NSNumber numberWithBool: [self isAppInstalled:@"line"]]);
    } else if ([METHOD_SHARETEXT isEqualToString:call.method]) {
        [self shareText:call result:result];
    } else if ([METHOD_SHAREIMAGE isEqualToString:call.method]) {
        [self shareImage:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void) shareText:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString * text = call.arguments[ARGUMENT_KEY_TEXT];
    text = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)text, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    NSURL * lineURL = [NSURL URLWithString:[NSString stringWithFormat:@"line://msg/text/%@", text]];
    if ([[UIApplication sharedApplication] canOpenURL: lineURL]) {
        [[UIApplication sharedApplication] openURL: lineURL];
    }
    result(nil);
}

- (void) shareImage:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString * imageUri = call.arguments[ARGUMENT_KEY_IMAGEURI];
    NSURL * imageUrl = [NSURL URLWithString:imageUri];
    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setData:[NSData dataWithContentsOfURL:imageUrl] forPasteboardType:@"public.jpeg"];
    NSURL * lineURL = [NSURL URLWithString:[NSString stringWithFormat:@"line://msg/image/%@", pasteboard.name]];
    if ([[UIApplication sharedApplication] canOpenURL: lineURL]) {
        [[UIApplication sharedApplication] openURL: lineURL];
    }
    result(nil);
}

// ---

- (BOOL) isAppInstalled:(NSString*)scheme{
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", scheme]];
    return [[UIApplication sharedApplication] canOpenURL:url];
}

@end
