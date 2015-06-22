//
//  EZAudioFile.m
//  EZAudio
//
//  Created by Syed Haris Ali on 12/1/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
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

#import "EZAudioFile.h"

//------------------------------------------------------------------------------

#import "EZAudio.h"
#import "EZAudioFloatConverter.h"
#import "EZAudioFloatData.h"
#include <pthread.h>

//------------------------------------------------------------------------------

// errors
static OSStatus EZAudioFileReadPermissionFileDoesNotExistCode = -88776;

// constants
static UInt32 EZAudioFileWaveformDefaultResolution = 1024;
static NSString *EZAudioFileWaveformDataQueueIdentifier = @"com.ezaudio.waveformQueue";

//------------------------------------------------------------------------------

typedef struct
{
    AudioFileID                 audioFileID;
    AudioStreamBasicDescription clientFormat;
    float                       duration;
    ExtAudioFileRef             extAudioFileRef;
    AudioStreamBasicDescription fileFormat;
    SInt64                      frames;
    EZAudioFilePermission       permission;
    CFURLRef                    sourceURL;
} EZAudioFileInfo;

//------------------------------------------------------------------------------
#pragma mark - EZAudioFile
//------------------------------------------------------------------------------

@interface EZAudioFile ()
@property (nonatomic, strong) EZAudioFloatConverter *floatConverter;
@property (nonatomic) float **floatData;
@property (nonatomic) EZAudioFileInfo *info;
@property (nonatomic) pthread_mutex_t lock;
@property (nonatomic) dispatch_queue_t waveformQueue;
@end

//------------------------------------------------------------------------------

@implementation EZAudioFile

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.info = (EZAudioFileInfo *)malloc(sizeof(EZAudioFileInfo));
        self.info->permission = EZAudioFilePermissionRead;
        _floatData = NULL;
        pthread_mutex_init(&_lock, NULL);
        _waveformQueue = dispatch_queue_create(EZAudioFileWaveformDataQueueIdentifier.UTF8String, DISPATCH_QUEUE_PRIORITY_DEFAULT);
    }
    return self;
}

//------------------------------------------------------------------------------

- (instancetype)initWithURL:(NSURL *)url
{
    AudioStreamBasicDescription asbd;
    return [self initWithURL:url
                  permission:EZAudioFilePermissionRead
                  fileFormat:asbd];
}

//------------------------------------------------------------------------------

- (instancetype)initWithURL:(NSURL*)url
                 permission:(EZAudioFilePermission)permission
                 fileFormat:(AudioStreamBasicDescription)fileFormat
{
    return [self initWithURL:url
                    delegate:nil
                  permission:permission
                  fileFormat:fileFormat];
}

//------------------------------------------------------------------------------

- (instancetype)initWithURL:(NSURL*)url
                   delegate:(id<EZAudioFileDelegate>)delegate
                 permission:(EZAudioFilePermission)permission
                 fileFormat:(AudioStreamBasicDescription)fileFormat
{
    return [self initWithURL:url
                    delegate:delegate
                  permission:permission
                  fileFormat:fileFormat
                clientFormat:[self.class defaultClientFormat]];
}

//------------------------------------------------------------------------------

- (instancetype)initWithURL:(NSURL*)url
                   delegate:(id<EZAudioFileDelegate>)delegate
                 permission:(EZAudioFilePermission)permission
                 fileFormat:(AudioStreamBasicDescription)fileFormat
               clientFormat:(AudioStreamBasicDescription)clientFormat
{
    self = [self init];
    if(self)
    {
        self.info->clientFormat = clientFormat;
        self.info->fileFormat = fileFormat;
        self.info->permission = permission;
        self.info->sourceURL = (__bridge CFURLRef)url;
        self.delegate = delegate;
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------

+ (instancetype)audioFileWithURL:(NSURL*)url
{
    return [[self alloc] initWithURL:url];
}

//------------------------------------------------------------------------------

+ (instancetype)audioFileWithURL:(NSURL*)url
                      permission:(EZAudioFilePermission)permission
                      fileFormat:(AudioStreamBasicDescription)fileFormat
{
    return [[self alloc] initWithURL:url
                          permission:permission
                          fileFormat:fileFormat];
}

//------------------------------------------------------------------------------

+ (instancetype)audioFileWithURL:(NSURL*)url
                        delegate:(id<EZAudioFileDelegate>)delegate
                      permission:(EZAudioFilePermission)permission
                      fileFormat:(AudioStreamBasicDescription)fileFormat
{
    return [[self alloc] initWithURL:url
                            delegate:delegate
                          permission:permission
                          fileFormat:fileFormat];
}

//------------------------------------------------------------------------------

+ (instancetype)audioFileWithURL:(NSURL*)url
                        delegate:(id<EZAudioFileDelegate>)delegate
                      permission:(EZAudioFilePermission)permission
                      fileFormat:(AudioStreamBasicDescription)fileFormat
                    clientFormat:(AudioStreamBasicDescription)clientFormat
{
    return [[self alloc] initWithURL:url
                            delegate:delegate
                          permission:permission
                          fileFormat:fileFormat
                        clientFormat:clientFormat];
}

//------------------------------------------------------------------------------
#pragma mark - Class Methods
//------------------------------------------------------------------------------

+ (AudioStreamBasicDescription)defaultClientFormat
{
    return [EZAudioUtilities stereoFloatNonInterleavedFormatWithSampleRate:44100];
}

//------------------------------------------------------------------------------

+ (NSArray *)supportedAudioFileTypes
{
    return @[
        @"aac",
        @"caf",
        @"aif",
        @"aiff",
        @"aifc",
        @"mp3",
        @"mp4",
        @"m4a",
        @"snd",
        @"au",
        @"sd2",
        @"wav"
    ];
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)setup
{
    // we open the file differently depending on the permissions specified
    [EZAudioUtilities checkResult:[self openAudioFile]
                        operation:"Failed to create/open audio file"];
    
    // set the client format
    self.clientFormat = self.info->clientFormat;
}

//------------------------------------------------------------------------------
#pragma mark - Creating/Opening Audio File
//------------------------------------------------------------------------------

- (OSStatus)openAudioFile
{
    // need a source url
    NSAssert(self.info->sourceURL, @"EZAudioFile cannot be created without a source url!");
    
    // determine if the file actually exists
    CFURLRef url        = self.info->sourceURL;
    NSURL    *fileURL   = (__bridge NSURL *)(url);
    BOOL     fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path];
    
    // create the file wrapper slightly differently depending what we are
    // trying to do with it
    OSStatus              result     = noErr;
    EZAudioFilePermission permission = self.info->permission;
    UInt32                propSize;
    if (fileExists)
    {
        result = AudioFileOpenURL(url,
                                  permission,
                                  0,
                                  &self.info->audioFileID);
        [EZAudioUtilities checkResult:result
                            operation:"failed to open audio file"];
    }
    else
    {
        // read permission is not applicable because the file does not exist
        if (permission == EZAudioFilePermissionRead)
        {
            result = EZAudioFileReadPermissionFileDoesNotExistCode;
        }
        else
        {
            result = AudioFileCreateWithURL(url,
                                            0,
                                            &self.info->fileFormat,
                                            kAudioFileFlags_EraseFile,
                                            &self.info->audioFileID);
        }
    }
    
    // get the ExtAudioFile wrapper
    if (result == noErr)
    {
        [EZAudioUtilities checkResult:ExtAudioFileWrapAudioFileID(self.info->audioFileID,
                                                                  false,
                                                                  &self.info->extAudioFileRef)
                            operation:"Failed to wrap audio file ID in ext audio file ref"];
    }
    
    // store the file format if we opened an existing file
    if (fileExists)
    {
        propSize = sizeof(self.info->fileFormat);
        [EZAudioUtilities checkResult:ExtAudioFileGetProperty(self.info->extAudioFileRef,
                                                              kExtAudioFileProperty_FileDataFormat,
                                                              &propSize,
                                                              &self.info->fileFormat)
                            operation:"Failed to get file audio format on existing audio file"];
    }
    
    // done
    return result;
}

//------------------------------------------------------------------------------
#pragma mark - Events
//------------------------------------------------------------------------------

- (void)readFrames:(UInt32)frames
    audioBufferList:(AudioBufferList *)audioBufferList
         bufferSize:(UInt32 *)bufferSize
               eof:(BOOL *)eof
{
    if (pthread_mutex_trylock(&_lock) == 0)
    {
        // perform read
        [EZAudioUtilities checkResult:ExtAudioFileRead(self.info->extAudioFileRef,
                                                       &frames,
                                                       audioBufferList)
                            operation:"Failed to read audio data from file"];
        *bufferSize = frames;
        *eof = frames == 0;
        
        // notify delegate
        if ([self.delegate respondsToSelector:@selector(audioFile:updatedPosition:)])
        {
            [self.delegate audioFile:self
                     updatedPosition:self.frameIndex];
        }
        
        // convert into float data
        [self.floatConverter convertDataFromAudioBufferList:audioBufferList
                                         withNumberOfFrames:*bufferSize
                                             toFloatBuffers:self.floatData];
        
        if ([self.delegate respondsToSelector:@selector(audioFile:readAudio:withBufferSize:withNumberOfChannels:)])
        {
            UInt32 channels = self.clientFormat.mChannelsPerFrame;
            [self.delegate audioFile:self
                           readAudio:self.floatData
                      withBufferSize:*bufferSize
                withNumberOfChannels:channels];
        }
        
        pthread_mutex_unlock(&_lock);
        
    }
}

//------------------------------------------------------------------------------

- (void)seekToFrame:(SInt64)frame
{
    if (pthread_mutex_trylock(&_lock) == 0)
    {
        [EZAudioUtilities checkResult:ExtAudioFileSeek(self.info->extAudioFileRef,
                                                       frame)
                   operation:"Failed to seek frame position within audio file"];

        pthread_mutex_unlock(&_lock);
        
        // notify delegate
        if ([self.delegate respondsToSelector:@selector(audioFile:updatedPosition:)])
        {
            [self.delegate audioFile:self
                     updatedPosition:self.frameIndex];
        }
    }
}

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

- (AudioStreamBasicDescription)floatFormat
{
    return [EZAudioUtilities stereoFloatNonInterleavedFormatWithSampleRate:44100];
}

//------------------------------------------------------------------------------

- (EZAudioFloatData *)getWaveformData
{
    return [self getWaveformDataWithNumberOfPoints:EZAudioFileWaveformDefaultResolution];
}

//------------------------------------------------------------------------------

- (EZAudioFloatData *)getWaveformDataWithNumberOfPoints:(UInt32)numberOfPoints
{
    EZAudioFloatData *waveformData;
    if (pthread_mutex_trylock(&_lock) == 0)
    {
        // store current frame
        SInt64 currentFrame     = self.frameIndex;
        UInt32 channels         = self.clientFormat.mChannelsPerFrame;
        BOOL   interleaved      = [EZAudioUtilities isInterleaved:self.clientFormat];
        SInt64 totalFrames      = self.totalClientFrames;
        SInt64 framesPerBuffer  = ((SInt64) totalFrames / numberOfPoints);
        SInt64 framesPerChannel = framesPerBuffer / channels;
        float  **data           = (float **)malloc( sizeof(float *) * channels );
        for (int i = 0; i < channels; i++)
        {
            data[i] = (float *)malloc( sizeof(float) * numberOfPoints );
        }
        
        // seek to 0
        [EZAudioUtilities checkResult:ExtAudioFileSeek(self.info->extAudioFileRef,
                                                       0)
                   operation:"Failed to seek frame position within audio file"];
        
        // allocate an audio buffer list
        AudioBufferList *audioBufferList = [EZAudioUtilities audioBufferListWithNumberOfFrames:(UInt32)totalFrames
                                                                              numberOfChannels:self.info->clientFormat.mChannelsPerFrame
                                                                                   interleaved:interleaved];

        UInt32 bufferSize = (UInt32)totalFrames;
        [EZAudioUtilities checkResult:ExtAudioFileRead(self.info->extAudioFileRef,
                                                       &bufferSize,
                                                       audioBufferList)
                            operation:"Failed to read audio data from file waveform"];
        
        // read through file and calculate rms at each point
        SInt64 offset = 0;
        for (SInt64 i = 0; i < numberOfPoints; i++)
        {
            float buffer[framesPerBuffer];
            if (interleaved)
            {
                float *samples = (float *)audioBufferList->mBuffers[0].mData;
                memcpy(buffer, &samples[offset], (size_t)framesPerBuffer * sizeof(float));
                for (int channel = 0; channel < channels; channel++)
                {
                    float channelData[framesPerChannel];
                    for (int frame = 0; frame < framesPerChannel; frame++)
                    {
                        channelData[frame] = buffer[frame * channels + channel];
                    }
                    float rms = [EZAudioUtilities RMS:channelData length:(UInt32)framesPerChannel];
                    data[channel][i] = rms;
                }
                offset += channels * framesPerBuffer;
            }
            else
            {
                for (int channel = 0; channel < channels; channel++)
                {
                    float *samples = (float *)audioBufferList->mBuffers[channel].mData;
                    memcpy(buffer, &samples[offset], (size_t)framesPerBuffer * sizeof(float));
                    float rms = [EZAudioUtilities RMS:buffer length:(UInt32)framesPerBuffer];
                    data[channel][i] = rms;
                }
                offset += framesPerBuffer;
            }
        }
        
        // clean up
        [EZAudioUtilities freeBufferList:audioBufferList];
        
        // seek back to previous position
        [EZAudioUtilities checkResult:ExtAudioFileSeek(self.info->extAudioFileRef,
                                                       currentFrame)
                            operation:"Failed to seek frame position within audio file"];
        
        pthread_mutex_unlock(&_lock);
        
        waveformData = [EZAudioFloatData dataWithNumberOfChannels:channels
                                                          buffers:(float **)data
                                                       bufferSize:numberOfPoints];
        
        // cleanup
        [EZAudioUtilities freeFloatBuffers:data
                          numberOfChannels:channels];
    }
    return waveformData;
}

//------------------------------------------------------------------------------

- (void)getWaveformDataWithCompletionBlock:(WaveformDataCompletionBlock)waveformDataCompletionBlock
{
    [self getWaveformDataWithNumberOfPoints:EZAudioFileWaveformDefaultResolution
                                 completion:waveformDataCompletionBlock];
}

//------------------------------------------------------------------------------

- (void)getWaveformDataWithNumberOfPoints:(UInt32)numberOfPoints
                               completion:(WaveformDataCompletionBlock)completion
{
    if (!completion)
    {
        return;
    }

    // async get waveform data
    __weak EZAudioFile *weakSelf = self;
    dispatch_async(self.waveformQueue, ^{
        EZAudioFloatData *waveformData = [weakSelf getWaveformDataWithNumberOfPoints:numberOfPoints];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(waveformData);
        });
    });
}

//------------------------------------------------------------------------------

- (AudioStreamBasicDescription)clientFormat
{
    return self.info->clientFormat;
}

//------------------------------------------------------------------------------

- (AudioStreamBasicDescription)fileFormat
{
    return self.info->fileFormat;
}

//------------------------------------------------------------------------------

- (SInt64)frameIndex
{
    SInt64 frameIndex;
    [EZAudioUtilities checkResult:ExtAudioFileTell(self.info->extAudioFileRef, &frameIndex)
                        operation:"Failed to get frame index"];
    return frameIndex;
}

//------------------------------------------------------------------------------

- (NSDictionary *)metadata
{
    // get size of metadata property (dictionary)
    UInt32          propSize = sizeof(self.info->audioFileID);
    CFDictionaryRef metadata;
    UInt32          writable;
    [EZAudioUtilities checkResult:AudioFileGetPropertyInfo(self.info->audioFileID,
                                                           kAudioFilePropertyInfoDictionary,
                                                           &propSize,
                                                           &writable)
                        operation:"Failed to get the size of the metadata dictionary"];
    
    // pull metadata
    [EZAudioUtilities checkResult:AudioFileGetProperty(self.info->audioFileID,
                                                       kAudioFilePropertyInfoDictionary,
                                                       &propSize,
                                                       &metadata)
                        operation:"Failed to get metadata dictionary"];
    
    // cast to NSDictionary
    return (__bridge NSDictionary*)metadata;
}

//------------------------------------------------------------------------------

- (NSTimeInterval)totalDuration
{
    SInt64 totalFrames = [self totalFrames];
    return (NSTimeInterval) totalFrames / self.info->fileFormat.mSampleRate;
}

//------------------------------------------------------------------------------

- (SInt64)totalClientFrames
{
    SInt64 totalFrames = [self totalFrames];
    
    // check sample rate of client vs file format
    AudioStreamBasicDescription clientFormat = self.info->clientFormat;
    AudioStreamBasicDescription fileFormat   = self.info->fileFormat;
    BOOL sameSampleRate = clientFormat.mSampleRate == fileFormat.mSampleRate;
    if (!sameSampleRate)
    {
        NSTimeInterval duration = [self totalDuration];
        totalFrames = duration * clientFormat.mSampleRate;
    }
    
    return totalFrames;
}

//------------------------------------------------------------------------------

- (SInt64)totalFrames
{
    SInt64 totalFrames;
    UInt32 size = sizeof(SInt64);
    [EZAudioUtilities checkResult:ExtAudioFileGetProperty(self.info->extAudioFileRef,
                                                          kExtAudioFileProperty_FileLengthFrames,
                                                          &size,
                                                          &totalFrames)
                        operation:"Failed to get total frames"];
    return totalFrames;
}

//------------------------------------------------------------------------------

- (NSURL*)url
{
  return (__bridge NSURL*)self.info->sourceURL;
}

//------------------------------------------------------------------------------
#pragma mark - Setters
//------------------------------------------------------------------------------

- (void)setClientFormat:(AudioStreamBasicDescription)clientFormat
{
    NSAssert([EZAudioUtilities isLinearPCM:clientFormat], @"Client format must be linear PCM");
    
    // store the client format
    self.info->clientFormat = clientFormat;
    
    // set the client format on the extended audio file ref
    [EZAudioUtilities checkResult:ExtAudioFileSetProperty(self.info->extAudioFileRef,
                                                          kExtAudioFileProperty_ClientDataFormat,
                                                          sizeof(clientFormat),
                                                          &clientFormat)
                        operation:"Couldn't set client data format on file"];
    
    // create a new float converter using the client format as the input format
    self.floatConverter = [EZAudioFloatConverter converterWithInputFormat:clientFormat];
    
    UInt32 maxPacketSize;
    UInt32 propSize = sizeof(maxPacketSize);
    [EZAudioUtilities checkResult:ExtAudioFileGetProperty(self.info->extAudioFileRef,
                                                          kExtAudioFileProperty_ClientMaxPacketSize,
                                                          &propSize,
                                                          &maxPacketSize)
                        operation:"Failed to get max packet size"];
    
    
    
    // figure out what the max packet size is
    
    
    
    
    
    
    self.floatData = [EZAudioUtilities floatBuffersWithNumberOfFrames:1024
                                                     numberOfChannels:self.clientFormat.mChannelsPerFrame];
}

//------------------------------------------------------------------------------

-(void)dealloc
{
    pthread_mutex_destroy(&_lock);
    [EZAudioUtilities freeFloatBuffers:self.floatData numberOfChannels:self.clientFormat.mChannelsPerFrame];
    [EZAudioUtilities checkResult:AudioFileClose(self.info->audioFileID) operation:"Failed to close audio file"];
    [EZAudioUtilities checkResult:ExtAudioFileDispose(self.info->extAudioFileRef) operation:"Failed to dispose of ext audio file"];
    free(self.info);
}

//------------------------------------------------------------------------------

@end
