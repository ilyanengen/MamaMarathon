//
//  Background.m
//  MamaMarathon
//
//  Created by Илья on 01.04.17.
//  Copyright © 2017 Ilya Biltuev. All rights reserved.
//

#import "Background.h"

@implementation Background

+(Background *)generateNewBackground {
    
    Background *background = [[Background alloc]initWithImageNamed:@"road1.jpg"];
    background.anchorPoint = CGPointZero;
    background.zPosition = 1;
    
    return background;
}


@end
