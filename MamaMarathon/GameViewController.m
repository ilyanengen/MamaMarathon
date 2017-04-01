//
//  GameViewController.m
//  MamaMarathon
//
//  Created by Илья on 01.04.17.
//  Copyright © 2017 Ilya Biltuev. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    SKView *skView = (SKView *)self.view;
    GameScene *scene = [GameScene sceneWithSize:skView.bounds.size];
    
    // Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene
    [skView presentScene:scene];
    
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
