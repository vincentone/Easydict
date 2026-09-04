//
//  EZQueryMenuTextView.m
//  Easydict
//
//  Created by tisfeng on 2023/10/17.
//  Copyright © 2023 izual. All rights reserved.
//

#import "EZQueryMenuTextView.h"
#import "EZWindowManager.h"


@interface EZQueryMenuTextView ()

@property (nonatomic, copy) NSString *queryText;

@end

@implementation EZQueryMenuTextView

//- (NSMenu *)menu

- (NSMenu *)menuForEvent:(NSEvent *)event {
    // We need to rewrite menuForEvent: rather than menu, because we want custom menu itme shown in the first place.

    NSMenu *menu = [super menuForEvent:event];
    NSString *queryText = [self selectedText].ns_trim;

    if (queryText.length > 0) {
        NSString *title = [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"query_in_app", nil), queryText];
        NSMenuItem *queryInAppMenuItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(queryInApp:) keyEquivalent:@""];

        // Note that this shortcut only works when the menu is displayed.
        //    [queryInAppMenuItem setKeyEquivalentModifierMask: NSEventModifierFlagCommand];

        [queryInAppMenuItem setTarget:self];

        [menu insertItem:NSMenuItem.separatorItem atIndex:0];
        [menu insertItem:queryInAppMenuItem atIndex:0];
    }

    self.queryText = queryText;

    return menu;
}

- (void)queryInApp:(id)sender {
    EZActionType actionType = EZActionTypeInvokeQuery;
    EZWindowManager *windowManager = [EZWindowManager shared];
    [windowManager.floatingWindow.queryViewController startQueryText:self.queryText actionType:actionType];
}

- (nullable NSString *)selectedText {
    NSArray *selectedRanges = [self selectedRanges];
    if (selectedRanges.count > 0) {
        NSRange selectedRange = [selectedRanges[0] rangeValue];
        NSString *selectedText = [[self string] substringWithRange:selectedRange];
        if (selectedRange.length == 0) {
            selectedText = [self.string wordAtIndex:selectedRange.location];
        }
        return selectedText;
    } else {
        return nil;
    }
}

@end
