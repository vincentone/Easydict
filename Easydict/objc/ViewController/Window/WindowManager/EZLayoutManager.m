//
//  EZWindowFrameManager.m
//  Easydict
//
//  Created by tisfeng on 2022/11/21.
//  Copyright © 2022 izual. All rights reserved.
//

#import "EZLayoutManager.h"
#import "EZBaseQueryWindow.h"


@interface EZLayoutManager ()

/// Minimum window frame size of clicked window
@property (nonatomic, assign) CGSize minimumWindowSize;
/// Maximum window frame size of clicked window
@property (nonatomic, assign) CGSize maximumWindowSize;

@end

@implementation EZLayoutManager

static EZLayoutManager *_instance;

+ (instancetype)shared {
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[super allocWithZone:NULL] init];
        });
    }
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shared];
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInitialize];
    }
    return self;
}

- (void)commonInitialize {
    self.screen = NSScreen.mainScreen;
    self.minimumWindowSize = CGSizeMake(360, 40);

    MyConfiguration *configuration = [MyConfiguration shared];

    self.fixedWindowFrame = [configuration windowFrameWithType:EZWindowTypeFixed];
    if (CGRectEqualToRect(self.fixedWindowFrame, CGRectZero)) {
        self.fixedWindowFrame = [self defaultWindowFrameWithType:EZWindowTypeFixed];
        [configuration setWindowFrame:self.fixedWindowFrame windowType:EZWindowTypeFixed];
    }
}

- (void)setScreen:(NSScreen *)screen {
    _screen = screen;

    [self setupMaximumWindowSize:screen];
}

- (void)setupMaximumWindowSize:(NSScreen *)screen {
    CGSize visibleFrameSize = screen.visibleFrame.size;
    self.maximumWindowSize = CGSizeMake(visibleFrameSize.width, visibleFrameSize.height);
}

- (CGSize)minimumWindowSize:(EZWindowType)type {
    return self.minimumWindowSize;
}

- (CGSize)maximumWindowSize:(EZWindowType)type {
    // Get maximum size from the screen's visible frame
    // self.maximumWindowSize is already set to self.screen.visibleFrame.size in setupMaximumWindowSize

    CGFloat maxWidth = self.maximumWindowSize.width;
    CGFloat maxHeight = self.maximumWindowSize.height;

    NSInteger percentage = MyConfiguration.shared.maxWindowHeightPercentage;

    CGFloat calculatedMaxHeight = maxHeight * ((CGFloat)percentage / 100.0);

    // Ensure the calculated height is not less than the minimum window height for this type
    CGFloat minHeightForType = [self minimumWindowSize:type].height;
    CGFloat effectiveMaxHeight = MAX(minHeightForType, calculatedMaxHeight);

    // Ensure it does not exceed the original screen height (shouldn't happen if percentage <= 100)
    effectiveMaxHeight = MIN(effectiveMaxHeight, maxHeight);

    return CGSizeMake(maxWidth, effectiveMaxHeight);
}


- (CGFloat)inputViewMinHeight:(EZWindowType)type {
    if (![self showInputTextField:type]) {
        return 0;
    }

    return 65; // > two line
}

- (CGFloat)inputViewMaxHeight:(EZWindowType)type {
    if (![self showInputTextField:type]) {
        return 0;
    }

    return NSScreen.mainScreen.frame.size.height * 0.3;
}

- (CGRect)windowFrameWithType:(EZWindowType)type {
    if (type == EZWindowTypeFixed) {
        return self.fixedWindowFrame;
    }
    return CGRectZero;
}

- (CGRect)defaultWindowFrameWithType:(EZWindowType)type {
    CGSize visibleFrameSize = NSScreen.mainScreen.visibleFrame.size;
    CGPoint centerPoint = NSMakePoint(visibleFrameSize.width / 2, visibleFrameSize.height / 2);
    CGFloat rateableWidth = 1727.0 / NSScreen.mainScreen.frame.size.width;
    CGFloat fixedWindowWidth = 420 * rateableWidth;

    if (type == EZWindowTypeFixed) {
        return CGRectMake(centerPoint.x,
                          centerPoint.y,
                          fixedWindowWidth,
                          self.minimumWindowSize.height);
    }
    return CGRectZero;
}

- (CGRect)windowFrame:(EZBaseQueryWindow *)window {
    return [self windowFrameWithType:window.windowType];
}

- (void)updateWindowFrame:(EZBaseQueryWindow *)window {
    EZWindowType windowType = window.windowType;

    CGRect windowFrame = window.frame;

    // Record floating window frame
    [MyConfiguration.shared setWindowFrame:windowFrame windowType:windowType];

    if (windowType == EZWindowTypeFixed) {
        self.fixedWindowFrame = windowFrame;

        // Record screenVisibleFrame when fixedWindowPosition is EZShowWindowPositionFormer
        if (MyConfiguration.shared.fixedWindowPosition == EZShowWindowPositionFormer) {
            CGPoint fixedWindowCenter = NSMakePoint(NSMidX(windowFrame), NSMidY(windowFrame));

            // Update lastPoint to update current active screen
            EZWindowManager.shared.lastPoint = fixedWindowCenter;
            MyConfiguration.shared.formerFixedScreenVisibleFrame = self.screen.visibleFrame;
        }
    }
}

- (BOOL)showInputTextField:(EZWindowType)windowType {
    // Input field is always visible in this build.
    return YES;
}

- (void)updateScreen:(NSScreen *)screen {
    _screen = screen;

    [self setupMaximumWindowSize:screen];
}

- (void)updateScreenVisibleFrame:(CGRect)visibleFrame {
   _screenVisibleFrame = visibleFrame;
}

@end
