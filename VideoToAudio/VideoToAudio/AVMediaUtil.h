//
//  AVMediaUtil.h
//  videoToMp3
//
//  Created by pathfinder on 2018/4/3.
//  Copyright © 2018年 lingyfh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSUInteger, successType) {
    mediaNil,
    mediaFailed,
    mediaStatus
};


@interface AVMediaUtil : NSObject

//转换为音频从url
+ (void)changeVideoToAudioWithReadPath:(NSURL *)readPath completionHandler:(void(^)(successType success , NSString *fileName))completionHandler;

//处理路径,去除@“file”头部
+ (NSString *)shavedString:(NSString *)path;

@end
