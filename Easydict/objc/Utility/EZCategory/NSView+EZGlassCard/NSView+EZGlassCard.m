//
//  NSView+EZGlassCard.m
//  Easydict
//
//  Created by tisfeng on 2026/9/6.
//  Copyright © 2026 izual. All rights reserved.
//

#import "NSView+EZGlassCard.h"

#if __has_include(<AppKit/NSGlassEffectView.h>)
#import <AppKit/NSGlassEffectView.h>
#endif

@implementation NSView (EZGlassCard)

- (nullable NSView *)ez_addGlassBackgroundWithStyle:(EZGlassStyle)style
                                       cornerRadius:(CGFloat)cornerRadius {
#if __has_include(<AppKit/NSGlassEffectView.h>)
    if (@available(macOS 26.0, *)) {
        NSGlassEffectView *glassView = [[NSGlassEffectView alloc] initWithFrame:self.bounds];
        glassView.cornerRadius = cornerRadius;
        glassView.style = (NSGlassEffectViewStyle)style;
        [self addSubview:glassView positioned:NSWindowBelow relativeTo:nil];
        [glassView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        return glassView;
    }
#endif
    return nil;
}

@end
