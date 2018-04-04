//
//  ViewController.m
//  VideoToAudio
//
//  Created by pathfinder on 2018/4/4.
//  Copyright © 2018年 pathfinder. All rights reserved.
//

#import "ViewController.h"
#import "AVMediaUtil.h"

#define OUTPUTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

@import Foundation;

@interface ViewController ()

@property(strong, nonatomic)AVAudioPlayer *play;
@property(copy, nonatomic)NSString *playFileName;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (IBAction)change:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"TalkingTom" withExtension:@"mp4"];
    [AVMediaUtil changeVideoToAudioWithReadPath:URL completionHandler:^(successType success, NSString *fileName) {
        if (success == mediaStatus)
        {
            weakSelf.playFileName = fileName;
        }
    }];
}


- (IBAction)play:(UIButton *)sender
{
    NSString *filePath = [OUTPUTPATH stringByAppendingPathComponent:_playFileName];
    NSURL *outputURL = [NSURL fileURLWithPath:filePath];
    _play = [[AVAudioPlayer alloc] initWithContentsOfURL:outputURL error:NULL];
    _play.volume = 1;
    [_play prepareToPlay];
    [_play play];
}

@end
