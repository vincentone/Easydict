//
//  EZBaseQueryWindow.m
//  Easydict
//
//  Created by tisfeng on 2022/11/19.
//  Copyright © 2022 izual. All rights reserved.
//

#import "EZBaseQueryWindow.h"
#import "EZTitlebar.h"
#import "EZWindowManager.h"
#import "NSImage+EZResize.h"

#if __has_include(<AppKit/NSGlassEffectView.h>)
#import <AppKit/NSGlassEffectView.h>
#endif


@interface EZBaseQueryWindow () <NSWindowDelegate, NSToolbarDelegate>

@end

@implementation EZBaseQueryWindow

- (instancetype)initWithWindowType:(EZWindowType)type {
    // Floating query window should not activate the app (menu bar app behavior).
    NSWindowStyleMask style = NSWindowStyleMaskTitled | NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskClosable;
    style |= NSWindowStyleMaskNonactivatingPanel;

    CGRect frame = [EZLayoutManager.shared windowFrameWithType:type];

    if (self = [super initWithContentRect:frame styleMask:style backing:NSBackingStoreBuffered defer:YES]) {
        self.windowType = type;

        self.floatingPanel = YES;
        self.hidesOnDeactivate = NO;
        self.collectionBehavior |= NSWindowCollectionBehaviorTransient | NSWindowCollectionBehaviorIgnoresCycle;
        self.movableByWindowBackground = YES;
        self.level = NSNormalWindowLevel;
        self.titlebarAppearsTransparent = YES;
        self.titleVisibility = NSWindowTitleHidden;
        self.delegate = self;

        self.opaque = NO;
        self.backgroundColor = [NSColor clearColor];
        self.hasShadow = YES;

        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    NSView *themeView = self.contentView.superview;
    [self setupGlassEffectInView:themeView];

    self.titleBar = [[EZTitlebar alloc] initWithFrame:CGRectMake(0, 0, self.width, EZTitlebarHeight_28)];
    self.titleBar.wantsLayer = YES;
    [themeView addSubview:self.titleBar positioned:NSWindowAbove relativeTo:nil];
    [self.titleBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(themeView);
        make.height.mas_equalTo(EZTitlebarHeight_28);
    }];
}

- (void)setupGlassEffectInView:(NSView *)containerView {
    if (self.glassBackgroundView) {
        return;
    }

#if __has_include(<AppKit/NSGlassEffectView.h>)
    if (@available(macOS 26.0, *)) {
        NSGlassEffectView *glassView = [[NSGlassEffectView alloc] initWithFrame:containerView.bounds];
        glassView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        glassView.cornerRadius = EZCornerRadius_22;
        glassView.style = NSGlassEffectViewStyleClear;
        [containerView addSubview:glassView positioned:NSWindowBelow relativeTo:nil];
        self.glassBackgroundView = glassView;
        return;
    }
#endif

    NSVisualEffectView *visualEffectView = [[NSVisualEffectView alloc] initWithFrame:containerView.bounds];
    visualEffectView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    visualEffectView.material = NSVisualEffectMaterialPopover;
    visualEffectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    visualEffectView.state = NSVisualEffectStateActive;
    visualEffectView.wantsLayer = YES;
    visualEffectView.layer.cornerRadius = 16.0;
    visualEffectView.layer.masksToBounds = YES;
    [containerView addSubview:visualEffectView positioned:NSWindowBelow relativeTo:nil];
    self.glassBackgroundView = visualEffectView;
}


#pragma mark - Setter

- (void)setWindowType:(EZWindowType)windowType {
    _windowType = windowType;
    
    EZBaseQueryViewController *viewController = [[EZBaseQueryViewController alloc] initWithWindowType:windowType];
    self.queryViewController = viewController;
}

- (void)setQueryViewController:(EZBaseQueryViewController *)viewController {
    _queryViewController = viewController;
    
    viewController.baseQueryWindow = self;
    self.contentViewController = viewController;
}

- (void)setPin:(BOOL)pin {
    [self updateWindowLevel:pin];
    self.titleBar.pin = pin;
}

- (void)updateWindowLevel:(BOOL)pin {
    _pin = pin;

    // !!!: Do not use kCGMaximumWindowLevel, otherwise it will obscure the tooltip.
    NSWindowLevel level = pin ? kCGUtilityWindowLevel : kCGNormalWindowLevel;
    self.level = level;
}

#pragma mark - Rewrite

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (BOOL)canBecomeMainWindow {
    return YES;
}

- (NSTimeInterval)animationResizeTime:(NSRect)newFrame {
    return EZUpdateTableViewRowHeightAnimationDuration;
}


- (void)dealloc {
    MMLogInfo(@"dealloc query window: %@", self);
}

#pragma mark - NSWindowDelegate, NSNotification

- (void)windowDidBecomeKey:(NSNotification *)notification {
    //    MMLogInfo(@"windowDidBecomeKey: %@", self);
    
    // We need to update the window type when the window becomes the key window.
    [EZWindowManager.shared updateFloatingWindowType:self.windowType isShowing:YES];
    
    if (self.didBecomeKeyWindowBlock) {
        self.didBecomeKeyWindowBlock();
    }
}

- (void)windowWillClose:(NSNotification *)notification {
    [self.queryViewController cancelAutoQuery];
}

- (void)windowDidResignKey:(NSNotification *)notification {
    //    MMLogInfo(@"windowDidResignKey: %@", self);
    
    // Close floating window when losing focus if it's not pinned.
    [EZWindowManager.shared closeFloatingWindowIfNotPinned];
}

- (void)windowDidResize:(NSNotification *)aNotification {
        MMLog(@"windowDidResize: %@, windowType: %ld", @(self.frame), self.windowType);
    
    [[EZLayoutManager shared] updateWindowFrame:self];
    
    if (self.resizeWindowBlock) {
        self.resizeWindowBlock();
    }
    
    if (self.queryViewController.resizeWindowBlock) {
        self.queryViewController.resizeWindowBlock();
    }
}

- (void)windowDidMove:(NSNotification *)notification {
    [[EZLayoutManager shared] updateWindowFrame:self];
}

- (BOOL)windowShouldClose:(NSWindow *)sender {
    return YES;
}

// Window is hidden or showing.
- (void)windowDidChangeOcclusionState:(NSNotification *)notification {
    //    MMLogInfo(@"window Did Change Occlusion State");
    
    // Window is obscured
    if (self.occlusionState != NSWindowOcclusionStateVisible) {
        
    }
}

@end
