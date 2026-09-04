//
//  EZEnumTypes.m
//  Easydict
//
//  Created by tisfeng on 2023/4/18.
//  Copyright © 2023 izual. All rights reserved.
//

#import "EZEnumTypes.h"

#import "OrderedDictionary+Variadic.h"

#pragma mark - EZServiceType
NSString *const EZServiceTypeYoudao = @"Youdao";
NSString *const EZServiceTypeApple = @"Apple";

NSString *const EZQueryTextTypeKey = @"QueryTextType";
NSString *const EZIntelligentQueryTextTypeKey = @"IntelligentQueryTextType";


#pragma mark - EZActionType
NSString *const EZActionTypeNone = @"none";
NSString *const EZActionTypeShortcutQuery = @"shortcut_query";
NSString *const EZActionTypeInputQuery = @"input_query";
NSString *const EZActionTypeInvokeQuery = @"invoke_query";
NSString *const EZActionTypePasteboardTranslate = @"pasteboard_translate";


@implementation EZEnumTypes

+ (NSString *)windowName:(EZWindowType)type {
    if (type == EZWindowTypeFixed) {
        return @"fixed_window";
    }
    return @"none_window";
}

+ (MMOrderedDictionary *)fixedWindowPositionDict {
    MMOrderedDictionary *dict = [[MMOrderedDictionary alloc] initWithKeysAndObjects:
                                                                 @(EZShowWindowPositionRight), NSLocalizedString(@"fixed_window_position_right", nil),
                                                                 @(EZShowWindowPositionMouse), NSLocalizedString(@"fixed_window_position_mouse", nil),
                                                                 @(EZShowWindowPositionFormer), NSLocalizedString(@"fixed_window_position_former", nil),
                                                                 @(EZShowWindowPositionCenter), NSLocalizedString(@"fixed_window_position_center", nil),
                                                                 nil];

    return dict;
}

@end
