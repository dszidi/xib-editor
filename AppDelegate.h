#import <AppKit/AppKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextViewDelegate>

@property (strong) NSWindow *window;
@property (strong) NSTextView *sourceView;
@property (strong) NSView *previewContainer;

@end
