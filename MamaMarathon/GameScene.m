//
//  GameScene.m
//  MamaMarathon
//
//  Created by Илья on 01.04.17.
//  Copyright © 2017 Ilya Biltuev. All rights reserved.
//

#import "GameScene.h"
#import "Background.h"

//Physics bodies collisions and contact bitMasks
static const uint32_t mamaCategory =  0x1 << 0;
static const uint32_t runnersCategory =  0x1 << 1;
static const uint32_t itemsCategory =  0x1 << 2;
static const uint32_t bordersCategory =  0x1 << 3;

@implementation GameScene {
    
    //screen size
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGSize screenCell;
    CGFloat HUDheightProperty;
    
    //for update method
    NSTimeInterval _lastUpdateTimeInterval;
    NSTimeInterval _timeSinceLast;
    
    //background
    Background *_firstBackground;
    Background *_secondBackground;
    Background *_thirdBackground;
    
    //Objects
    SKSpriteNode *_pickupWithMama;
    SKSpriteNode *_runner;
    
    //GAME MECHANIC
    NSInteger _backgroundMoveSpeed; //было 250 //define the background move speed in pixels per frame.
}

- (void)didMoveToView:(SKView *)view {
    
    //Get screen size to use later
    screenWidth = view.bounds.size.width;
    screenHeight = view.bounds.size.height;
    screenCell = CGSizeMake(screenWidth/10, screenWidth/10);
    NSLog(@"\n\nscreenCell = (%f, %f)\n\n", screenCell.width, screenCell.height);
    
    //назначаем скорость движения
    _backgroundMoveSpeed = 300;
    
    [self addHUD];
    [self addBackgrounds];
    [self addBorders];
    [self addPickupWithMama];
    [self addRunners];
}

#pragma mark - Add objects on scene
- (void)addHUD {

    //create main HUD node
    CGFloat HUDheight = screenHeight / 6 * 1.2;
    HUDheightProperty = HUDheight;
    
    SKSpriteNode *HUDnode = [SKSpriteNode spriteNodeWithColor:[SKColor lightGrayColor] size:CGSizeMake(screenWidth, HUDheight)];
    HUDnode.anchorPoint = CGPointZero;
    HUDnode.position = CGPointZero;
    HUDnode.zPosition = 10;
    [self addChild:HUDnode];
    
    //create itemsBar on HUD node
    SKSpriteNode *itemsBar = [SKSpriteNode spriteNodeWithColor:[SKColor darkGrayColor] size:CGSizeMake(screenWidth, screenHeight / 6)];
    itemsBar.anchorPoint = CGPointZero;
    itemsBar.position = CGPointZero;
    itemsBar.zPosition = 11;
    [HUDnode addChild:itemsBar];
    
    //create distanceBar on HUD node
    CGFloat distanceBarHeight = HUDnode.size.height - itemsBar.size.height;
    SKSpriteNode *distanceBar = [SKSpriteNode spriteNodeWithColor:[SKColor yellowColor] size:CGSizeMake(screenWidth, distanceBarHeight)];
    distanceBar.anchorPoint =CGPointZero;
    distanceBar.position = CGPointMake(0, itemsBar.size.height);
    distanceBar.zPosition = 11;
    [HUDnode addChild:distanceBar];
}

- (void)addBackgrounds{

    CGSize backgroundSize = CGSizeMake(screenWidth, screenHeight - HUDheightProperty);
    
    //FIRST BACKGROUND
    Background *firstBackground = [Background generateNewBackground];
    firstBackground.size = backgroundSize;
    firstBackground.position = CGPointZero;
    firstBackground.name = @"first background";
    
    _firstBackground = firstBackground;
    [self addChild:_firstBackground];
    NSLog(@"first background node created");
    
    //SECOND BACKGROUND
    Background *secondBackground = [Background generateNewBackground];
    secondBackground.size = backgroundSize;
    secondBackground.position = CGPointMake(0, firstBackground.position.y - backgroundSize.height);
    secondBackground.name = @"second background";
    
    _secondBackground = secondBackground;
    [self addChild:_secondBackground];
    NSLog(@"second background node created");
    
    //THIRD BACKGROUND
    Background *thirdBackground = [Background generateNewBackground];
    thirdBackground.size = backgroundSize;
    thirdBackground.position = CGPointMake(0, secondBackground.position.y - backgroundSize.height);
    thirdBackground.name = @"third background";
    
    _thirdBackground = thirdBackground;
    [self addChild:_thirdBackground];
    NSLog(@"third background node created");
}

- (void)addBorders {

    CGFloat bottomForBorder = screenHeight * 3;
    CGFloat heightForBorder = screenHeight * 6;
    CGRect bordersRect = CGRectMake(0, - bottomForBorder, screenWidth, heightForBorder);
    SKPhysicsBody *borders = [SKPhysicsBody bodyWithEdgeLoopFromRect:bordersRect];
    
    borders.categoryBitMask = bordersCategory;
    borders.collisionBitMask = itemsCategory | runnersCategory;
    borders.contactTestBitMask = 0;
    
    self.physicsBody = borders;
}

- (void)addPickupWithMama {

    //add pickup
    SKSpriteNode *pickup = [SKSpriteNode spriteNodeWithImageNamed:@"pickup 2.png"];
    pickup.anchorPoint = CGPointMake(0.5, 0.5);
    pickup.zPosition = 2;
    pickup.position = CGPointMake(screenWidth / 2, HUDheightProperty);
    _pickupWithMama = pickup;
    [self addChild:_pickupWithMama];
    
    //add mama on pickup
    SKSpriteNode *mama = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:screenCell];
    mama.anchorPoint = CGPointMake(0.5,0.5);
    mama.position = CGPointMake(0, screenCell.height);
    mama.zPosition = 3;
    //mama.position
    [_pickupWithMama addChild:mama];
}

- (void)addRunners {

    SKSpriteNode *runner = [SKSpriteNode spriteNodeWithColor:[SKColor blueColor] size:screenCell];
    runner.anchorPoint = CGPointMake(0.5, 0.5);
    runner.zPosition = 2;
    runner.position = CGPointMake(screenWidth / 2, screenHeight - screenCell.height);
    runner.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:screenCell.width / 2];
    
    runner.physicsBody.affectedByGravity = NO;
    runner.physicsBody.allowsRotation = NO;
    runner.physicsBody.restitution = 0.0;
    runner.physicsBody.friction = 0.0;
    runner.physicsBody.dynamic = YES;
    
    runner.physicsBody.categoryBitMask = runnersCategory;
    runner.physicsBody.contactTestBitMask = itemsCategory;
    runner.physicsBody.collisionBitMask = runnersCategory | bordersCategory;
    
    _runner = runner;
    [self addChild:_runner];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark --- UPDATE METHOD
-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
    
    //calculation of time since last update to calculate the movement speed of background.
    _timeSinceLast = currentTime - _lastUpdateTimeInterval;
    _lastUpdateTimeInterval = currentTime;
    
    //if too much time passed since last update - sms, phone call etc.
    if (_timeSinceLast > 1) {
        _timeSinceLast = 1.0/ 60.0;
        _lastUpdateTimeInterval = currentTime;
    }

    //BACKGROUND MOVEMENT
    
    //1st background movement
    [self enumerateChildNodesWithName:_firstBackground.name usingBlock:^(SKNode *node, BOOL *stop) {
        //calculation of background move speed
        node.position = CGPointMake(node.position.x, node.position.y + _backgroundMoveSpeed * _timeSinceLast);
        
        //if background moves completely off the screen - put it on the top of three background nodes
        if (node.position.y > screenHeight * 1.5) {
            
            CGPoint bottomPosition = CGPointMake(_thirdBackground.position.x, _thirdBackground.position.y - _thirdBackground.size.height + 20);//пришлось отнимать по 10 чтобы не было видно стыков между каждыми 3мя картинками дороги
            node.position = bottomPosition;
            NSLog(@"\n\n FIRST NODE WAS PUT ON THE BOTTOM!\n\n");
        }}];
    
    //2nd background movement
    [self enumerateChildNodesWithName:_secondBackground.name usingBlock:^(SKNode *node, BOOL *stop) {
        //calculation of background move speed
        node.position = CGPointMake(node.position.x, node.position.y + _backgroundMoveSpeed * _timeSinceLast);
        
        //if background moves completely off the screen - put it on the top of three background nodes
        if (node.position.y > screenHeight * 1.5) {
            
            CGPoint bottomPosition = CGPointMake(_firstBackground.position.x, _firstBackground.position.y - _firstBackground.size.height + 20);//пришлось отнимать по 10 чтобы не было видно стыков между каждыми 3мя картинками дороги
            
            node.position = bottomPosition;
            NSLog(@"\n\n SECOND NODE WAS PUT ON THE BOTTOM!\n\n");
        }}];
    
    //3rd background movement
    [self enumerateChildNodesWithName:_thirdBackground.name usingBlock:^(SKNode *node, BOOL *stop) {
        //calculation of background move speed
        node.position = CGPointMake(node.position.x, node.position.y + _backgroundMoveSpeed * _timeSinceLast);
        
        //if background moves completely off the screen - put it on the top of three background nodes
        if (node.position.y > screenHeight * 1.5) {
            
            CGPoint bottomPosition = CGPointMake(_secondBackground.position.x, _secondBackground.position.y - _secondBackground.size.height + 20);//пришлось отнимать по 10 чтобы не было видно стыков между каждыми 3мя картинками дороги
            
            node.position = bottomPosition;
            NSLog(@"\n\n THIRD NODE WAS PUT ON THE BOTTOM!\n\n");
        }}];
}

@end
