//
//  touchPad.m
//  6.23Demo
//
//  Created by wangcheng on 14-7-7.
//  Copyright (c) 2014年 W.C. All rights reserved.
//

#import "Joystick.h"

@interface Joystick()
{
    CGPoint sCenter;
    SKSpriteNode *stickBase;
    CGVector dir;
    CGPoint target;
    double force;
}
@end

@implementation Joystick


-(id)init
{
    self = [super init];
    if(self != nil)
    {
        stickBase = [[SKSpriteNode alloc]initWithImageNamed:@"stickBase"];
        [self addChild:stickBase];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([touches count] == 1)
    {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:stickBase];
      //  [self touchEvent:location];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([touches count] == 1)
    {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:stickBase];
        [self touchEvent:location];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate stickTouchUp];
}
-(void)touchEvent:(CGPoint)location
{
    dir.dx = location.x;
    dir.dy = location.y;
    double len = sqrt(location.x * location.x + location.y * location.y);
    if(len < 0.001)
    {
         [self.delegate stickMoveWithVector:CGVectorMake(0, 0) force:0];
        return;
    }
    if(len>stickBase.size.height/2)
    {
        force = 1;
    }
    else force = len/(stickBase.size.height/2);
    
    len = 1.0/len;
    dir.dx *= len;
    dir.dy *= len;
    [self.delegate stickMoveWithVector:dir force:force];
}
@end