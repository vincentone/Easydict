//
//  EZTitlebar.m
//  Easydict
//
//  Created by tisfeng on 2022/11/19.
//  Copyright © 2022 izual. All rights reserved.
//

#import "EZTitlebar.h"
#import "EZTitleBarMoveView.h"
#import "NSObject+EZWindowType.h"
#import "NSImage+EZResize.h"
#import "NSImage+EZSymbolmage.h"
#import "NSObject+EZDarkMode.h"
#import "EZBaseQueryWindow.h"

typedef NS_ENUM(NSInteger, EZTitlebarButtonType) {
    EZTitlebarButtonTypePin = 0,
};

@interface EZTitlebar ()

@property (nonatomic, assign) CGSize buttonSize;
@property (nonatomic, assign) CGFloat buttonWidth;

@end

@implementation EZTitlebar

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup {
    self.wantsLayer = YES;
    self.buttonWidth = 24;
    self.buttonSize = CGSizeMake(self.buttonWidth, self.buttonWidth);

    [self addSubview:self.pinButton];

    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateTitlebar) name:NSNotification.languagePreferenceChanged object:nil];
}

- (void)updateTitlebar {
    /**
     Fix appcenter issue, seems cannot remove self.subviews 🤔

     -[EZTitlebar updateConstraints]
     EZTitlebar.m, line 64
     SIGABRT: *** Collection <__NSArrayM: 0x6000036e45d0> was mutated while being enumerated.
     */

    [_pinButton removeFromSuperview];

    [self updatePinButton];

    [self addSubview:self.pinButton];

    [self setNeedsUpdateConstraints:YES];
}

- (void)updateConstraints {
    CGFloat margin = EZHorizontalCellSpacing_10;
    CGFloat topOffset = EZTitlebarHeight_28 - self.buttonWidth;

    [self.pinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.buttonWidth);
        make.left.inset(margin);
        make.top.equalTo(self).offset(topOffset);
    }];

    [super updateConstraints];
}

#pragma mark - Public Methods

- (void)updateShortcutButtonsToolTip {
    self.pinButton.toolTip = [self toolTipStrWithButtonType:EZTitlebarButtonTypePin];
}

#pragma mark - Getter && Setter

- (EZOpenLinkButton *)pinButton {
    if (!_pinButton) {
        EZOpenLinkButton *pinButton = [[EZOpenLinkButton alloc] init];
        _pinButton = pinButton;

        pinButton.contentTintColor = [NSColor clearColor];
        pinButton.clickBlock = nil;
        self.pin = NO;

        mm_weakify(self);
        [pinButton setMouseDownBlock:^(EZButton *_Nonnull button) {
            mm_strongify(self);
            self.pin = !self.pin;
        }];

        [pinButton setMouseUpBlock:^(EZButton *_Nonnull button) {
            mm_strongify(self);
            BOOL oldPin = !self.pin;

            // This means clicked pin button.
            if (button.state == EZButtonHoverState) {
                self.pin = !oldPin;
            } else if (button.buttonState == EZButtonNormalState) {
                self.pin = oldPin;
            }
        }];

        [self executeOnAppearanceChange:^(EZTitlebar *titlebar, BOOL isDarkMode) {
            [titlebar updatePinButtonImage];
        }];
    }
    return _pinButton;
}

- (BOOL)pin {
    EZBaseQueryWindow *window = (EZBaseQueryWindow *)self.window;
    return window.pin;
}

- (void)setPin:(BOOL)pin {
    [(EZBaseQueryWindow *)self.window updateWindowLevel:pin];

    [self updatePinButton];
}

#pragma mark -

- (NSString *)toolTipStrWithButtonType:(EZTitlebarButtonType)type {
    NSString *toolTipStr = @"";
    if (type == EZTitlebarButtonTypePin) {
        NSString *shortcutStr = MyConfiguration.shared.pinShortcutString;
        NSString *hint = self.pin ? NSLocalizedString(@"unpin", nil) : NSLocalizedString(@"pin", nil);
        if (shortcutStr.length != 0) {
            toolTipStr = [NSString stringWithFormat:@"%@, %@", hint, shortcutStr];
        } else {
            toolTipStr = [NSString stringWithFormat:@"%@", hint];
        }
    }
    return toolTipStr;
}

- (void)updatePinButton {
    self.pinButton.toolTip = [self toolTipStrWithButtonType:EZTitlebarButtonTypePin];
    [self updatePinButtonImage];
}

- (void)updatePinButtonImage {
    CGFloat imageWidth = 18;
    CGSize imageSize = CGSizeMake(imageWidth, imageWidth);

    // Since the system's dark picture mode cannot dynamically follow the mode switch changes, we manually implement dark mode picture coloring.
    NSColor *pinNormalLightTintColor = [NSColor mm_colorWithHexString:@"#797A7F"];
    NSColor *pinNormalDarkTintColor = [NSColor mm_colorWithHexString:@"#C0C1C4"];

    NSImage *normalImage = [[NSImage imageNamed:@"new_pin_normal"] resizeToSize:imageSize];
    NSImage *selectedImage = [[NSImage imageNamed:@"new_pin_selected"] resizeToSize:imageSize];

    BOOL isDarkMode = self.pinButton.isDarkMode;
    NSColor *pinTintColor = isDarkMode ? pinNormalDarkTintColor : pinNormalLightTintColor;
    NSImage *normalTintedImage = [normalImage imageWithTintColor:pinTintColor];
    self.pinButton.image = self.pin ? selectedImage : normalTintedImage;
}

@end
