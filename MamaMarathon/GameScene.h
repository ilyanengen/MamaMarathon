//
//  GameScene.h
//  MamaMarathon
//
//  Created by Илья on 01.04.17.
//  Copyright © 2017 Ilya Biltuev. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene <SKPhysicsContactDelegate>

@property(nonatomic, assign) id<SKPhysicsContactDelegate> contactDelegate;

@end
