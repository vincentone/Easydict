//
//  EZEnumTypes.m
//  Easydict
//
//  Created by tisfeng on 2023/4/18.
//  Copyright © 2023 izual. All rights reserved.
//

#import "EZEnumTypes.h"

#pragma mark - EZServiceType
NSString *const EZServiceTypeYoudao = @"Youdao";
NSString *const EZServiceTypeApple = @"Apple";

NSString *const EZQueryTextTypeKey = @"QueryTextType";
NSString *const EZIntelligentQueryTextTypeKey = @"IntelligentQueryTextType";


#pragma mark - EZActionType
NSString *const EZActionTypeNone = @"none";
NSString *const EZActionTypeInputQuery = @"input_query";
NSString *const EZActionTypeInvokeQuery = @"invoke_query";
NSString *const EZActionTypePasteboardTranslate = @"pasteboard_translate";
