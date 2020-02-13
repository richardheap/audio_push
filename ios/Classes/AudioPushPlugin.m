#import "AudioPushPlugin.h"
#if __has_include(<audio_push/audio_push-Swift.h>)
#import <audio_push/audio_push-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "audio_push-Swift.h"
#endif

@implementation AudioPushPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAudioPushPlugin registerWithRegistrar:registrar];
}
@end
