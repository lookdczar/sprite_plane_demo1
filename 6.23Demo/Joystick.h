//
//  touchPad.h
//  6.23Demo
//
//  Created by wangcheng on 14-7-7.
//  Copyright (c) 2014年 W.C. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol joystickPadDelegate <NSObject>

-(void)stickMoveWithVector:(CGVector) vector force:(double)force;
-(void)stickTouchUp;

@end

@interface Joystick : SKSpriteNode

 @property(assign,nonatomic)id<joystickPadDelegate> delegate;

-(id)init;

@end
