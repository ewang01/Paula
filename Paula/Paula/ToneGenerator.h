//
//  ToneGenerator.h
//  Paula
//
//  Created by Grant Damron on 10/11/12.
//  Copyright (c) 2012 Grant Damron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToneGenerator : NSObject

@property (assign, nonatomic) BOOL isOn;
@property (assign, nonatomic) int waveForm;
@property (assign, nonatomic) double globalGain;

- (void)noteOn:(double)freq withGain:(double)g andSoundType:(int)s;
- (void)noteOff:(double)freq;
- (void)noteOff;
- (void)start;
- (void)stop;

@end

/*@interface Tone : NSObject

@property (assign, nonatomic) double frequency;
@property (assign, nonatomic) double phase;
@property (assign, nonatomic) double j;
@property (assign, nonatomic) double cycleLength;
@property (assign, nonatomic) double sample;

@end*/
