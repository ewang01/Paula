//
//  KevinViewController.h
//  Paula
//
//  Created by Grant Damron on 10/10/12.
//  Copyright (c) 2012 Grant Damron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameServer.h"

@interface KevinViewController : UIViewController

@property (strong, nonatomic) UIButton *backButton;
@property (nonatomic) GameServer *server;

@end