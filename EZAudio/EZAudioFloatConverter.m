//
//  EZAudioFloatConverter.m
//  EZAudioPlayFileExample
//
//  Created by Syed Haris Ali on 2/14/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import "EZAudioFloatConverter.h"
#import "EZAudioUtilities.h"

//------------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------------

static UInt32 EZAudioFloatConverterDefaultOutputBufferSize = 128 * 32;
UInt32 const EZAudioFloatConverterDefaultPacketSize = 2048;

//------------------------------------------------------------------------------
#pragma mark - Data Structures
//------------------------------------------------------------------------------

typedef struct
{
    AudioConverterRef             converterRef;
    AudioBufferList              *floatAudioBufferList;
    AudioStreamBasicDescription   inputFormat;
    AudioStreamBasicDescription   outputFormat;
    AudioStreamPacketDescription *packetDescriptions;
    UInt32 packetsPerBuffer;
} EZAudioFloatConverterInfo;

//------------------------------------------------------------------------------
#pragma mark - Callbacks
//------------------------------------------------------------------------------

OSStatus EZAudioFloatConverterCallback(AudioConverterRef             inAudioConverter,
                                       UInt32                       *ioNumberDataPackets,
                                       AudioBufferList              *ioData,
                                       AudioStreamPacketDescription **outDataPacketDescription,
                                       void                         *inUserData)
{
    AudioBufferList *sourceBuffer = (AudioBufferList *)inUserData;
    memcpy(ioData,
           sourceBuffer,
           sizeof(AudioBufferList) + (sourceBuffer->mNumberBuffers - 1)*sizeof(AudioBuffer));
    return noErr;
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioFloatConverter (Interface Extension)
//------------------------------------------------------------------------------

@interface EZAudioFloatConverter ()
@property (nonatomic, assign) EZAudioFloatConverterInfo info;
@end

//------------------------------------------------------------------------------
#pragma mark - EZAudioFloatConverter (Implementation)
//------------------------------------------------------------------------------

@implementation EZAudioFloatConverter

//------------------------------------------------------------------------------
#pragma mark - Class Methods
//------------------------------------------------------------------------------

+ (instancetype)converterWithInputFormat:(AudioStreamBasicDescription)inputFormat
{
    return [[self alloc] initWithInputFormat:inputFormat];
}

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    free(self.info.packetDescriptions);
    [EZAudioUtilities freeBufferList:self.info.floatAudioBufferList];
}

//------------------------------------------------------------------------------
#pragma mark - Initialization
//------------------------------------------------------------------------------

- (instancetype)initWithInputFormat:(AudioStreamBasicDescription)inputFormat
{
    self = [super init];
    if (self)
    {
        EZAudioFloatConverterInfo info;
        memset(&info, 0, sizeof(info));
        info.inputFormat = inputFormat;
        info.outputFormat = [EZAudioUtilities floatFormatWithNumberOfChannels:inputFormat.mChannelsPerFrame
                                                                   sampleRate:inputFormat.mSampleRate];
        
        // get max packets per buffer so you can allocate a proper AudioBufferList
        UInt32 packetsPerBuffer = 0;
        UInt32 outputBufferSize = EZAudioFloatConverterDefaultOutputBufferSize;
        UInt32 sizePerPacket = info.inputFormat.mBytesPerPacket;
        BOOL isVBR = sizePerPacket == 0;
        
        // VBR
        if (isVBR)
        {
            // determine the max output buffer size
            UInt32 maxOutputPacketSize;
            UInt32 propSize = sizeof(maxOutputPacketSize);
            OSStatus result = AudioConverterGetProperty(info.converterRef,
                                                        kAudioConverterPropertyMaximumOutputPacketSize,
                                                        &propSize,
                                                        &maxOutputPacketSize);
            if (result != noErr)
            {
                maxOutputPacketSize = EZAudioFloatConverterDefaultPacketSize;
            }
            
            // set the output buffer size to at least the max output size
            if (maxOutputPacketSize > outputBufferSize)
            {
                outputBufferSize = maxOutputPacketSize;
            }
            packetsPerBuffer = outputBufferSize / maxOutputPacketSize;
            
            // allocate memory for the packet descriptions
            info.packetDescriptions = (AudioStreamPacketDescription *)malloc(sizeof(AudioStreamPacketDescription) * packetsPerBuffer);
        }
        else
        {
            packetsPerBuffer = outputBufferSize / sizePerPacket;
        }
        info.packetsPerBuffer = packetsPerBuffer;
        
        // allocate the AudioBufferList to hold the float values
        BOOL isInterleaved = [EZAudioUtilities isInterleaved:info.outputFormat];
        info.floatAudioBufferList = [EZAudioUtilities audioBufferListWithNumberOfFrames:packetsPerBuffer
                                                                       numberOfChannels:info.outputFormat.mChannelsPerFrame
                                                                            interleaved:isInterleaved];

        self.info = info;
        [self setup];
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark - Setup
//------------------------------------------------------------------------------

- (void)setup
{
    // create a new instance of the audio converter
    [EZAudioUtilities checkResult:AudioConverterNew(&_info.inputFormat,
                                                    &_info.outputFormat,
                                                    &_info.converterRef)
                        operation:"Failed to create new audio converter"];
}

//------------------------------------------------------------------------------
#pragma mark - Events
//------------------------------------------------------------------------------

- (void)convertDataFromAudioBufferList:(AudioBufferList *)audioBufferList
                    withNumberOfFrames:(UInt32)frames
                        toFloatBuffers:(float **)buffers
{
    [self convertDataFromAudioBufferList:audioBufferList
                      withNumberOfFrames:frames
                          toFloatBuffers:buffers
                      packetDescriptions:self.info.packetDescriptions];
}

//------------------------------------------------------------------------------

- (void)convertDataFromAudioBufferList:(AudioBufferList *)audioBufferList
                    withNumberOfFrames:(UInt32)frames
                        toFloatBuffers:(float **)buffers
                    packetDescriptions:(AudioStreamPacketDescription *)packetDescriptions
{
    EZAudioFloatConverterInfo info = self.info;
    if (frames == 0)
    {
        
    }
    else
    {
        [EZAudioUtilities checkResult:AudioConverterFillComplexBuffer(info.converterRef,
                                                                      EZAudioFloatConverterCallback,
                                                                      audioBufferList,
                                                                      &frames,
                                                                      info.floatAudioBufferList,
                                                                      packetDescriptions ? packetDescriptions : info.packetDescriptions)
                            operation:"Failed to fill complex buffer in float converter"];
        for (int i = 0; i < info.floatAudioBufferList->mNumberBuffers; i++)
        {
            memcpy(buffers[i],
                   info.floatAudioBufferList->mBuffers[i].mData,
                   info.floatAudioBufferList->mBuffers[i].mDataByteSize);
        }
    }
}

//------------------------------------------------------------------------------

@end