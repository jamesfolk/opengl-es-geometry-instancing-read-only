//
//  testappAppDelegate.h
//  testapp
//
//  Created by Dmytro on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class testappViewController;

@interface testappAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet testappViewController *viewController;

@end
