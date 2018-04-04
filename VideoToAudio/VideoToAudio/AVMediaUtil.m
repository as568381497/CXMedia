//
//  AVMediaUtil.m
//  videoToMp3
//
//  Created by pathfinder on 2018/4/3.
//  Copyright © 2018年 lingyfh. All rights reserved.
//

#import "AVMediaUtil.h"
#define OUTPUTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
@implementation AVMediaUtil

#pragma mark - 暴露方法
//转换从路径
+ (void)changeVideoToAudioWithReadPath:(NSURL *)readPath completionHandler:(void(^)(successType success , NSString *fileName))completionHandler
{
    //判断读取路径是否存在
    if (readPath == nil)
    {
        completionHandler(mediaNil,@"");
        return;
    }
    
    
    //处理输入文件，抽出音轨，并获取播放时长
    AVMutableComposition *newAudioAsset = [AVMutableComposition composition];
    AVMutableCompositionTrack *dstCompositionTrack;
    dstCompositionTrack = [newAudioAsset addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAsset *srcAsset = [AVURLAsset URLAssetWithURL:readPath options:nil];
    AVAssetTrack *srcTrack = [[srcAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    CMTimeRange timeRange = srcTrack.timeRange;
    
    
    
    //合成音轨，输出错误 如果有
    NSError *error;
    if(NO == [dstCompositionTrack insertTimeRange:timeRange ofTrack:srcTrack atTime:kCMTimeZero error:&error]) {
        NSLog(@"track insert failed: %@n", error);
        return;
    }
    
    //处理输出文件，确定输出类型
    AVAssetExportSession *exportSesh = [[AVAssetExportSession alloc] initWithAsset:newAudioAsset presetName:AVAssetExportPresetPassthrough];
    
    NSString *fileName = [self getFileName:readPath];
    NSArray *typeArr = [NSArray arrayWithArray:[exportSesh supportedFileTypes]];
    if ([typeArr containsObject:AVFileTypeMPEGLayer3])
    {
        NSString *name = [self getOutputName:fileName WithExtension:@"mp3"];
        NSString *filePath = [OUTPUTPATH stringByAppendingPathComponent:name];
        NSURL *outputURL = [NSURL fileURLWithPath:filePath];
        exportSesh.outputFileType = AVFileTypeMPEGLayer3;
        exportSesh.outputURL = outputURL;
        fileName = name;
        
    }
    else if ([typeArr containsObject:AVFileTypeAppleM4A])
    {
        NSString *name = [self getOutputName:fileName WithExtension:@"m4a"];
        NSString *filePath = [OUTPUTPATH stringByAppendingPathComponent:name];
        NSURL *outputURL = [NSURL fileURLWithPath:filePath];
        exportSesh.outputFileType = AVFileTypeAppleM4A;
        exportSesh.outputURL = outputURL;
        fileName = name;
    }
    
    //执行输出操作
    [exportSesh exportAsynchronouslyWithCompletionHandler:^{
        
        AVAssetExportSessionStatus status = exportSesh.status;
        NSLog(@"exportAsynchronouslyWithCompletionHandler: %lin", (long)status);
        
        if(AVAssetExportSessionStatusFailed == status)
        {
            completionHandler(mediaFailed,fileName);
            NSLog(@"FAILURE: %@n", exportSesh.error);
        }
        else if(AVAssetExportSessionStatusCompleted == status)
        {
            completionHandler(mediaStatus,fileName);
            NSLog(@"SUCCESS!n");
        }
        
    }];
}

+ (NSString *)shavedString:(NSString *)path
{
    
    if([path containsString:@"file://"])
    {
        NSRange range = [path rangeOfString:@"file://"];
        //匹配得到的下标
        NSRange textRange = {range.length,path.length - range.length};
        NSString *newPath = [path substringWithRange:textRange];
        return newPath;
    }
    else
    {
        return path;
    }
    
}


#pragma mark - 内部方法
//获取文件名称
+ (NSString *)getFileName:(NSURL *)path
{
    NSString *lastString = path.lastPathComponent;
    NSString *extenString = path.pathExtension;
    
    NSRange range = [lastString rangeOfString:[NSString stringWithFormat:@".%@",extenString]];
    
    //匹配得到的下标
    NSRange textRange = {0,range.location};
    NSString *fileName = [lastString substringWithRange:textRange];
    
    return fileName;
}

//判断输出路径是否有文件存在,如果有则输出返回新名称
+ (NSString *)getOutputName:(NSString *)name WithExtension:(NSString *)extension
{
    NSString *filePath = [OUTPUTPATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",name,extension]];
    NSURL *outputURL = [NSURL URLWithString:filePath];
    
    //判断读取路径是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputURL.absoluteString])
    {
        NSRange range = [outputURL.absoluteString rangeOfString:outputURL.lastPathComponent];
        NSRange textRange = {0,range.location};
        NSString *filePath = [outputURL.absoluteString substringWithRange:textRange];
        int index = 1;
        NSString *newfileName;
        while (1)
        {
            newfileName = [NSString stringWithFormat:@"%@(%d).%@",name,index,extension];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[filePath stringByAppendingPathComponent:newfileName]])
            {
                index++;
                continue;
            }
            else
            {
                return newfileName;
            }
            
        }
       
    }
    else
    {
        return [NSString stringWithFormat:@"%@.%@",name,extension];
    }
    
}

@end
