//
//  MySceneSec.m
//  6.23Demo
//
//  Created by wangcheng on 14-6-23.
//  Copyright (c) 2014年 W.C. All rights reserved.
//

#import "MySceneSec.h"
#import "Joystick.h"

static const uint32_t boundaryCategory = 0x1 ;
static const uint32_t blockCategory = 0x1 << 1;
static const uint32_t spaceshipCategory = 0x1 <<2;
static const uint32_t planeCategory = 0x1 <<3;
static const uint32_t bulletCategory = 0x1 <<4;

@interface MySceneSec()<SKPhysicsContactDelegate,joystickPadDelegate>
{
    NSArray *roleWalk ;
    SKSpriteNode *spaceship;
    float characterSpeed;
    SKLabelNode *lbScole;
    SKLabelNode *lbHp;
    SKNode *fireNode;
    int scole;
    int hp;
    BOOL moveRequested;
    CGVector targetVector;
    NSTimeInterval lastUpdateTimeInterval;
    SKSpriteNode *plane;
    Joystick * joyStick ;
}
@property(strong) SKTexture *role;
@property BOOL contentCreated;

@end

@implementation MySceneSec 

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.physicsWorld.gravity = CGVectorMake(0,-9);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

-(void) didMoveToView:(SKView *)view
{
    if(!_contentCreated)
    {
        [self createSceneContents];
        _contentCreated = YES;
    }
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        

        
//        CGPoint charLocation = spaceship.position;
//        CGFloat distance = sqrtf((location.x-charLocation.x)*(location.x-charLocation.x)+
//                                 (location.y-charLocation.y)*(location.y-charLocation.y));
//         SKAction *moveToTouch = [SKAction moveTo:location duration:distance/characterSpeed];
//        moveToTouch.timingMode = SKActionTimingEaseOut;
//
//        SKAction *roal = [SKAction rotateByAngle:M_PI/6 duration:1];

        
        joyStick.position = location;
        [self addChild:joyStick];
        [joyStick touchesBegan:touches withEvent:event];
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [joyStick touchesMoved:touches withEvent:event];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [joyStick removeFromParent];
    [joyStick touchesEnded:touches withEvent:event];
}

-(void) createSceneContents
{
    targetVector = CGVectorMake(0, 1);
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    characterSpeed = 400;
    
    _role = [SKTexture textureWithImageNamed:@"image.bundle/1-1"];
    roleWalk = @[
                        [SKTexture textureWithImageNamed:@"image.bundle/1-1"],
                        [SKTexture textureWithImageNamed:@"image.bundle/1-2"],
                        [SKTexture textureWithImageNamed:@"image.bundle/1-3"],
                        [SKTexture textureWithImageNamed:@"image.bundle/1-4"],
                        [SKTexture textureWithImageNamed:@"image.bundle/1-5"],
                        [SKTexture textureWithImageNamed:@"image.bundle/1-6"],
                        [SKTexture textureWithImageNamed:@"image.bundle/1-7"],
                        [SKTexture textureWithImageNamed:@"image.bundle/1-8"],
                        [SKTexture textureWithImageNamed:@"image.bundle/1-9"],
                        [SKTexture textureWithImageNamed:@"image.bundle/1-10"]
                          ];
    
    spaceship = [self newSpaceShip];
    spaceship.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:spaceship];
    
    //创建石头
    SKAction * makeRocks = [SKAction sequence:@ [
                                                 [SKAction performSelector:@selector(addRock) onTarget:self],
                                                 [SKAction waitForDuration:0.50 withRange:0.15]
                                                 ]]; 
    [self runAction:[SKAction repeatActionForever:makeRocks]];

    
    lbScole = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    lbScole.text = @"分数：0";
    lbScole.fontSize = 20;
    lbScole.color = [SKColor whiteColor];
    lbScole.colorBlendFactor = 0.5;
    lbScole.fontColor = [SKColor whiteColor];
    lbScole.position = CGPointMake(40,500);
    [self addChild:lbScole];
    
    hp = 100;
    lbHp = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    lbHp.text = @"HP：100";
    lbHp.fontSize = 20;
    lbHp.color = [SKColor whiteColor];
    lbHp.colorBlendFactor = 0.5;
    lbHp.fontColor = [SKColor whiteColor];
    lbHp.position = CGPointMake(250,500);
    [self addChild:lbHp];
    

    
   
   // [self addChild:fireBack];
    
    joyStick = [[Joystick alloc]init];
    joyStick.position = CGPointMake(CGRectGetMidX(self.frame), 100);
    joyStick.delegate = self;
    joyStick.alpha = 0.6;
    joyStick.userInteractionEnabled = YES;
   // [self addChild:joyStick];
    
    [self addPlane];
    [self addFire];
    
    //边界
    SKPhysicsBody *body = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.scene.name = @"boundary";
    self.physicsBody = body;
    
    self.physicsBody.categoryBitMask = boundaryCategory;
    self.physicsBody.collisionBitMask = planeCategory;
    self.physicsBody.contactTestBitMask = planeCategory;
    

    
}
-(void) addFire
{
    fireNode = [[SKNode alloc]init];
    NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"fire" ofType:@"sks"];
    SKEmitterNode *fire = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
    // fire.position = CGPointMake(150, 300);
    fire.particleBlendMode = SKBlendModeAdd;
    fire.zPosition = 1;
    fire.name = @"fireFront";
    
    SKNode *fireFront = [SKNode new];
    fireFront.zPosition = 10;
    [self addChild:fireFront];
    fire.targetNode = fireFront;
    
    spaceship.zPosition = 4;
    
    // [self addChild:fire];
    
    NSString *backPath = [[NSBundle mainBundle] pathForResource:@"fireBack" ofType:@"sks"];
    SKEmitterNode *fireBack = [NSKeyedUnarchiver unarchiveObjectWithFile:backPath];
    // fireBack.position = CGPointMake(150, 300);
    fireBack.zPosition = 9;
    fireBack.name = @"fireBack";
    [fireNode addChild:fireBack];
    [fireNode addChild:fire];
    SKNode *fireB = [SKNode new];
    fireB.zPosition = 1;
    [self addChild:fireB];
    fireBack.targetNode = fireB;
    
    [fireNode setScale:7];
    fireNode.position = CGPointMake(0, -plane.size.height*2.1);
    [plane addChild:fireNode];
    
}
-(void)addPlane
{
    plane = [[SKSpriteNode alloc]init];
   // plane.zRotation +=M_PI/2;
    plane.texture = [SKTexture textureWithImageNamed:@"Spaceship"];
    plane.size = CGSizeMake(200, 176);
    plane.position = CGPointMake(CGRectGetMidX(self.frame), 200);
    [plane setScale:0.2];

    plane.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:plane.size];
    CGMutablePathRef planePath = CGPathCreateMutable();
    CGPathMoveToPoint(planePath, nil, 0, plane.size.height/2);
    CGPathAddLineToPoint(planePath, nil, plane.size.width/2, -plane.size.height/2);
     CGPathAddLineToPoint(planePath, nil, -plane.size.width/2, -plane.size.height/2);
   //  CGPathAddLineToPoint(planePath, nil, 0, plane.size.height/2);
    CGPathCloseSubpath(planePath);
//    SKShapeNode *ball = [[SKShapeNode alloc] init];
//    ball.path = planePath;
//    ball.position = CGPointMake(200, 200);
//    ball.fillColor = [SKColor blueColor];
//    [self addChild:ball];
    plane.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:planePath];
    plane.physicsBody.dynamic = YES;
    plane.physicsBody.affectedByGravity = NO;
    plane.physicsBody.categoryBitMask = planeCategory;
    plane.physicsBody.collisionBitMask = boundaryCategory|spaceshipCategory;
    plane.physicsBody.contactTestBitMask = blockCategory |spaceshipCategory;
    
    SKAction * makeFire = [SKAction sequence:@ [
                                                 [SKAction performSelector:@selector(addBullet) onTarget:self],
                                                 [SKAction waitForDuration:0.20 withRange:0.15]
                                                 ]];
    [self runAction:[SKAction repeatActionForever:makeFire] withKey:@"addFire"];
    
    [self addChild:plane];
}

-(void)addBullet
{
    SKSpriteNode *fire1 = [[SKSpriteNode alloc] initWithColor:[SKColor redColor] size:CGSizeMake(7,7)];
    fire1.name = @"zidan";
    CGPoint planeP = [self convertPoint:plane.position fromNode:plane.parent];
    fire1.position = CGPointMake(planeP.x, planeP.y);
    fire1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:fire1.size];
    fire1.physicsBody.affectedByGravity = NO;
    fire1.physicsBody.categoryBitMask = bulletCategory;
    fire1.physicsBody.contactTestBitMask = blockCategory|spaceshipCategory ;
    fire1.physicsBody.collisionBitMask = spaceshipCategory;
    SKAction *move = [SKAction moveByX:cosf(plane.zRotation+M_PI/2)*480 y:sinf(plane.zRotation+M_PI/2)*480 duration:1];
    [self addChild:fire1];
    [fire1 runAction:move];
}

-(void)stickMoveWithVector:(CGVector)vector force:(double)force
{
   // NSLog(@"方向X:%f,Y:%f,力：%f",vector.dx,vector.dy,force);

   // SKAction *action = [SKAction moveBy:CGVectorMake(vector.dx*force*3, vector.dy*force*3) duration:force*3];
    targetVector = CGVectorMake(vector.dx*force*10, vector.dy*force*10);
    moveRequested = YES;
}
-(void)stickTouchUp
{
    //targetVector = CGVectorMake(0,0);
    moveRequested = NO;
}
- (void)update:(NSTimeInterval)currentTime
{
    CFTimeInterval timeSinceLast = currentTime - lastUpdateTimeInterval;
    lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0f / 60.0f;//kMinTimeInterval;
        lastUpdateTimeInterval = currentTime;

    }
    if (moveRequested) {
        [self faceTo:targetVector];
            [self moveTowards:targetVector withTimeInterval:timeSinceLast];
    }
}

- (void)moveTowards:(CGVector)vector withTimeInterval:(NSTimeInterval)timeInterval {

    CGFloat dt = characterSpeed * timeInterval;
    CGFloat distRemaining = hypotf(vector.dx, vector.dy);
    CGPoint character = plane.position;
    if (distRemaining < dt) {
        plane.position = CGPointMake(character.x+vector.dx, character.y+vector.dy);
    } else {
        CGFloat ang = atan2f(vector.dy, vector.dx);
        plane.position = CGPointMake(character.x + cosf(ang)*dt,
                                    character.y + sinf(ang)*dt);
    }
    //NSLog(@"planeX:%f,Y:%f",character.x,character.y);
    
}

- (CGFloat)faceTo:(CGVector)vector {
    CGFloat ang = atan2f(vector.dy, vector.dx);
    ang -=M_PI/2;
    SKAction *action = [SKAction rotateToAngle:ang duration:0];
    [plane runAction:action];
    SKEmitterNode *fireFront = (SKEmitterNode *)[fireNode childNodeWithName:@"fireFront"];
    fireFront.emissionAngle = ang-M_PI/2;
    SKEmitterNode *fireBack = (SKEmitterNode *)[fireNode childNodeWithName:@"fireBack"];
    fireBack.emissionAngle = ang-M_PI/2;
     NSLog(@"plane角度：%f",plane.zRotation);
    return ang;
}

-(SKSpriteNode *)newSpaceShip
{
    SKSpriteNode *hull = [[SKSpriteNode alloc]initWithColor:[SKColor grayColor] size:CGSizeMake(64, 32)];
    SKAction *hover = [SKAction sequence:@[
                                    [SKAction waitForDuration:1.0],
                                    [SKAction moveByX:100 y:50 duration:1],
                                    [SKAction waitForDuration:1.0],
                                    [SKAction moveByX:-100 y:-50 duration:1.0]
                                           ]];
   // [hull runAction:[SKAction repeatActionForever:hover]];
    
    SKSpriteNode *light1 = [self newLight];
    light1.position = CGPointMake(-28, 6);
    [hull addChild:light1];
    SKSpriteNode *light2 = [self newLight];
    light2.position = CGPointMake(28, 6);
    [hull addChild:light2];
    
    hull.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hull.size];
    hull.physicsBody.friction = 0.5;
    //hull.physicsBody.mass = 1;
    hull.physicsBody.density = 20;
    //hull.physicsBody.restitution = 1.f;
    hull.physicsBody.dynamic = NO;
  //  hull.physicsBody.affectedByGravity = NO;
    hull.physicsBody.linearDamping = 0.8f;
    hull.zPosition = 1;
    NSLog(@"blendMode:%d",hull.blendMode);
   // hull.blendMode = SKBlendModeAdd;

    hull.physicsBody.categoryBitMask = spaceshipCategory;
    hull.physicsBody.contactTestBitMask = bulletCategory ;
//    hull.physicsBody.collisionBitMask = blockCategory;
   // hull.physicsBody.linearDamping = 1.f;
    return hull;
    
    
}

-(SKSpriteNode *)newLight
{
    SKSpriteNode * light = [[SKSpriteNode alloc]initWithColor:[SKColor yellowColor] size:CGSizeMake(8, 8)];
    SKAction *blink = [SKAction sequence:@[
                                        [SKAction fadeOutWithDuration:0.25],
                                        [SKAction fadeInWithDuration:0.25]
                                           ]];
    [light runAction:[SKAction repeatActionForever:blink]];
    return light;
}

static inline CGFloat skRandf() {
    return rand()/(CGFloat)RAND_MAX;
}
static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf()*(high - low) + low;
}

- (void)addRock
{
    float speed = skRand(1, 15);
    float size;
    if(speed<5) size = 10;
    else if(speed <10) size = 20;
    else if (speed <=15) size =30;
    
    SKSpriteNode *rock = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor] size:CGSizeMake(size,size)];
    rock.position = CGPointMake(skRand(0, self.size.width),self.size.height-50);
   // rock.position = CGPointMake(10,self.size.height-50);

    rock.name = @"rock";
    rock.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rock.size];
   // rock.physicsBody.usesPreciseCollisionDetection = YES;
    rock.physicsBody.friction = 0.5;
//    rock.physicsBody.mass = 0.1;
    rock.physicsBody.categoryBitMask = blockCategory;
    rock.physicsBody.contactTestBitMask =   planeCategory;
    rock.physicsBody.collisionBitMask = spaceshipCategory | blockCategory |planeCategory;
    rock.physicsBody.density = 20;
    rock.physicsBody.friction = 10000;
    rock.physicsBody.linearDamping = speed;
  //  rock.physicsBody.angularDamping= 1.f;
    rock.zPosition = 2;
    
   // rock.speed = 0.1;
    [self addChild:rock];
    
}

-(void)didSimulatePhysics
{
    [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop){
        if(node.position.y<0)
            [node removeFromParent];
    }];
    
    
    [self enumerateChildNodesWithName:@"zidan" usingBlock:^(SKNode *node, BOOL *stop){
        CGSize device = [UIScreen mainScreen].bounds.size;
        if(node.position.y<0 || node.position.x<0 ||node.position.y>device.height|| node.position.x>device.width )
            [node removeFromParent];
    }];
}

-(void) spaceship:(SKNode*)spaceshipC didCollideWithBlock:(SKSpriteNode*)block
{
//    NSLog(@"Hit");
//    SKPhysicsJointSliding *slide = [SKPhysicsJointSliding jointWithBodyA:spaceshipC.physicsBody bodyB:block.physicsBody anchor:spaceshipC.position axis:CGVectorMake(1, 1)];
//    [self.physicsWorld addJoint:slide];
    //[block removeFromParent];
  //  [block removeFromParent];
  //  [spaceshipC addChild:block];
   // SKPhysicsJointFixed *fix = [SKPhysicsJointFixed jointWithBodyA:spaceship.physicsBody bodyB:block.physicsBody anchor:CGPointMake(block.position.x, block.position.y+block.size.height/2)];
   // [self.physicsWorld addJoint:fix];
    scole ++;
    lbScole.text = [NSString stringWithFormat:@"%d",scole];
    block.physicsBody = nil;
    
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody,*secondBody;
    if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & blockCategory) != 0 &&
        (secondBody.categoryBitMask & bulletCategory) != 0)
    {
        SKSpriteNode *block = (SKSpriteNode *)firstBody.node;
        if(block.size.width >0)
        {
            CGSize blockSize = block.size;
            block.size = CGSizeMake(blockSize.width-10, blockSize.height-10);
            if(block.size.width <=0)
            {
                scole ++;
                NSLog(@"分数：%d",scole);
                [firstBody.node removeFromParent];
                lbScole.text = [NSString stringWithFormat:@"分数：%d",scole];
            }
        }

        [secondBody.node removeFromParent];
    }
    
    if ((firstBody.categoryBitMask & spaceshipCategory) != 0 &&
        (secondBody.categoryBitMask & bulletCategory) != 0)
    {
       
        [secondBody.node removeFromParent];
    }
    
    if ((firstBody.categoryBitMask & blockCategory) != 0 &&
        (secondBody.categoryBitMask & planeCategory) != 0)
    {
        SKSpriteNode *block = (SKSpriteNode *)firstBody.node;
        if(hp - (int)block.size.height <=0)
        {
            [secondBody.node removeFromParent];
            lbHp.text = @"游戏结束";
            [self removeActionForKey:@"addFire"];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            [btn setTitle:@"重新开始" forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor whiteColor]];
            btn.frame = CGRectMake(100, 350, 120, 30);
            [btn addTarget:self action:@selector(rePlay:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:btn];
            return;
        }
        hp -= (int)block.size.height;
        lbHp.text = [NSString stringWithFormat:@"HP：%d",hp];
        
        SKAction *pulseRed= [SKAction sequence:@[
                    [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1 duration:0.15],
                    [SKAction waitForDuration:0.1],
                    [SKAction colorizeWithColorBlendFactor:0 duration:0.15]]];[secondBody.node runAction:pulseRed];
                                                 
        [firstBody.node removeFromParent];
    }
    
}

-(void)rePlay:(UIButton*)btn
{
    scole = 0;
    hp = 100;
    [btn removeFromSuperview];
    lbScole.text = @"分数：0";
    lbHp.text = @"HP：100";
    [self addPlane];
    [self addFire];
}
@end
