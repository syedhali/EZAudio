//
//  EZRecorder.m
//  EZAudio
//
//  Created by Syed Haris Ali on 12/1/13.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "EZRecorder.h"
#import "EZAudioUtilities.h"

typedef struct
{
    ExtAudioFileRef             extAudioFileRef;
    AudioStreamBasicDescription clientFormat;
    AudioFileTypeID             fileTypeID;
    CFURLRef                    fileURL;
    AudioStreamBasicDescription fileFormat;
} EZRecorderInfo;

@interface EZRecorder ()
@property (nonatomic, assign) EZRecorderInfo *info;
@end

@implementation EZRecorder

#pragma mark - Initializers
- (EZRecorder*)initWithDestinationURL:(NSURL*)url
                        sourceFormat:(AudioStreamBasicDescription)sourceFormat
                 destinationFileType:(EZRecorderFileType)destinationFileType
{
    self = [super init];
    if (self)
    {
        // Set defaults
        self.info = (EZRecorderInfo *)calloc(1, sizeof(EZRecorderInfo));
        self.info->fileURL = (__bridge CFURLRef)url;
        self.info->clientFormat = sourceFormat;
        self.info->fileFormat = [EZRecorder recorderFormatForFileType:destinationFileType withSourceFormat:self.info->clientFormat];
        self.info->fileTypeID  = [EZRecorder recorderFileTypeIdForFileType:destinationFileType withSourceFormat:self.info->clientFormat];
        [self setup];
    }
    return self;
}

#pragma mark - Class Initializers
+(EZRecorder*)recorderWithDestinationURL:(NSURL*)url
                            sourceFormat:(AudioStreamBasicDescription)sourceFormat
                     destinationFileType:(EZRecorderFileType)destinationFileType
{
    return [[EZRecorder alloc] initWithDestinationURL:url
                                         sourceFormat:sourceFormat
                                  destinationFileType:destinationFileType];
}

#pragma mark - Private Configuration
+ (AudioStreamBasicDescription)recorderFormatForFileType:(EZRecorderFileType)fileType
                                        withSourceFormat:(AudioStreamBasicDescription)sourceFormat
{
    AudioStreamBasicDescription asbd;
    switch (fileType)
    {
        case EZRecorderFileTypeAIFF:
            asbd = [EZAudioUtilities AIFFFormatWithNumberOfChannels:sourceFormat.mChannelsPerFrame
                                                         sampleRate:sourceFormat.mSampleRate];
            break;
        case EZRecorderFileTypeM4A:
            asbd = [EZAudioUtilities M4AFormatWithNumberOfChannels:sourceFormat.mChannelsPerFrame
                                                        sampleRate:sourceFormat.mSampleRate];
            break;
            
        case EZRecorderFileTypeWAV:
            asbd = [EZAudioUtilities stereoFloatInterleavedFormatWithSampleRate:sourceFormat.mSampleRate];
            break;
            
        default:
            asbd = [EZAudioUtilities stereoCanonicalNonInterleavedFormatWithSampleRate:sourceFormat.mSampleRate];
            break;
    }
    return asbd;
}

//------------------------------------------------------------------------------

+ (AudioFileTypeID)recorderFileTypeIdForFileType:(EZRecorderFileType)fileType
                                withSourceFormat:(AudioStreamBasicDescription)sourceFormat
{
    AudioFileTypeID audioFileTypeID;
    switch ( fileType)
    {
        case EZRecorderFileTypeAIFF:
            audioFileTypeID = kAudioFileAIFFType;
            break;
            
        case EZRecorderFileTypeM4A:
            audioFileTypeID = kAudioFileM4AType;
            break;
            
        case EZRecorderFileTypeWAV:
            audioFileTypeID = kAudioFileWAVEType;
            break;
            
        default:
            audioFileTypeID = kAudioFileWAVEType;
            break;
    }
    return audioFileTypeID;
}

//------------------------------------------------------------------------------

- (void)setup
{
    // Finish filling out the destination format description
    UInt32 propSize = sizeof(self.info->fileFormat);
    [EZAudioUtilities checkResult:AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                                         0,
                                                         NULL,
                                                         &propSize,
                                                         &self.info->fileFormat)
                        operation:"Failed to fill out rest of destination format"];
    
    // Create the audio file
    [EZAudioUtilities checkResult:ExtAudioFileCreateWithURL(self.info->fileURL,
                                                            self.info->fileTypeID,
                                                            &self.info->fileFormat,
                                                            NULL,
                                                            kAudioFileFlags_EraseFile,
                                                            &self.info->extAudioFileRef)
                        operation:"Failed to create audio file"];
    
    // Set the client format (which should be equal to the source format)
    [EZAudioUtilities checkResult:ExtAudioFileSetProperty(self.info->extAudioFileRef,
                                                          kExtAudioFileProperty_ClientDataFormat,
                                                          sizeof(self.info->clientFormat),
                                                          &self.info->clientFormat)
                        operation:"Failed to set client format on recorded audio file"];
    
}

//------------------------------------------------------------------------------
#pragma mark - Events
//------------------------------------------------------------------------------

- (void)appendDataFromBufferList:(AudioBufferList *)bufferList
                  withBufferSize:(UInt32)bufferSize
{
    if (self.info->extAudioFileRef)
    {
        [EZAudioUtilities checkResult:ExtAudioFileWriteAsync(self.info->extAudioFileRef,
                                                             bufferSize,
                                                             bufferList)
                   operation:"Failed to write audio data to recorded audio file"];
        
        SInt64 outFrameOffset;
        [EZAudioUtilities checkResult:ExtAudioFileTell(self.info->extAudioFileRef,
                                                       &outFrameOffset) operation:"Failed to get current frame"];
        NSLog(@"out frame: %lli", outFrameOffset);
    }
}

- (void)closeAudioFile
{
    if (self.info->extAudioFileRef)
    {
        // Dispose of the audio file reference
        [EZAudioUtilities checkResult:ExtAudioFileDispose(self.info->extAudioFileRef)
                            operation:"Failed to close audio file"];
        
        // Null out the file reference
        self.info->extAudioFileRef = NULL;
    }
}

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

//- (NSTimeInterval)currentTime
//{
//    
//}

//------------------------------------------------------------------------------

//- (NSTimeInterval)duration
//{
//
//}

//------------------------------------------------------------------------------

//- (NSString *)formattedCurrentTime
//{
//    
//}

//------------------------------------------------------------------------------

//- (NSString *)formattedDuration
//{
//    
//}

//------------------------------------------------------------------------------

- (SInt64)frameIndex
{
    SInt64 frameIndex;
    [EZAudioUtilities checkResult:ExtAudioFileTell(self.info->extAudioFileRef, &frameIndex)
                        operation:"Failed to get frame index"];
    return frameIndex;
}

//------------------------------------------------------------------------------

//- (SInt64)totalFrames
//{
//    
//}

//------------------------------------------------------------------------------

- (NSURL *)url
{
    return (__bridge NSURL*)self.info->fileURL;
}

#pragma mark - Dealloc
- (void)dealloc
{
    [self closeAudioFile];
}

@end