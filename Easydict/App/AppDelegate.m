//
//  AppDelegate.m
//  Easydict
//
//  Created by tisfeng on 2022/10/30.
//  Copyright © 2023 izual. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+EZURLScheme.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    MMLogInfo(@"程序启动");

    [[StatusBarController sharedInstance] setup];

    [ShortcutManager.shared setupShortcut];

    // Menu bar app: never show a regular main window.
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];

    [self registerRouters];
    
    [DarkModeManager.shared updateDarkMode:MyConfiguration.shared.appearance];
}

#pragma mark - NSApplicationDelegate

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
    return NO;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    return YES;
}

@end
