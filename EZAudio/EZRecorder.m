//
//  EZRecorder.m
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

#import "EZRecorder.h"

#import "EZAudio.h"

@interface EZRecorder (){
    ExtAudioFileRef             _destinationFile;
    AudioFileTypeID             _destinationFileTypeID;
    CFURLRef                    _destinationFileURL;
    AudioStreamBasicDescription _destinationFormat;
    AudioStreamBasicDescription _sourceFormat;
}

@end

@implementation EZRecorder

#pragma mark - Initializers
-(EZRecorder*)initWithDestinationURL:(NSURL*)url
                        sourceFormat:(AudioStreamBasicDescription)sourceFormat
                 destinationFileType:(EZRecorderFileType)destinationFileType
{
    self = [super init];
    if( self )
    {
        // Set defaults
        _destinationFile        = NULL;
        _destinationFileURL     = (__bridge CFURLRef)url;
        _sourceFormat           = sourceFormat;
        _destinationFormat      = [EZRecorder recorderFormatForFileType:destinationFileType
                                                       withSourceFormat:_sourceFormat];
        _destinationFileTypeID  = [EZRecorder recorderFileTypeIdForFileType:destinationFileType
                                                           withSourceFormat:_sourceFormat];
        
        // Initializer the recorder instance
        [self _initializeRecorder];
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
+(AudioStreamBasicDescription)recorderFormatForFileType:(EZRecorderFileType)fileType
                                       withSourceFormat:(AudioStreamBasicDescription)sourceFormat
{
    AudioStreamBasicDescription asbd;
    switch ( fileType )
    {
        case EZRecorderFileTypeAIFF:
            asbd = [EZAudio AIFFFormatWithNumberOfChannels:sourceFormat.mChannelsPerFrame
                                                sampleRate:sourceFormat.mSampleRate];
            break;
        case EZRecorderFileTypeM4A:
            asbd = [EZAudio M4AFormatWithNumberOfChannels:sourceFormat.mChannelsPerFrame
                                               sampleRate:sourceFormat.mSampleRate];
            break;
            
        case EZRecorderFileTypeWAV:
            asbd = [EZAudio stereoFloatInterleavedFormatWithSampleRate:sourceFormat.mSampleRate];
            break;
            
        default:
            asbd = [EZAudio stereoCanonicalNonInterleavedFormatWithSampleRate:sourceFormat.mSampleRate];
            break;
    }
    return asbd;
}

+(AudioFileTypeID)recorderFileTypeIdForFileType:(EZRecorderFileType)fileType
                               withSourceFormat:(AudioStreamBasicDescription)sourceFormat
{
    AudioFileTypeID audioFileTypeID;
    switch ( fileType )
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

-(void)_initializeRecorder
{
    // Finish filling out the destination format description
    UInt32 propSize = sizeof(_destinationFormat);
    [EZAudio checkResult:AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                                0,
                                                NULL,
                                                &propSize,
                                                &_destinationFormat)
               operation:"Failed to fill out rest of destination format"];
    
    // Create the audio file
    [EZAudio checkResult:ExtAudioFileCreateWithURL(_destinationFileURL,
                                                   _destinationFileTypeID,
                                                   &_destinationFormat,
                                                   NULL,
                                                   kAudioFileFlags_EraseFile,
                                                   &_destinationFile)
               operation:"Failed to create audio file"];
    
    // Set the client format (which should be equal to the source format)
    [EZAudio checkResult:ExtAudioFileSetProperty(_destinationFile,
                                                 kExtAudioFileProperty_ClientDataFormat,
                                                 sizeof(_sourceFormat),
                                                 &_sourceFormat)
               operation:"Failed to set client format on recorded audio file"];
    
}

#pragma mark - Events
-(void)appendDataFromBufferList:(AudioBufferList *)bufferList
                 withBufferSize:(UInt32)bufferSize
{
    if( _destinationFile )
    {
        [EZAudio checkResult:ExtAudioFileWriteAsync(_destinationFile,
                                                    bufferSize,
                                                    bufferList)
                   operation:"Failed to write audio data to recorded audio file"];
    }
}

-(void)closeAudioFile
{
    if( _destinationFile )
    {
        // Dispose of the audio file reference
        [EZAudio checkResult:ExtAudioFileDispose(_destinationFile)
                   operation:"Failed to close audio file"];
        
        // Null out the file reference
        _destinationFile = NULL;
    }
}

-(NSURL *)url
{
    return (__bridge NSURL*)_destinationFileURL;
}

#pragma mark - Dealloc
-(void)dealloc
{
    [self closeAudioFile];
}

@end