//
//  NSView+EZGlassCard.h
//  Easydict
//
//  Created by tisfeng on 2026/9/6.
//  Copyright © 2026 izual. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

/// Mirror of NSGlassEffectViewStyle raw values, so this header compiles on
/// SDKs where the AppKit type is unavailable.
typedef NS_ENUM(NSInteger, EZGlassStyle) {
    EZGlassStyleRegular = 0,
    EZGlassStyleClear = 1,
};

@interface NSView (EZGlassCard)

/// Add a full-size Liquid Glass background board underneath existing subviews.
/// Returns nil on macOS < 26 or older SDKs, so callers can fall back to the
/// translucent CALayer card style.
- (nullable NSView *)ez_addGlassBackgroundWithStyle:(EZGlassStyle)style
                                       cornerRadius:(CGFloat)cornerRadius;

@end

NS_ASSUME_NONNULL_END
