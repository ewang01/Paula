//
//  GK_GamePacket.h
//  Paula
//
//  Created by Kevin Tseng on 11/24/12.
//  Copyright (c) 2012 inomadmusic.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GAME_START = 0x01,
    GAME_SCORE_TO_SERVER = 0x02,
    GAME_SCORE_TO_CLIENT = 0x03
}
CommPacketType;

@interface GK_GamePacket : NSObject

@property (nonatomic, assign) CommPacketType *packetType;

-(id)initWithPacketType:(CommPacketType*)type;
//this should append a header info to the packet
-(NSMutableData *) data;

@end
