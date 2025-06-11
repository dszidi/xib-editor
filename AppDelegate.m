#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSRect frame = NSMakeRect(0, 0, 800, 600);
    NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable;
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                               styleMask:style
                                                 backing:NSBackingStoreBuffered
                                                   defer:NO];
    [self.window setTitle:@"GNUstep XIB Viewer"];
    
    NSSplitView *splitView = [[NSSplitView alloc] initWithFrame:[[self.window contentView] bounds]];
    [splitView setDividerStyle:NSSplitViewDividerStyleThin];
    [splitView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [splitView setVertical:YES];
    
    // Left view - source editor
    NSScrollView *leftScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 400, 600)];
    self.sourceView = [[NSTextView alloc] initWithFrame:leftScroll.contentView.bounds];
    [self.sourceView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [leftScroll setDocumentView:self.sourceView];
    [leftScroll setHasVerticalScroller:YES];
    [splitView addSubview:leftScroll];
    
    // Right view - preview
    self.previewContainer = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 400, 600)];
    [splitView addSubview:self.previewContainer];

    [[self.window contentView] addSubview:splitView];
    
    [self.window makeKeyAndOrderFront:nil];
    
    [self setupMenu];
}

- (void)setupMenu {
    NSMenu *menubar = [[NSMenu alloc] init];
    NSMenuItem *fileMenuItem = [[NSMenuItem alloc] init];
    [menubar addItem:fileMenuItem];
    [NSApp setMainMenu:menubar];

    NSMenu *fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
    NSMenuItem *openItem = [[NSMenuItem alloc] initWithTitle:@"Open"
                                                      action:@selector(openFile:)
                                               keyEquivalent:@"o"];
    [openItem setTarget:self];
    [fileMenu addItem:openItem];
    [fileMenuItem setSubmenu:fileMenu];
}

- (void)openFile:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"xib"]];

    if ([panel runModal] == NSModalResponseOK) {
        NSURL *fileURL = [panel URL];
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        if (data) {
            NSString *source = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self.sourceView setString:source];

            // Clear preview container
            NSArray *subviews = [self.previewContainer subviews];
            for (NSView *subview in subviews) {
                [subview removeFromSuperview];
            }

            // Load XIB as bundle and instantiate top-level views
            NSBundle *xibBundle = [NSBundle bundleWithPath:[fileURL path]];
            NSArray *topLevelObjects = nil;
            NSNib *nib = [[NSNib alloc] initWithContentsOfURL:fileURL];
            if ([nib instantiateWithOwner:nil topLevelObjects:&topLevelObjects]) {
                for (id obj in topLevelObjects) {
                    if ([obj isKindOfClass:[NSView class]]) {
                        NSView *loadedView = obj;
                        [loadedView setFrame:self.previewContainer.bounds];
                        [loadedView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
                        [self.previewContainer addSubview:loadedView];
                        break;
                    }
                }
            } else {
                NSRunAlertPanel(@"Error", @"Failed to load .xib file.", @"OK", nil, nil);
            }
        }
    }
}

@end
