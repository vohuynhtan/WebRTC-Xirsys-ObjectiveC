//
//  ViewController.m
//  WebRTC-Xirsys-ObjectiveC
//
//  Created by TanVo on 8/3/16.
//  Copyright © 2016 TanVo. All rights reserved.
//

#import "ViewController.h"
#import "WebRTCManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [[WebRTCManager sharedInstance]createPeerConnectionWithICEServers];
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"1", @"2", @"3", @"4", nil];
    
    for (NSString *str in array) {
        [array removeObject:str];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
