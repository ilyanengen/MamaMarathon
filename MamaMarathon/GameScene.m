//
//  GameScene.m
//  MamaMarathon
//
//  Created by Илья on 01.04.17.
//  Copyright © 2017 Ilya Biltuev. All rights reserved.
//

#import "GameScene.h"
#import "Background.h"

@implementation GameScene {
    
    //screen size
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGSize screenCell;
    
    //for update method
    NSTimeInterval _lastUpdateTimeInterval;
    NSTimeInterval _timeSinceLast;
    
    //background
    Background *_firstBackground;
    Background *_secondBackground;
    Background *_thirdBackground;
    
    //GAME MECHANIC
    NSInteger _backgroundMoveSpeed; //было 250 //define the background move speed in pixels per frame.

}

- (void)didMoveToView:(SKView *)view {
    
    //Get screen size to use later
    screenWidth = view.bounds.size.width;
    screenHeight = view.bounds.size.height;
    screenCell = CGSizeMake(screenWidth/6, screenWidth/6);
    NSLog(@"\n\nscreenCell = (%f, %f)\n\n", screenCell.width, screenCell.height);
    
    //назначаем скорость движения
    _backgroundMoveSpeed = 300;
    
    [self addHUD];
    [self addBackgrounds];
}

#pragma mark - Add objects on scene
- (void)addHUD {

    //create main HUD node
    CGFloat HUDheight = screenHeight / 6 * 1.2;
    
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

#warning высота бэкграунда должна зависеть от высоты HUD'a
    CGSize backgroundSize = CGSizeMake(screenWidth, screenHeight);
    
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
    secondBackground.position = CGPointMake(0, firstBackground.position.y + backgroundSize.height);
    secondBackground.name = @"second background";
    
    _secondBackground = secondBackground;
    [self addChild:_secondBackground];
    NSLog(@"second background node created");
    
    //THIRD BACKGROUND
    Background *thirdBackground = [Background generateNewBackground];
    thirdBackground.size = backgroundSize;
    thirdBackground.position = CGPointMake(0, secondBackground.position.y + backgroundSize.height);
    thirdBackground.name = @"third background";
    
    _thirdBackground = thirdBackground;
    [self addChild:_thirdBackground];
    NSLog(@"third background node created");
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
        node.position = CGPointMake(node.position.x, node.position.y - _backgroundMoveSpeed * _timeSinceLast);
        
        //if background moves completely off the screen - put it on the top of three background nodes
        if (node.position.y < -(screenHeight * 1.5)) {
            
            CGPoint topPosition = CGPointMake(_thirdBackground.position.x, _thirdBackground.position.y + _thirdBackground.size.height - 20);//пришлось отнимать по 10 чтобы не было видно стыков между каждыми 3мя картинками дороги
            node.position = topPosition;
            NSLog(@"\n\n FIRST NODE WAS PUT ON THE TOP!\n\n");
        }}];
    
    //2nd background movement
    [self enumerateChildNodesWithName:_secondBackground.name usingBlock:^(SKNode *node, BOOL *stop) {
        //calculation of background move speed
        node.position = CGPointMake(node.position.x, node.position.y - _backgroundMoveSpeed * _timeSinceLast);
        
        //if background moves completely off the screen - put it on the top of three background nodes
        if (node.position.y < -(screenHeight * 1.5)) {
            
            CGPoint topPosition = CGPointMake(_firstBackground.position.x, _firstBackground.position.y + _firstBackground.size.height - 20);//пришлось отнимать по 10 чтобы не было видно стыков между каждыми 3мя картинками дороги
            
            node.position = topPosition;
            NSLog(@"\n\n SECOND NODE WAS PUT ON THE TOP!\n\n");
        }}];
    
    //3rd background movement
    [self enumerateChildNodesWithName:_thirdBackground.name usingBlock:^(SKNode *node, BOOL *stop) {
        //calculation of background move speed
        node.position = CGPointMake(node.position.x, node.position.y - _backgroundMoveSpeed * _timeSinceLast);
        
        //if background moves completely off the screen - put it on the top of three background nodes
        if (node.position.y < -(screenHeight * 1.5)) {
            
            CGPoint topPosition = CGPointMake(_secondBackground.position.x, _secondBackground.position.y + _secondBackground.size.height - 20);//пришлось отнимать по 10 чтобы не было видно стыков между каждыми 3мя картинками дороги
            
            node.position = topPosition;
            NSLog(@"\n\n THIRD NODE WAS PUT ON THE TOP!\n\n");
        }}];
}

@end
