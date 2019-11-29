//
//  AppDelegate.m
//  GanttChart.ObjC.macOS
//
//  Created by DlhSoft on 19/10/2019.
//

#import "AppDelegate.h"
#import "GanttChart_ObjC_macOS-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (instancetype)init {
    self = [super init];
    [GanttisLicense new];
    return self;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}


@end
