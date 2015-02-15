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
#include <pthread.h>

//------------------------------------------------------------------------------

// errors
static OSStatus EZAudioFileReadPermissionFileDoesNotExistCode = -88776;

// constants
static UInt32    EZAudioFileWaveformDefaultResolution   = 1024;
static NSString *EZAudioFileWaveformDataQueueIdentifier = @"com.ezaudio.waveformQueue";

//------------------------------------------------------------------------------

typedef struct
{
    AudioFileID                 audioFileID;
    AudioStreamBasicDescription clientFormat;
    Float32                     duration;
    ExtAudioFileRef             extAudioFileRef;
    AudioStreamBasicDescription fileFormat;
    SInt64                      frames;
    EZAudioFilePermission       permission;
    CFURLRef                    sourceURL;
} EZAudioFileInfo;

//------------------------------------------------------------------------------
#pragma mark - EZAudioWaveformData
//------------------------------------------------------------------------------

@interface EZAudioWaveformData ()
@property (nonatomic, assign, readwrite) int numberOfChannels;
@property (nonatomic, assign, readwrite) float **buffers;
@property (nonatomic, assign, readwrite) UInt32 bufferSize;
@end

@implementation EZAudioWaveformData

- (void)dealloc
{
    for (int i = 0; i < self.numberOfChannels; i++)
    {
        free(self.buffers[i]);
    }
    free(self.buffers);
}

+ (instancetype)dataWithNumberOfChannels:(int)numberOfChannels
                                 buffers:(float **)buffers
                              bufferSize:(UInt32)bufferSize
{
    id waveformData = [[self alloc] init];
    
    size_t size = sizeof(float *) * numberOfChannels;
    float **buffersCopy = (float **)malloc(size);
    for (int i = 0; i < numberOfChannels; i++)
    {
        size = sizeof(float) * bufferSize;
        buffersCopy[i] = (float *)malloc(size);
        memcpy(buffersCopy[i], buffers[i], size);
    }
    
    ((EZAudioWaveformData *)waveformData).buffers = buffersCopy;
    ((EZAudioWaveformData *)waveformData).bufferSize = bufferSize;
    ((EZAudioWaveformData *)waveformData).numberOfChannels = numberOfChannels;
    
    return waveformData;
}

- (float *)bufferForChannel:(int)channel
{
    float *buffer = NULL;
    if (channel < self.numberOfChannels)
    {
        buffer = self.buffers[channel];
    }
    return buffer;
}

@end

//------------------------------------------------------------------------------
#pragma mark - EZAudioFile
//------------------------------------------------------------------------------

@interface EZAudioFile ()
@property (nonatomic) EZAudioFileInfo info;
@property (nonatomic) pthread_mutex_t lock;
@property (nonatomic) dispatch_queue_t waveformQueue;
@end

//------------------------------------------------------------------------------

@implementation EZAudioFile

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        memset(&_info, 0, sizeof(_info));
        _info.permission = EZAudioFilePermissionRead;
        pthread_mutex_init(&_lock, NULL);
        _waveformQueue = dispatch_queue_create(EZAudioFileWaveformDataQueueIdentifier.UTF8String, DISPATCH_QUEUE_PRIORITY_DEFAULT);
    }
    return self;
}

//------------------------------------------------------------------------------

- (instancetype) initWithURL:(NSURL*)url
{
    AudioStreamBasicDescription asbd;
    return [self initWithURL:url
                  permission:EZAudioFilePermissionRead
                  fileFormat:asbd];
}

//------------------------------------------------------------------------------

- (instancetype) initWithURL:(NSURL*)url
                  permission:(EZAudioFilePermission)permission
                  fileFormat:(AudioStreamBasicDescription)fileFormat
{
    return [self initWithURL:url
                    delegate:nil
                  permission:permission
                  fileFormat:fileFormat];
}

//------------------------------------------------------------------------------

- (instancetype) initWithURL:(NSURL*)url
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

- (instancetype) initWithURL:(NSURL*)url
                    delegate:(id<EZAudioFileDelegate>)delegate
                  permission:(EZAudioFilePermission)permission
                  fileFormat:(AudioStreamBasicDescription)fileFormat
                clientFormat:(AudioStreamBasicDescription)clientFormat
{
    self = [self init];
    if(self)
    {
        _info.clientFormat = clientFormat;
        _info.fileFormat   = fileFormat;
        _info.permission   = permission;
        _info.sourceURL    = (__bridge CFURLRef)url;
        self.delegate      = delegate;
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------

+ (instancetype) audioFileWithURL:(NSURL*)url
{
    return [[self alloc] initWithURL:url];
}

//------------------------------------------------------------------------------

+ (instancetype) audioFileWithURL:(NSURL*)url
                       permission:(EZAudioFilePermission)permission
                       fileFormat:(AudioStreamBasicDescription)fileFormat
{
    return [[self alloc] initWithURL:url
                          permission:permission
                          fileFormat:fileFormat];
}

//------------------------------------------------------------------------------

+ (instancetype) audioFileWithURL:(NSURL*)url
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

+ (instancetype) audioFileWithURL:(NSURL*)url
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

+ (AudioStreamBasicDescription) defaultClientFormat
{
    return [EZAudio stereoFloatNonInterleavedFormatWithSampleRate:41000];
}

//------------------------------------------------------------------------------

+ (NSArray *) supportedAudioFileTypes
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

- (void) setup
{
    // we open the file differently depending on the permissions specified
    [EZAudio checkResult:[self openAudioFile]
               operation:"Failed to create/open audio file"];
    
    // set the client format
    self.clientFormat = self.info.clientFormat;
}

//------------------------------------------------------------------------------
#pragma mark - Creating/Opening Audio File
//------------------------------------------------------------------------------

- (OSStatus) openAudioFile
{
    // need a source url
    NSAssert(_info.sourceURL, @"EZAudioFile cannot be created without a source url!");
    
    // determine if the file actually exists
    CFURLRef url        = self.info.sourceURL;
    NSURL    *fileURL   = (__bridge NSURL *)(url);
    BOOL     fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path];
    
    // create the file wrapper slightly differently depending what we are
    // trying to do with it
    OSStatus              result     = noErr;
    EZAudioFilePermission permission = self.info.permission;
    UInt32                propSize;
    if (fileExists)
    {
        result = AudioFileOpenURL(url,
                                  permission,
                                  0,
                                  &_info.audioFileID);
        [EZAudio checkResult:result
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
                                            &_info.fileFormat,
                                            kAudioFileFlags_EraseFile,
                                            &_info.audioFileID);
        }
    }
    
    // get the ExtAudioFile wrapper
    if (result == noErr)
    {
        [EZAudio checkResult:ExtAudioFileWrapAudioFileID(self.info.audioFileID,
                                                         false,
                                                         &_info.extAudioFileRef)
                   operation:"Failed to wrap audio file ID in ext audio file ref"];
    }
    
    // store the file format if we opened an existing file
    if (fileExists)
    {
        propSize = sizeof(self.info.fileFormat);
        [EZAudio checkResult:ExtAudioFileGetProperty(self.info.extAudioFileRef,
                                                     kExtAudioFileProperty_FileDataFormat,
                                                     &propSize,
                                                     &_info.fileFormat)
                   operation:"Failed to get file audio format on existing audio file"];
    }
    
    // done
    return result;
}

//------------------------------------------------------------------------------
#pragma mark - Events
//------------------------------------------------------------------------------

- (void) readFrames:(UInt32)frames
    audioBufferList:(AudioBufferList *)audioBufferList
         bufferSize:(UInt32 *)bufferSize
                eof:(BOOL *)eof
{
    if (pthread_mutex_trylock(&_lock) == 0)
    {
        [EZAudio checkResult:ExtAudioFileRead(self.info.extAudioFileRef,
                                              &frames,
                                              audioBufferList)
                   operation:"Failed to read audio data from file"];
        *bufferSize = frames;
        *eof = frames == 0;
        pthread_mutex_unlock(&_lock);
    }
}

- (void) seekToFrame:(SInt64)frame
{
    if (pthread_mutex_trylock(&_lock) == 0)
    {
        [EZAudio checkResult:ExtAudioFileSeek(self.info.extAudioFileRef,
                                              frame)
                   operation:"Failed to seek frame position within audio file"];
        pthread_mutex_unlock(&_lock);
    }
//    if( self.audioFileDelegate ){
//        if( [self.audioFileDelegate respondsToSelector:@selector(audioFile:updatedPosition:)] ){
//            [self.audioFileDelegate audioFile:self updatedPosition:_frameIndex];
//        }
//    }
}

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

- (BOOL) hasLoadedAudioData
{
//  return _waveformData != NULL;
    return NO;
}

//------------------------------------------------------------------------------

- (EZAudioWaveformData *)getWaveformData
{
    return [self getWaveformDataWithNumberOfPoints:EZAudioFileWaveformDefaultResolution];
}

//------------------------------------------------------------------------------

- (EZAudioWaveformData *)getWaveformDataWithNumberOfPoints:(UInt32)numberOfPoints
{
    EZAudioWaveformData *waveformData;
    if (pthread_mutex_trylock(&_lock) == 0)
    {
        // store current frame
        SInt64 currentFrame = self.frameIndex;
        BOOL interleaved = [EZAudio isInterleaved:self.clientFormat];
        UInt32 channels = self.clientFormat.mChannelsPerFrame;
        float **data = (float **)malloc( sizeof(float*) * channels );
        for (int i = 0; i < channels; i++)
        {
            data[i] = (float *)malloc( sizeof(float) * numberOfPoints );
        }
        
        // seek to 0
        [EZAudio checkResult:ExtAudioFileSeek(self.info.extAudioFileRef,
                                              0)
                   operation:"Failed to seek frame position within audio file"];
        
        // calculate the required number of frames per buffer
        SInt64 totalFrames = self.totalClientFrames;
        SInt64 framesPerBuffer = ((SInt64) totalFrames / numberOfPoints);
        SInt64 framesPerChannel = framesPerBuffer / channels;
        
        // allocate an audio buffer list
        AudioBufferList *audioBufferList = [EZAudio audioBufferListWithNumberOfFrames:(UInt32)totalFrames
                                                                     numberOfChannels:self.info.clientFormat.mChannelsPerFrame
                                                                          interleaved:interleaved];

        UInt32 bufferSize = (UInt32)totalFrames;
        [EZAudio checkResult:ExtAudioFileRead(self.info.extAudioFileRef,
                                              &bufferSize,
                                              audioBufferList)
                   operation:"Failed to read audio data from file waveform"];
        
        // read through file and calculate rms at each point
//        SInt64 index = 0;
        for (SInt64 i = 0; i < numberOfPoints; i++)
        {
            
            
            
//            if (interleaved)
//            {
//                float *buffer = (float *)audioBufferList->mBuffers[0].mData;
//                for (int channel = 0; channel < channels; channel++)
//                {
//                    float channelData[framesPerChannel];
//                    for (int frame = 0; frame < framesPerChannel; frame++)
//                    {
//                        channelData[frame] = buffer[frame * channels + channel];
//                    }
//                    float rms = [EZAudio RMS:channelData length:(UInt32)framesPerChannel];
//                    data[channel][i] = rms;
//                }
//            }
//            else
//            {
//                for (int channel = 0; channel < channels; channel++)
//                {
//                    float *channelData = audioBufferList->mBuffers[channel].mData;
//                    float rms = [EZAudio RMS:channelData length:bufferSize];
//                    data[channel][i] = rms;
//                }
//            }
        }
        
        // clean up
        [EZAudio freeBufferList:audioBufferList];
        
        // seek back to previous position
        [EZAudio checkResult:ExtAudioFileSeek(self.info.extAudioFileRef,
                                              currentFrame)
                   operation:"Failed to seek frame position within audio file"];
        
        pthread_mutex_unlock(&_lock);
        
        NSLog(@"done");
        waveformData = [EZAudioWaveformData dataWithNumberOfChannels:channels
                                                             buffers:(float **)data
                                                          bufferSize:numberOfPoints];
        
        // cleanup
        for (int i = 0; i < channels; i++)
        {
            free(data[i]);
        }
        free(data);
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
    dispatch_async(self.waveformQueue, ^{
        EZAudioWaveformData *waveformData = [self getWaveformDataWithNumberOfPoints:numberOfPoints];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(waveformData);
        });
    });
}

//------------------------------------------------------------------------------

- (AudioStreamBasicDescription) clientFormat
{
    return self.info.clientFormat;
}

//------------------------------------------------------------------------------

- (AudioStreamBasicDescription) fileFormat
{
    return self.info.fileFormat;
}

//------------------------------------------------------------------------------

- (SInt64) frameIndex
{
    SInt64 frameIndex;
    [EZAudio checkResult:ExtAudioFileTell(self.info.extAudioFileRef, &frameIndex)
               operation:"Failed to get frame index"];
    return frameIndex;
}

//------------------------------------------------------------------------------

- (NSDictionary *) metadata
{
    // get size of metadata property (dictionary)
    UInt32          propSize = sizeof(_info.audioFileID);
    CFDictionaryRef metadata;
    UInt32          writable;
    [EZAudio checkResult:AudioFileGetPropertyInfo(self.info.audioFileID,
                                                  kAudioFilePropertyInfoDictionary,
                                                  &propSize,
                                                  &writable)
               operation:"Failed to get the size of the metadata dictionary"];
    
    // pull metadata
    [EZAudio checkResult:AudioFileGetProperty(self.info.audioFileID,
                                              kAudioFilePropertyInfoDictionary,
                                              &propSize,
                                              &metadata)
               operation:"Failed to get metadata dictionary"];
    
    // cast to NSDictionary
    return (__bridge NSDictionary*)metadata;
}

//------------------------------------------------------------------------------

- (NSTimeInterval) totalDuration
{
    SInt64 totalFrames = [self totalFrames];
    return (NSTimeInterval) totalFrames / self.info.fileFormat.mSampleRate;
}

//------------------------------------------------------------------------------

- (SInt64) totalClientFrames
{
    SInt64 totalFrames = [self totalFrames];
    
    // check sample rate of client vs file format
    AudioStreamBasicDescription clientFormat = self.info.clientFormat;
    AudioStreamBasicDescription fileFormat   = self.info.fileFormat;
    BOOL sameSampleRate = clientFormat.mSampleRate == fileFormat.mSampleRate;
    if (!sameSampleRate)
    {
        NSTimeInterval duration = [self totalDuration];
        totalFrames = duration * clientFormat.mSampleRate;
    }
    
    return totalFrames;
}

//------------------------------------------------------------------------------

- (SInt64) totalFrames
{
    SInt64 totalFrames;
    UInt32 size = sizeof(SInt64);
    [EZAudio checkResult:ExtAudioFileGetProperty(self.info.extAudioFileRef,
                                                 kExtAudioFileProperty_FileLengthFrames,
                                                 &size,
                                                 &totalFrames)
               operation:"Failed to get total frames"];
    return totalFrames;
}

//------------------------------------------------------------------------------

- (NSURL*) url
{
  return (__bridge NSURL*)self.info.sourceURL;
}

//------------------------------------------------------------------------------
#pragma mark - Setters
//------------------------------------------------------------------------------

- (void) setClientFormat:(AudioStreamBasicDescription)clientFormat
{
    // store the client format
    _info.clientFormat = clientFormat;
    
    // set the client format on the extended audio file ref
    [EZAudio checkResult:ExtAudioFileSetProperty(self.info.extAudioFileRef,
                                                 kExtAudioFileProperty_ClientDataFormat,
                                                 sizeof(clientFormat),
                                                 &clientFormat)
               operation:"Couldn't set client data format on file"];
}

//------------------------------------------------------------------------------

-(void) setWaveformResolution:(UInt32)waveformResolution
{
//  if( _waveformResolution != waveformResolution ){
//    _waveformResolution = waveformResolution;
//    if( _waveformData ){
//      free(_waveformData);
//      _waveformData = NULL;
//    }
//  }
}

//------------------------------------------------------------------------------

-(void)dealloc
{
    pthread_mutex_destroy(&_lock);
    [EZAudio checkResult:AudioFileClose(self.info.audioFileID) operation:"Failed to close audio file"];
    [EZAudio checkResult:ExtAudioFileDispose(self.info.extAudioFileRef) operation:"Failed to dispose of ext audio file"];
}

//------------------------------------------------------------------------------

@end
