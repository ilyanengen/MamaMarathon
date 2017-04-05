//
//  GameScene.m
//  MamaMarathon
//
//  Created by Илья on 01.04.17.
//  Copyright © 2017 Ilya Biltuev. All rights reserved.
//

#import "GameScene.h"
#import "Background.h"

typedef NS_ENUM(NSUInteger, mamaSelectedItem) {
    mamaSelectedItemBanana = 1,
    mamaSelectedItemOil = 2,
    mamaSelectedItemWater = 3,
    mamaSelectedItemHamburger = 4
};

//Physics bodies collisions and contact bitMasks
static const uint32_t pickupWithMamaCategory =  0x1 << 0;
static const uint32_t runnersCategory =  0x1 << 1;
static const uint32_t itemsCategory =  0x1 << 2;
static const uint32_t bordersCategory =  0x1 << 3;

static const NSTimeInterval runnerAnimationDuration = 0.18;
static const NSTimeInterval sonAnimationDuration = 0.25;

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
    SKSpriteNode *_son;
    NSMutableArray *_runnersArray;
    
    //HUD
    SKSpriteNode *_itemsBar;
    //Buttons
    SKSpriteNode *_bananaButton;
    SKSpriteNode *_oilButton;
    SKSpriteNode *_waterButton;
    SKSpriteNode *_hamburgerButton;
    
    //GAME MECHANIC
    NSInteger _backgroundMoveSpeed; //define the background move speed in pixels per frame.
    NSInteger _iterationCount; //+1 on every 3rd background
    
    BOOL _mamaThrewItem;
    BOOL _gameIsOver;
    SKNode *_mamaPushedButton;
    mamaSelectedItem selectedItem;
#warning ИСПОЛЬЗОВАТЬ ЭТИ айвары чтобы запрограммировать поведение бегунов
    SKSpriteNode *_runnersShouldAvoidItem;
    SKSpriteNode *_runnersShouldCatchItem;
    
}

- (void)didMoveToView:(SKView *)view {
    
    self.physicsWorld.contactDelegate = self;
    
    //Get screen size to use later
    screenWidth = view.bounds.size.width;
    screenHeight = view.bounds.size.height;
    screenCell = CGSizeMake(screenWidth/10, screenWidth/10);
    NSLog(@"\n\nscreenCell = (%f, %f)\n\n", screenCell.width, screenCell.height);
    
    //назначаем скорость движения
    _backgroundMoveSpeed = 300;
    
    //устанавливаем начальный статус
    _mamaThrewItem = NO;
    _mamaPushedButton = nil;
    _gameIsOver = NO;
    
    //добавляем объекты на сцену
    [self addRunners];
    [self addHUD];
    [self addBackgrounds];
    [self addBorders];
    [self addPickupWithMama];
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
    itemsBar.anchorPoint = CGPointMake(0.5, 0.5);
    itemsBar.position = CGPointMake(screenWidth / 2, itemsBar.size.height / 2);
    itemsBar.zPosition = 11;
    _itemsBar = itemsBar;
    [HUDnode addChild:_itemsBar];
    
    //create distanceBar on HUD node
    CGFloat distanceBarHeight = HUDnode.size.height - _itemsBar.size.height;
    SKSpriteNode *distanceBar = [SKSpriteNode spriteNodeWithColor:[SKColor yellowColor] size:CGSizeMake(screenWidth, distanceBarHeight)];
    distanceBar.anchorPoint =CGPointZero;
    distanceBar.position = CGPointMake(0, _itemsBar.size.height);
    distanceBar.zPosition = 11;
    [HUDnode addChild:distanceBar];
    
    //BUTTONS on itemsBar
    [self addButtons];
    }

- (void)addButtons {

    CGSize buttonSize = CGSizeMake(screenCell.width * 2, screenCell.height * 2);
    //banana button
    
    SKSpriteNode *bananaButton = [SKSpriteNode spriteNodeWithColor:[SKColor lightGrayColor]
                                                              size:buttonSize];
    bananaButton.zPosition = 12;
    bananaButton.anchorPoint = CGPointMake(0.5, 0.5);
    bananaButton.position = CGPointMake(-(screenWidth / 8 * 3), 0);
    _bananaButton = bananaButton;
    [_itemsBar addChild:_bananaButton];
    SKSpriteNode *bananaImageOnButton = [SKSpriteNode spriteNodeWithImageNamed:@"banana64.png"];
    bananaImageOnButton.name = @"bananaButton";
    [_bananaButton addChild:bananaImageOnButton];
    
    //oil button
    SKSpriteNode *oilButton = [SKSpriteNode spriteNodeWithColor:[SKColor lightGrayColor]
                                                           size:buttonSize];
    oilButton.zPosition = 12;
    oilButton.anchorPoint = CGPointMake(0.5, 0.5);
    oilButton.position = CGPointMake(- screenWidth / 8, 0);
    _oilButton = oilButton;
    [_itemsBar addChild:_oilButton];
    SKSpriteNode *oilImageOnButton = [SKSpriteNode spriteNodeWithImageNamed:@"oil64.png"];
    oilImageOnButton.name = @"oilButton";
    [_oilButton addChild:oilImageOnButton];
    
    //water button
    SKSpriteNode *waterButton = [SKSpriteNode spriteNodeWithColor:[SKColor lightGrayColor]
                                                             size:buttonSize];
    waterButton.zPosition = 12;
    waterButton.anchorPoint = CGPointMake(0.5, 0.5);
    waterButton.position = CGPointMake(screenWidth / 8 , 0);
    _waterButton = waterButton;
    [_itemsBar addChild:_waterButton];
    SKSpriteNode *waterImageOnButton = [SKSpriteNode spriteNodeWithImageNamed:@"water64.png"];
    waterImageOnButton.name = @"waterButton";
    [_waterButton addChild:waterImageOnButton];
    
    //hamburger button
    SKSpriteNode *hamburgerButton = [SKSpriteNode spriteNodeWithColor:[SKColor lightGrayColor]
                                                                 size:buttonSize];
    hamburgerButton.zPosition = 12;
    hamburgerButton.anchorPoint = CGPointMake(0.5, 0.5);
    hamburgerButton.position = CGPointMake(screenWidth / 8 * 3, 0);
    _hamburgerButton = hamburgerButton;
    [_itemsBar addChild:_hamburgerButton];
    SKSpriteNode *hamburgerImageOnButton = [SKSpriteNode spriteNodeWithImageNamed:@"hamburger64.png"];
    hamburgerImageOnButton.name = @"hamburgerButton";
    [_hamburgerButton addChild:hamburgerImageOnButton];
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
    
    pickup.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pickup.size];
    pickup.physicsBody.affectedByGravity = NO;
    pickup.physicsBody.allowsRotation = NO;
    pickup.physicsBody.restitution = 0.0;
    pickup.physicsBody.friction = 0.0;
    pickup.physicsBody.dynamic = YES;
    
    pickup.physicsBody.categoryBitMask = pickupWithMamaCategory;
    pickup.physicsBody.collisionBitMask = runnersCategory | bordersCategory;

    _pickupWithMama = pickup;
    [self addChild:_pickupWithMama];
    
    //add mama on pickup
    SKSpriteNode *mama = [SKSpriteNode spriteNodeWithImageNamed:@"mama.png"];
    mama.anchorPoint = CGPointMake(0.5,0.5);
    mama.position = CGPointMake(0, screenCell.height);
    mama.zPosition = 3;
    [_pickupWithMama addChild:mama];
}

- (void)addRunners {

    _runnersArray = [NSMutableArray array];
    
    //создаем анимацию для бегунов
    SKTexture *runnerTexture1 = [SKTexture textureWithImageNamed:@"runner1.png"];
    SKTexture *runnerTexture2 = [SKTexture textureWithImageNamed:@"runner2.png"];
    NSArray *runnerTextures = [NSArray arrayWithObjects:runnerTexture1,runnerTexture2, nil];
    SKAction *runnerAnimationAction = [SKAction animateWithTextures:runnerTextures timePerFrame:runnerAnimationDuration];
    
    //создаем анимацию для сыночка
    SKTexture *sonTexture1 = [SKTexture textureWithImageNamed:@"son1.png"];
    SKTexture *sonTexture2 = [SKTexture textureWithImageNamed:@"son2.png"];
    NSArray *sonTextures = [NSArray arrayWithObjects:sonTexture1,sonTexture2, nil];
    SKAction *sonAnimationAction = [SKAction animateWithTextures:sonTextures timePerFrame:sonAnimationDuration];
    
    //создаем бегунов и добавляем в массив
    for (int i; i < 10; i++) {
        SKSpriteNode *runner = [SKSpriteNode spriteNodeWithColor:[SKColor blueColor] size:screenCell];
        runner.name = @"runner";
        runner.anchorPoint = CGPointMake(0.5, 0.5);
        runner.zPosition = 2;
        runner.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:screenCell.width / 2];
        runner.physicsBody.affectedByGravity = NO;
        runner.physicsBody.allowsRotation = NO;
        runner.physicsBody.restitution = 0.0;
        runner.physicsBody.friction = 0.0;
        runner.physicsBody.dynamic = YES;
        
        runner.physicsBody.categoryBitMask = runnersCategory;
        runner.physicsBody.contactTestBitMask = itemsCategory;
        runner.physicsBody.collisionBitMask = runnersCategory | bordersCategory | pickupWithMamaCategory;
        
        [self addChild:runner];
        [_runnersArray addObject:runner];
        NSLog(@"RunnersArray COUNT = %ld", [_runnersArray count]);
    }
    
    //Расставляем бегунов
    [_runnersArray[0] setPosition:CGPointMake(screenCell.width / 2, screenHeight - screenCell.height * 1.5)];
    [_runnersArray[1] setPosition:CGPointMake(screenCell.width * 1.5, screenHeight - screenCell.height * 2.5)];
    [_runnersArray[2] setPosition:CGPointMake(screenCell.width * 2.5, screenHeight - screenCell.height * 1.5)];
    [_runnersArray[3] setPosition:CGPointMake(screenCell.width * 3.5, screenHeight - screenCell.height * 2.5)];
    [_runnersArray[4] setPosition:CGPointMake(screenCell.width * 4.5, screenHeight - screenCell.height * 1.5)];
    [_runnersArray[5] setPosition:CGPointMake(screenCell.width * 5.5, screenHeight - screenCell.height * 2.5)];
    [_runnersArray[6] setPosition:CGPointMake(screenCell.width * 6.5, screenHeight - screenCell.height * 1.5)];
    [_runnersArray[7] setPosition:CGPointMake(screenCell.width * 7.5, screenHeight - screenCell.height * 2.5)];
    [_runnersArray[8] setPosition:CGPointMake(screenCell.width * 8.5, screenHeight - screenCell.height * 1.5)];
    [_runnersArray[9] setPosition:CGPointMake(screenCell.width * 9.5, screenHeight - screenCell.height * 2.5)];
    
    //Анимируем бегунов
    [_runnersArray[0] runAction:[SKAction repeatActionForever:runnerAnimationAction]];
    [_runnersArray[1] runAction:[SKAction repeatActionForever:runnerAnimationAction]];
    [_runnersArray[2] runAction:[SKAction repeatActionForever:runnerAnimationAction]];
    [_runnersArray[3] runAction:[SKAction repeatActionForever:runnerAnimationAction]];
    [_runnersArray[4] runAction:[SKAction repeatActionForever:runnerAnimationAction]];
    [_runnersArray[6] runAction:[SKAction repeatActionForever:runnerAnimationAction]];
    [_runnersArray[7] runAction:[SKAction repeatActionForever:runnerAnimationAction]];
    [_runnersArray[8] runAction:[SKAction repeatActionForever:runnerAnimationAction]];
    [_runnersArray[9] runAction:[SKAction repeatActionForever:runnerAnimationAction]];
    
    //Выделяем сыночка из остальных бегунов
    [_runnersArray[5] setName:@"son"];
    [_runnersArray[5] runAction:[SKAction repeatActionForever:sonAnimationAction]];
    _son = _runnersArray[5];
}

#pragma mark - ITEMS OF MAMA
- (SKSpriteNode *)createBanana {

    SKSpriteNode *bananaNode = [SKSpriteNode spriteNodeWithImageNamed:@"banana32.png"];
    bananaNode.name = @"banana";
    bananaNode.zPosition = 2;
    bananaNode.anchorPoint = CGPointMake(0.5, 0.5);
    
    bananaNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: bananaNode.size.width / 2];
    bananaNode.physicsBody.affectedByGravity = NO;
    bananaNode.physicsBody.allowsRotation = YES;
    bananaNode.physicsBody.restitution = 0.0;
    bananaNode.physicsBody.friction = 0.0;
    bananaNode.physicsBody.dynamic = YES;
    
    bananaNode.physicsBody.categoryBitMask = itemsCategory;
    bananaNode.physicsBody.contactTestBitMask = runnersCategory;
    bananaNode.physicsBody.collisionBitMask = bordersCategory;
    
    return bananaNode;
}

- (SKSpriteNode *)createOil {

    SKSpriteNode *oilNode = [SKSpriteNode spriteNodeWithImageNamed:@"oil64.png"];
    oilNode.name = @"oil";
    oilNode.zPosition = 2;
    oilNode.anchorPoint = CGPointMake(0.5, 0.5);
    
    oilNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: oilNode.size.width / 2];
    oilNode.physicsBody.affectedByGravity = NO;
    oilNode.physicsBody.allowsRotation = YES;
    oilNode.physicsBody.restitution = 0.0;
    oilNode.physicsBody.friction = 0.0;
    oilNode.physicsBody.dynamic = YES;
    
    oilNode.physicsBody.categoryBitMask = itemsCategory;
    oilNode.physicsBody.contactTestBitMask = runnersCategory;
    oilNode.physicsBody.collisionBitMask = bordersCategory;
    
    return oilNode;
}

- (SKSpriteNode *)createWater {

    SKSpriteNode *waterNode = [SKSpriteNode spriteNodeWithImageNamed:@"water32.png"];
    waterNode.name = @"water";
    waterNode.zPosition = 2;
    waterNode.anchorPoint = CGPointMake(0.5, 0.5);
    
    waterNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: waterNode.size.width / 2];
    waterNode.physicsBody.affectedByGravity = NO;
    waterNode.physicsBody.allowsRotation = YES;
    waterNode.physicsBody.restitution = 0.0;
    waterNode.physicsBody.friction = 0.0;
    waterNode.physicsBody.dynamic = YES;
    
    waterNode.physicsBody.categoryBitMask = itemsCategory;
    waterNode.physicsBody.contactTestBitMask = runnersCategory;
    waterNode.physicsBody.collisionBitMask = bordersCategory;
    
    return waterNode;
}

- (SKSpriteNode *)createHamburger {

    SKSpriteNode *hamburgerNode = [SKSpriteNode spriteNodeWithImageNamed:@"hamburger32.png"];
    hamburgerNode.name = @"hamburger";
    hamburgerNode.zPosition = 2;
    hamburgerNode.anchorPoint = CGPointMake(0.5, 0.5);
    
    hamburgerNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius: hamburgerNode.size.width / 2];
    hamburgerNode.physicsBody.affectedByGravity = NO;
    hamburgerNode.physicsBody.allowsRotation = YES;
    hamburgerNode.physicsBody.restitution = 0.0;
    hamburgerNode.physicsBody.friction = 0.0;
    hamburgerNode.physicsBody.dynamic = YES;
    
    hamburgerNode.physicsBody.categoryBitMask = itemsCategory;
    hamburgerNode.physicsBody.contactTestBitMask = runnersCategory;
    hamburgerNode.physicsBody.collisionBitMask = bordersCategory;
    
    return hamburgerNode;
}

#pragma mark --- GAME LOGIC
- (void)iterationCounterPlusOne {

    _iterationCount = _iterationCount + 1;
    NSLog(@"iteration count = %ld", _iterationCount);
}

- (void)changeDirectionOfrunner: (SKSpriteNode*)runner {

    SKAction *runnerMoveAction = [[SKAction alloc]init];
    NSTimeInterval runnerChangeDirectionDuration = 3;
    
    int randomNumber = arc4random_uniform(4);//будет рандомное значение 0, 1, 2, 3
    
    switch (randomNumber) {
        case 0:
            //NSLog(@"change direction of runner: UP");
            runnerMoveAction = [SKAction moveByX:0
                                               y:+screenCell.height/10
                                        duration:runnerChangeDirectionDuration];
            break;
        case 1:
            //NSLog(@"change direction of runner: RIGHT");
            runnerMoveAction = [SKAction moveByX:+screenCell.width/10
                                               y:0
                                        duration:runnerChangeDirectionDuration];
            break;
        case 2:
            //NSLog(@"change direction of runner: DOWN");
            runnerMoveAction = [SKAction moveByX:0
                                               y:-screenCell.height/10
                                        duration:runnerChangeDirectionDuration];
            break;
        case 3:
            //NSLog(@"change direction of runner: LEFT");
            runnerMoveAction = [SKAction moveByX:-screenCell.width/10
                                               y:0
                                        duration:runnerChangeDirectionDuration];
            break;
    }
    [runner runAction:runnerMoveAction];
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

    //Бегуны бегают в рандомных направлениях
        for (SKSpriteNode *runner in _runnersArray) {
            [self changeDirectionOfrunner:runner];
            
            if ((![runner.name isEqualToString:@"son"]) && (runner.position.y < -screenCell.height * 1.5) && (!_gameIsOver)) {
                [self gameOver];
            }
    }
    
    //Если сынок ушел за экран сверху -gameOver
    if ((_son != nil) && (_son.position.y > screenHeight + _son.size.height * 1.2) && (!_gameIsOver)) {
        [self gameOver];
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
            
            //+1 to iterationCounter
            [self iterationCounterPlusOne];
        }}];
}

#pragma mark - TOUCHES
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"bananaButton"]) {
        [self fadeInFadeOutNode:node];
        selectedItem = mamaSelectedItemBanana;
        
    } else if ([node.name isEqualToString:@"oilButton"]) {
        [self fadeInFadeOutNode:node];
        selectedItem = mamaSelectedItemOil;
        
    } else if ([node.name isEqualToString:@"waterButton"]) {
        [self fadeInFadeOutNode:node];
        selectedItem = mamaSelectedItemWater;
        
    } else if ([node.name isEqualToString:@"hamburgerButton"]) {
        [self fadeInFadeOutNode:node];
        selectedItem = mamaSelectedItemHamburger;
    
    } else if ((selectedItem > 0) &&
               (([node.name isEqualToString:@"first background"]) ||
                ([node.name isEqualToString:@"second background"]) ||
                ([node.name isEqualToString:@"third background"]))) {
    
        NSLog(@"\n\nPlayer selected item and touched one of the background nodes\n\n");
        [self mamaWillThrowSelectedItemToXPosition: location.x];
    } else {
        NSLog(@"Just usual touch. Nothing will happen");
    }
}

- (void)fadeInFadeOutNode:(SKNode *) node {

    SKAction *fadeOutAction = [SKAction fadeAlphaTo:0.3 duration:0.3];
    SKAction *fadeInAction = [SKAction fadeAlphaTo:1 duration:0.3];

    NSLog(@"\n\n%@ IS PRESSED!\n\n",node.name);
    if (_mamaPushedButton != nil) {
        [_mamaPushedButton runAction:fadeInAction];
        _mamaPushedButton = node;
        [node runAction:fadeOutAction];
    }else{
        _mamaPushedButton = node;
        [node runAction:fadeOutAction];
    }
}

- (void)mamaWillThrowSelectedItemToXPosition: (CGFloat)xPosition {

    SKSpriteNode *itemToThrow = [[SKSpriteNode alloc]init];
    
    switch (selectedItem) {
        case mamaSelectedItemBanana:
            itemToThrow = [self createBanana];
            break;
        case mamaSelectedItemOil:
            itemToThrow = [self createOil];
            break;
        case mamaSelectedItemWater:
            itemToThrow = [self createWater];
            break;
        case mamaSelectedItemHamburger:
            itemToThrow = [self createHamburger];
            break;
    }
    
    //start position
    itemToThrow.position = CGPointMake(_pickupWithMama.position.x, _pickupWithMama.position.y * 1.5);
    [self addChild:itemToThrow];
    //end position
    CGPoint endPosition = CGPointMake(xPosition, _pickupWithMama.position.y + _pickupWithMama.size.height * 0.75);
    //Throw Animation Action
    SKAction *throwAction = [SKAction moveTo:endPosition duration:0.5];
    [itemToThrow runAction:throwAction];

#warning Потестить! Поведение бегунов ---- дописать в методе update!!!
    //назначаем айвары, на которые будут реагировать бегуны
    if (([itemToThrow.name isEqualToString:@"banana"]) || ([itemToThrow.name isEqualToString:@"oil"]))  {
        _runnersShouldAvoidItem = itemToThrow;
    } else if (([itemToThrow.name isEqualToString:@"water"]) || ([itemToThrow.name isEqualToString:@"hamburger"])) {
        _runnersShouldCatchItem = itemToThrow;
    }
    
    //Going to Upper edge of screen
    NSTimeInterval timeInterval = (double)(screenHeight * 1.5 / _backgroundMoveSpeed);
    SKAction *goingUpAction = [SKAction moveBy:CGVectorMake(0, screenHeight * 1.5) duration:timeInterval];
    [itemToThrow runAction:goingUpAction completion:^{
        [itemToThrow removeFromParent]; //remove from parent after reaching performing action
    }];
}

#pragma mark - CONTACT DELEGATE
- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKNode *bodyANode = contact.bodyA.node;
    SKNode *bodyBNode = contact.bodyB.node;
    
    NSLog(@"\n\nCONTACT DELEGATE!!!!Body A: %@  Body B: %@\n\n",bodyANode.name, bodyBNode.name);
    
    //BANANA VS RUNNER
    if ([bodyANode.name isEqualToString:@"runner"] && [bodyBNode.name isEqualToString:@"banana"]) {
    
        [self fallDownOfRunner:bodyANode andItem:bodyBNode];
    }else if ([bodyANode.name isEqualToString:@"banana"] && [bodyBNode.name isEqualToString:@"runner"]) {
        
        [self fallDownOfRunner:bodyBNode andItem:bodyANode];
    } else if ([bodyANode.name isEqualToString:@"son"] && [bodyBNode.name isEqualToString:@"banana"]) {
    
        [self fallDownOfRunner:bodyANode andItem:bodyBNode];
    } else if ([bodyANode.name isEqualToString:@"banana"] && [bodyBNode.name isEqualToString:@"son"]) {
    
        [self fallDownOfRunner:bodyBNode andItem:bodyANode];
    }
    
    //OIL VS RUNNER
    if ([bodyANode.name isEqualToString:@"runner"] && [bodyBNode.name isEqualToString:@"oil"]) {
        
        [self fallDownOfRunner:bodyANode andItem:bodyBNode];
    }else if ([bodyANode.name isEqualToString:@"oil"] && [bodyBNode.name isEqualToString:@"runner"]) {
        
        [self fallDownOfRunner:bodyBNode andItem:bodyANode];
    } else if ([bodyANode.name isEqualToString:@"son"] && [bodyBNode.name isEqualToString:@"oil"]) {
        
        [self fallDownOfRunner:bodyANode andItem:bodyBNode];
    } else if ([bodyANode.name isEqualToString:@"oil"] && [bodyBNode.name isEqualToString:@"son"]) {
        
        [self fallDownOfRunner:bodyBNode andItem:bodyANode];
    }

    //WATER VS RUNNER
    if ([bodyANode.name isEqualToString:@"runner"] && [bodyBNode.name isEqualToString:@"water"]) {
        
        [self luckyRunner:bodyANode catchesItem:bodyBNode];
    }else if ([bodyANode.name isEqualToString:@"water"] && [bodyBNode.name isEqualToString:@"runner"]) {
        
        [self luckyRunner:bodyBNode catchesItem:bodyANode];
    } else if ([bodyANode.name isEqualToString:@"son"] && [bodyBNode.name isEqualToString:@"water"]) {
        
        [self luckyRunner:bodyANode catchesItem:bodyBNode];
    } else if ([bodyANode.name isEqualToString:@"water"] && [bodyBNode.name isEqualToString:@"son"]) {
        
        [self luckyRunner:bodyBNode catchesItem:bodyANode];
    }

    //HAMBURGER VS PLAYER
    if ([bodyANode.name isEqualToString:@"runner"] && [bodyBNode.name isEqualToString:@"hamburger"]) {
        
        [self luckyRunner:bodyANode catchesItem:bodyBNode];
    }else if ([bodyANode.name isEqualToString:@"hamburger"] && [bodyBNode.name isEqualToString:@"runner"]) {
        
        [self luckyRunner:bodyBNode catchesItem:bodyANode];
    } else if ([bodyANode.name isEqualToString:@"son"] && [bodyBNode.name isEqualToString:@"hamburger"]) {
        
        [self luckyRunner:bodyANode catchesItem:bodyBNode];
    } else if ([bodyANode.name isEqualToString:@"hamburger"] && [bodyBNode.name isEqualToString:@"son"]) {
        
        [self luckyRunner:bodyBNode catchesItem:bodyANode];
    }

    
}

#pragma mark - Contact consequences
- (void)fallDownOfRunner: (SKNode *) runner andItem: (SKNode *)item {

    if ([runner.name isEqualToString:@"runner"]) {
    
        SKAction *changeTexture = [SKAction setTexture:[SKTexture textureWithImageNamed:@"runner3.png"]];
        SKAction *moveUp = [SKAction moveByX:0 y:screenCell.height * 2 duration:screenCell.height * 2 / _backgroundMoveSpeed];
        
        SKTexture *runnerTexture1 = [SKTexture textureWithImageNamed:@"runner1.png"];
        SKTexture *runnerTexture2 = [SKTexture textureWithImageNamed:@"runner2.png"];
        NSArray *runnerTextures = [NSArray arrayWithObjects:runnerTexture1,runnerTexture2, nil];
        SKAction *runnerAnimationAction = [SKAction animateWithTextures:runnerTextures timePerFrame:runnerAnimationDuration];
        
        NSArray *sequenceOfActionsOfRunner = @[changeTexture, moveUp, runnerAnimationAction];
        
        [item removeFromParent];//удаляем айтем с вьюхи
        [runner runAction:[SKAction sequence:sequenceOfActionsOfRunner]];
        
    } else if ([runner.name isEqualToString:@"son"]){
    
        SKAction *changeTexture = [SKAction setTexture:[SKTexture textureWithImageNamed:@"son3.png"]];
        SKAction *moveUp = [SKAction moveByX:0 y:screenCell.height * 2 duration:screenCell.height * 2 / _backgroundMoveSpeed];
        
        SKTexture *runnerTexture1 = [SKTexture textureWithImageNamed:@"son1.png"];
        SKTexture *runnerTexture2 = [SKTexture textureWithImageNamed:@"son2.png"];
        NSArray *runnerTextures = [NSArray arrayWithObjects:runnerTexture1,runnerTexture2, nil];
        SKAction *runnerAnimationAction = [SKAction animateWithTextures:runnerTextures timePerFrame:sonAnimationDuration];
        
        NSArray *sequenceOfActionsOfRunner = @[changeTexture, moveUp, runnerAnimationAction];
        
        [item removeFromParent];//удаляем айтем с вьюхи
        [runner runAction:[SKAction sequence:sequenceOfActionsOfRunner]];
    } else {
        NSLog(@"ERROR! runner.name is strange!");
    }
}
               
- (void)luckyRunner: (SKNode *)runner catchesItem: (SKNode *)item {

    if ([runner.name isEqualToString:@"runner"]) {
        
        SKAction *moveDown = [[SKAction alloc]init];
        
        if ([item.name isEqualToString:@"hamburger"]) {
            moveDown = [SKAction moveByX:0 y:-screenCell.height duration:screenCell.height / _backgroundMoveSpeed];
        }else {
            moveDown = [SKAction moveByX:0 y:-screenCell.height / 2 duration:screenCell.height / _backgroundMoveSpeed];
        }
        
        SKTexture *runnerTexture1 = [SKTexture textureWithImageNamed:@"runner1.png"];
        SKTexture *runnerTexture2 = [SKTexture textureWithImageNamed:@"runner2.png"];
        NSArray *runnerTextures = [NSArray arrayWithObjects:runnerTexture1,runnerTexture2, nil];
        SKAction *runnerAnimationAction = [SKAction animateWithTextures:runnerTextures timePerFrame:runnerAnimationDuration];
        
        NSArray *groupOfActionsOfRunner = @[moveDown, runnerAnimationAction];
        
        [item removeFromParent];//удаляем айтем с вьюхи
        [runner runAction:[SKAction group:groupOfActionsOfRunner]];
        
    } else if ([runner.name isEqualToString:@"son"]){
        
        SKAction *moveDown = [[SKAction alloc]init];
        
        if ([item.name isEqualToString:@"hamburger"]) {
            moveDown = [SKAction moveByX:0 y:-screenCell.height duration:screenCell.height / _backgroundMoveSpeed];
        }else {
            moveDown = [SKAction moveByX:0 y:-screenCell.height / 2 duration:screenCell.height / _backgroundMoveSpeed];
        }
        
        SKTexture *runnerTexture1 = [SKTexture textureWithImageNamed:@"son1.png"];
        SKTexture *runnerTexture2 = [SKTexture textureWithImageNamed:@"son2.png"];
        NSArray *runnerTextures = [NSArray arrayWithObjects:runnerTexture1,runnerTexture2, nil];
        SKAction *runnerAnimationAction = [SKAction animateWithTextures:runnerTextures timePerFrame:sonAnimationDuration];
        
        NSArray *groupOfActionsOfRunner = @[moveDown, runnerAnimationAction];
        
        [item removeFromParent];//удаляем айтем с вьюхи
        [runner runAction:[SKAction group:groupOfActionsOfRunner]];
    } else {
        NSLog(@"ERROR! runner.name is strange!");
    }
}

- (void)gameOver {

    NSLog(@"\n\n\nGAME OVER!\n\n\n");
    [self removeAllChildren];
    
    [self setBackgroundColor:[SKColor blackColor]];
    
    NSString *gameOverString = @"GAME OVER";
    SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"San Francisco"];
    gameOverLabel.text = gameOverString;
    gameOverLabel.fontColor = [SKColor whiteColor];
    gameOverLabel.fontSize = 30;
    gameOverLabel.zPosition = 100;
    gameOverLabel.position = CGPointMake(screenWidth / 2, screenHeight / 2);
    [self addChild:gameOverLabel];
}

@end
