//
//  Background.h
//  MamaMarathon
//
//  Created by Илья on 01.04.17.
//  Copyright © 2017 Ilya Biltuev. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Background : SKSpriteNode

@property (strong, nonatomic) Background* previousBackgroundNode;
@property (strong, nonatomic) Background* nextBackgroundNode;

+(Background *)generateNewBackground;

@end
