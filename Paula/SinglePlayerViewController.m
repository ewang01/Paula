//
//  SinglePlayerViewController.m
//  Paula
//
//  Created by Grant Damron on 10/10/12.
//  Copyright (c) 2012 Grant Damron. All rights reserved.
//

#import "SinglePlayerViewController.h"
#import "Countdown.h"

#define OFFALPHA 0.5
#define BUTTONOFFSET 2.0

#define TEMP_BPM 100.0
#define TEMP_DUR 10.0
#define TEMP_LAYERS 1
#define TEMP_SECTIONS 1

@interface SinglePlayerViewController () {
    // These are all temporary
    NSArray *scale;
    // used for keeping track of time while a melody plays
    int melIndex;
    double totalDur;
    //Metronome *met;
    NSArray *melNotes;
}

@property (strong) NSNetServiceBrowser *browser;
@property (nonatomic) NSError *error;
@property (assign) BOOL isMultiPlayerMode;
@property (strong, nonatomic) GameOver *gameOver;
@end

@implementation SinglePlayerViewController

@synthesize controller=_controller;
@synthesize backButton;
@synthesize sineButton1;
@synthesize sineButton2;
@synthesize sineButton3;
@synthesize sineButton4;
@synthesize sineButton5;
@synthesize sineButton6;
@synthesize sineButton7;
@synthesize sineButton8;
@synthesize scoreDisplay;
@synthesize mistakesLeftDisplay;
@synthesize toneGen;
@synthesize isMultiPlayerMode;
@synthesize metronome;
@synthesize paula;
@synthesize game;
@synthesize gameOver;


//////////////////  NOTE ON AND OFF /////////////

- (void) noteOnWithNumber:(NSInteger)num sendMessage:(BOOL)send {
    int s = 1;
    
    if (num==1) {
        sineButton1.alpha = 1.0;
    } else if (num==2) {
        sineButton2.alpha = 1.0;
    } else if (num==3) {
        sineButton3.alpha = 1.0;
    } else if (num==4) {
        sineButton4.alpha = 1.0;
    } else if (num==5) {
        sineButton5.alpha = 1.0;
    } else if (num==6) {
        sineButton6.alpha = 1.0;
    } else if (num==7) {
        sineButton7.alpha = 1.0;
    } else if (num==8) {
        sineButton8.alpha = 1.0;
    }
    
    if(send) {
        uint8_t c = 0;
        switch (num) {
                case 1: c = '1'; break;
                case 2: c = '2'; break;
                case 3: c = '3'; break;
                case 4: c = '4'; break;
                case 5: c = '5'; break;
                case 6: c = '6'; break;
                case 7: c = '7'; break;
                case 8: c = '8'; break;
        }
        [self.controller send:c];
    }
    [toneGen noteOn:220*(pow (2, ([[scale objectAtIndex:num-1]intValue])/12.0)) withGain:1.0 andSoundType:s];
    
    if (!game.isPaulasTurn) {
        [self checkContinueConditions:num];
    }
}

- (void) noteOffWithNumber:(NSInteger)num sendMessage:(BOOL)send {
    if (num==1) {
        sineButton1.alpha = OFFALPHA;
    } else if (num==2) {
        sineButton2.alpha = OFFALPHA;
    } else if (num==3) {
        sineButton3.alpha = OFFALPHA;
    } else if (num==4) {
        sineButton4.alpha = OFFALPHA;
    } else if (num==5) {
        sineButton5.alpha = OFFALPHA;
    } else if (num==6) {
        sineButton6.alpha = OFFALPHA;
    } else if (num==7) {
        sineButton7.alpha = OFFALPHA;
    } else if (num==8) {
        sineButton8.alpha = OFFALPHA;
    }
    if(send) {
        [self.controller send:'0'];
    }
    [toneGen noteOff:220*(pow (2, ([[scale objectAtIndex:num-1]intValue])/12.0))];
}

// wrapper for noteOnWithNumber, used by UIButtons
- (void)noteOn:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self noteOnWithNumber:[button.titleLabel.text integerValue] sendMessage:YES];
}

// wrapper for noteOffWithNumber, used by UIButtons
- (void)noteOff:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self noteOffWithNumber:[button.titleLabel.text integerValue] sendMessage:YES];
}

// Stops all tones currently playing.  Bonjour currently uses this
- (void)allNotesOff {
    sineButton1.alpha = OFFALPHA;
    sineButton2.alpha = OFFALPHA;
    sineButton3.alpha = OFFALPHA;
    sineButton4.alpha = OFFALPHA;
    sineButton5.alpha = OFFALPHA;
    sineButton6.alpha = OFFALPHA;
    sineButton7.alpha = OFFALPHA;
    sineButton8.alpha = OFFALPHA;
    [toneGen noteOff];
}

//////////////// GAME MECHANICS ///////////////

- (void)playCountdownAndStartGame {
    [NSTimer scheduledTimerWithTimeInterval:(3.25*(60.0/TEMP_BPM)) target:self selector:@selector(startGame) userInfo:nil repeats:NO];
    Countdown *countdown = [[Countdown alloc] initWithWidth:self.view.frame.size.width AndHeight:self.view.frame.size.height];
    UILabel *tempLabel = countdown.label;
    [self.view addSubview:tempLabel];
    [self.view bringSubviewToFront:tempLabel];
    [countdown countdownWithTempo:TEMP_BPM];
}

- (void)startGame {
    paula = [[Paula alloc] initWithDuration:TEMP_DUR Tempo:TEMP_BPM NumberOfLayers:TEMP_LAYERS AndSections:TEMP_SECTIONS];
    toneGen = [[ToneGenerator alloc] init];
    game = [self setupGame];
    [toneGen start];
    [metronome turnOnWithNotification:@"paulaClick"];
}

- (Game *)setupGame {
    Game *g = [[Game alloc] init];
    Layer *newLayer = [[Layer alloc] init];
    newLayer.notes = [[NSArray alloc] initWithArray:[paula generateRandomLayer]];
    Section *newSection = [[Section alloc] init];
    [newSection addLayer:newLayer];
    
    [g.level.song addSection:newSection];
    
    return g;
}

- (void)turnBackOverToPaula {
    [game.currentRound removeAllObjects];
    [metronome turnOnWithNotification:@"paulaClick"];
}

- (void)checkContinueConditions:(int)num {
    int continueCondition = [game addNoteAndCompare:num];
    if (continueCondition==0) {
        //NSLog(@"continuing");
        [self updatePlayerDisplayInfo];
    } else if (continueCondition==1) {
        //NSLog(@"paula's turn");
        game.isPaulasTurn = YES;
        [game.currentRound removeAllObjects];
        [NSTimer scheduledTimerWithTimeInterval:metronome.beatDuration
                                         target:self selector:@selector(turnBackOverToPaula)
                                       userInfo:nil
                                        repeats:NO];
        [self updatePlayerDisplayInfo];
    } else if (continueCondition==2) {
        //NSLog(@"game over");
        [self gameLost];
    }
}

- (void)paulaClickListen:(id)sender {
    [self allNotesOff];
    Section *currentSection = game.level.song.sections[0];
    Layer *currentLayer = currentSection.layers[0];
    // get the index in the layer of the current note
    int index = [currentLayer.currentNote intValue];
    // get the index in the layer of the note stop at for this round
    int stopNote = [currentLayer.currentStopIndex intValue];
    //NSLog(@"%d %d %d", index, stopNote, currentLayer.notes.count);
    if (index < currentLayer.notes.count) {
        if (index >= stopNote) {
            index = 0;
            [metronome turnOff];
            game.isPaulasTurn = NO;
            currentLayer.currentStopIndex = [NSNumber numberWithInt:stopNote+1];
        } else {
            NSInteger i = [[currentLayer.notes objectAtIndex:index++] integerValue];
            if (i > 0) {
                [self noteOnWithNumber:i sendMessage:NO];
                [game.currentRound addObject:[NSNumber numberWithInt:i]];
            }
        }
        currentLayer.currentNote = [NSNumber numberWithInt:index];
    } else {
        // round over
        [self allNotesOff];
        [metronome turnOff];
    }
}

- (void)playerClickListen:(id)sender {
    [self allNotesOff];
    NSLog(@"click!");
}

- (void)updatePlayerDisplayInfo {
    scoreDisplay.text = [NSString stringWithFormat: @"score: %d", [game.score intValue]];
    mistakesLeftDisplay.text = [NSString stringWithFormat: @"mistakes: %d", ([game.player.mistakesAllowed intValue] - [game.player.mistakesMade intValue])];
}

- (void)gameLost {
    mistakesLeftDisplay.text = @"mistakes: 0";
    gameOver = [[GameOver alloc] initWithWidth:self.view.bounds.size.width AndHeight:self.view.bounds.size.height];
    [gameOver gameLost];
    [self.view addSubview:gameOver.label];
    [self.view addSubview:gameOver.button];
    [gameOver.button addTarget:self action:@selector(gameLostButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)gameWon {
    gameOver = [[GameOver alloc] initWithWidth:self.view.bounds.size.width AndHeight:self.view.bounds.size.height];
    [gameOver gameWon:[game.score intValue]];
    [self.view addSubview:gameOver.label];
    [self.view addSubview:gameOver.button];
    [gameOver.button addTarget:self action:@selector(gameWonButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

/////////////////// NAVIGATION ////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
	metronome = [[Metronome alloc] initWithBPM:TEMP_BPM AndResolution:2];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paulaClickListen:) name:@"paulaClick" object:metronome];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerClickListen:) name:@"playerClick" object:metronome];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [toneGen stop];
    [metronome turnOff];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Back to the main view controller
- (void) backButtonPressed {
    //[toneGen stop];
    melIndex = 0;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)gameLostButtonPressed {
    [gameOver.label removeFromSuperview];
    [gameOver.button removeFromSuperview];
    //[toneGen stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)gameWonButtonPressed {
    [gameOver.label removeFromSuperview];
    [gameOver.button removeFromSuperview];
    [self playCountdownAndStartGame];
}

/////////////////// VIEW SETUP ////////////

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        melIndex = 0;
        totalDur = 0.0;
        self.view.backgroundColor = [UIColor blackColor];
        scale = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0],
                 [NSNumber numberWithInt:2],
                 [NSNumber numberWithInt:5],
                 [NSNumber numberWithInt:7],
                 [NSNumber numberWithInt:8],
                 [NSNumber numberWithInt:9],
                 [NSNumber numberWithInt:12],
                 [NSNumber numberWithInt:14], nil];
        
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = self.view.bounds.size.height;
        
        [self setupPlayerDisplayInfo];
        
        sineButton1 = [self setupButton:sineButton1 OnScreenWithX:BUTTONOFFSET YOffset:BUTTONOFFSET andNumber:1];
        sineButton2 = [self setupButton:sineButton2 OnScreenWithX:width/2+BUTTONOFFSET/2 YOffset:BUTTONOFFSET andNumber:2];
        sineButton3 = [self setupButton:sineButton3 OnScreenWithX:BUTTONOFFSET YOffset:(height-20)/4+BUTTONOFFSET/2 andNumber:3];
        sineButton4 = [self setupButton:sineButton4 OnScreenWithX:width/2+BUTTONOFFSET/2 YOffset:(height-20)/4+BUTTONOFFSET/2 andNumber:4];
        sineButton5 = [self setupButton:sineButton5 OnScreenWithX:BUTTONOFFSET YOffset:(height-20)/2 andNumber:5];
        sineButton6 = [self setupButton:sineButton6 OnScreenWithX:width/2+BUTTONOFFSET/2 YOffset:(height-20)/2 andNumber:6];
        sineButton7 = [self setupButton:sineButton7 OnScreenWithX:BUTTONOFFSET YOffset:(height-20)*.75-BUTTONOFFSET/2 andNumber:7];
        sineButton8 = [self setupButton:sineButton8 OnScreenWithX:width/2+BUTTONOFFSET/2 YOffset:(height-20)*.75-BUTTONOFFSET/2 andNumber:8];
        
        backButton = addBackButton(width, height);
        [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:backButton];
        [self playCountdownAndStartGame];
        
    }
    return self;
}

// The individual tiles
- (UIButton *)setupButton:(UIButton *)sender OnScreenWithX:(int)x YOffset:(int)y andNumber:(int)num {
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    sender = [UIButton buttonWithType:UIButtonTypeCustom];
    sender.backgroundColor = [UIColor colorWithRed:(arc4random()%11)/10.0 green:(arc4random()%11)/10.0 blue:(arc4random()%11)/10.0 alpha:1.0];
    [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    sender.frame = CGRectMake(x, y, width/2-BUTTONOFFSET, (height-20)/4-BUTTONOFFSET);
    sender.titleLabel.alpha = 0.0;
    [sender setTitle:[NSString stringWithFormat:@"%d", num] forState:UIControlStateNormal];
    [self.view addSubview:sender];
    [sender addTarget:self action:@selector(noteOn:) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragEnter];
    [sender addTarget:self action:@selector(noteOff:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchDragExit];
    sender.alpha = OFFALPHA;
    return sender;
}

- (void)setupPlayerDisplayInfo {
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    scoreDisplay = [[UILabel alloc] initWithFrame:CGRectMake(width/2-48, height-18, 96, 16)];
    scoreDisplay.backgroundColor = [UIColor clearColor];
    scoreDisplay.textColor = [UIColor cyanColor];
    scoreDisplay.text = @"score: 0";
    scoreDisplay.textAlignment = NSTextAlignmentCenter;
    scoreDisplay.font = [UIFont systemFontOfSize:14];
    
    mistakesLeftDisplay = [[UILabel alloc] initWithFrame:CGRectMake(width-74, height-18, 72, 16)];
    mistakesLeftDisplay.backgroundColor = [UIColor clearColor];
    mistakesLeftDisplay.textColor = [UIColor cyanColor];
    mistakesLeftDisplay.text = @"mistakes: 3";
    mistakesLeftDisplay.textAlignment = NSTextAlignmentRight;
    mistakesLeftDisplay.font = [UIFont systemFontOfSize:14];
    
    [self.view addSubview:scoreDisplay];
    [self.view addSubview:mistakesLeftDisplay];
}

@end
