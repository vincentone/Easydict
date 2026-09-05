//
//  EZResultRowView.m
//  Easydict
//
//  Created by tisfeng on 2022/12/29.
//  Copyright © 2022 izual. All rights reserved.
//

#import "EZTableRowView.h"

@implementation EZTableRowView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.backgroundColor = [NSColor clearColor];
    }
    return self;
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect {
    // Keep row background clear to let the liquid glass effect show through
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
