//
//  NetworkViewController.h
//  Paula
//
//  Created by Kevin Tseng on 11/1/12.
//  Copyright (c) 2012 inomadmusic.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaulaUtilities.m"

@class NetworkViewController;

@protocol GameCommunicationDelegate <NSObject>
@required
- (void) send:(uint8_t)message;
- (void) noteOnWithNumber:(NSInteger)num sendMessage:(BOOL)send;
- (void) allNotesOff;
- (void) presentGame;
- (void) selectedRowAtIndexPath:(NSUInteger*)idx;
@end

@interface NetworkViewController : UIViewController

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *hostGameButton;
@property (strong, nonatomic) UIButton *searchGameButton;

@end
