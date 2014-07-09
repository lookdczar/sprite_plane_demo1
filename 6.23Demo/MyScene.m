//
//  MyScene.m
//  6.23Demo
//
//  Created by wangcheng on 14-6-23.
//  Copyright (c) 2014年 W.C. All rights reserved.
//

#import "MyScene.h"
#import "MySceneSec.h"

@interface MyScene()

@property BOOL contentCreated;

@end

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
        
        SKNode *helloNode = [self childNodeWithName:@"lbHello"];
        if(helloNode != nil)
        {
            SKAction *moveUp = [SKAction moveByX:0 y:100 duration:0.5];
            SKAction *zoom = [SKAction scaleTo:2.0 duration:0.5];
           // SKAction *pause = [SKAction waitForDuration:0.5];
            SKAction *fadeAway = [SKAction fadeOutWithDuration:0.5];
            SKAction *remove = [SKAction removeFromParent];

            SKAction *moveSequence = [SKAction sequence:@[moveUp,zoom,fadeAway,remove] ];
            
            [helloNode runAction:moveSequence completion:^(){
                SKScene *secScene = [[MySceneSec alloc]initWithSize:self.size];
                SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
                [self.view presentScene:secScene transition:doors];
            }];
        }
    
        //[self addChild:sprite];
//    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}


-(void)didMoveToView:(SKView *)view
{
    if(!_contentCreated)
    {
        [self createSceneContents];
        _contentCreated = YES;
    }
}

-(void)createSceneContents
{
    
    self.backgroundColor = [SKColor greenColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    SKLabelNode *lbHello = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    lbHello.text = @"开始游戏";
    lbHello.fontSize = 30;
    lbHello.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    lbHello.name = @"lbHello";
    
    [self addChild:lbHello];
}


@end
