//
//  EZEnumTypes.h
//  Easydict
//
//  Created by tisfeng on 2023/4/18.
//  Copyright © 2023 izual. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMOrderedDictionary;

NS_ASSUME_NONNULL_BEGIN

/// Window type
typedef NS_ENUM(NSInteger, EZWindowType) {
    EZWindowTypeNone = -1,
    EZWindowTypeFixed = 2,
};

/// Show window position
typedef NS_ENUM(NSUInteger, EZShowWindowPosition) {
    EZShowWindowPositionRight = 0,
    EZShowWindowPositionMouse = 1,
    EZShowWindowPositionFormer = 2,
    EZShowWindowPositionCenter = 3,
};

typedef NSString *EZServiceType NS_STRING_ENUM NS_SWIFT_NAME(ServiceType);
FOUNDATION_EXPORT EZServiceType const EZServiceTypeYoudao;
FOUNDATION_EXPORT EZServiceType const EZServiceTypeApple;

FOUNDATION_EXPORT NSString *const EZQueryTextTypeKey;
FOUNDATION_EXPORT NSString *const EZIntelligentQueryTextTypeKey;

typedef NS_OPTIONS(NSUInteger, EZQueryTextType) {
    EZQueryTextTypeNone = 0,             // 0
    EZQueryTextTypeTranslation = 1 << 0, // 01 = 1
    EZQueryTextTypeDictionary = 1 << 1,  // 10 = 2
    EZQueryTextTypeSentence = 1 << 2,    // 100 = 4
};


typedef NS_ENUM(NSUInteger, EZServiceUsageStatus) {
    EZServiceUsageStatusDefault = 0,
    EZServiceUsageStatusAlwaysOff = 1,
    EZServiceUsageStatusAlwaysOn = 2,
};

typedef NSString *EZActionType NS_STRING_ENUM NS_SWIFT_NAME(ActionType);
FOUNDATION_EXPORT EZActionType const EZActionTypeNone;
FOUNDATION_EXPORT EZActionType const EZActionTypeShortcutQuery;
FOUNDATION_EXPORT EZActionType const EZActionTypeInputQuery;
FOUNDATION_EXPORT EZActionType const EZActionTypeInvokeQuery;
FOUNDATION_EXPORT EZActionType const EZActionTypePasteboardTranslate;


@interface EZEnumTypes : NSObject

+ (NSString *)windowName:(EZWindowType)type;

+ (MMOrderedDictionary *)fixedWindowPositionDict;

@end


NS_ASSUME_NONNULL_END
