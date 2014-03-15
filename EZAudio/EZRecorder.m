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
  AudioConverterRef           _audioConverter;
  AudioStreamBasicDescription _clientFormat;
  ExtAudioFileRef             _destinationFile;
  CFURLRef                    _destinationFileURL;
  AudioStreamBasicDescription _destinationFormat;
  AudioStreamBasicDescription _sourceFormat;
}

typedef struct {
  AudioBufferList *sourceBuffer;
} EZRecorderConverterStruct;

@end

@implementation EZRecorder

#pragma mark - Initializers
-(EZRecorder*)initWithDestinationURL:(NSURL*)url
                     andSourceFormat:(AudioStreamBasicDescription)sourceFormat {
  self = [super init];
  if(self){
    _destinationFileURL = (__bridge CFURLRef)url;
    _sourceFormat = sourceFormat;
    _destinationFormat = [EZRecorder defaultDestinationFormat];
    [self _configureRecorder];
  }
  return self;
}

#pragma mark - Class Initializers
+(EZRecorder*)recorderWithDestinationURL:(NSURL*)url
                         andSourceFormat:(AudioStreamBasicDescription)sourceFormat {
  return [[EZRecorder alloc] initWithDestinationURL:url
                                    andSourceFormat:sourceFormat];
}

#pragma mark - Getters
-(NSURL *)url {
  return (__bridge NSURL *)(_destinationFileURL);
}

#pragma mark - Class Format Helper
+(AudioStreamBasicDescription)defaultDestinationFormat {
  AudioStreamBasicDescription destinationFormat = [EZAudio stereoFloatInterleavedFormatWithSampleRate:44100.0];
  return destinationFormat;
}

+(NSString *)defaultDestinationFormatExtension {
  return @"caf";
}

#pragma mark - Private Configuation
-(void)_configureRecorderForExistingFile {
  
}

-(void)_configureRecorderForNewFile {
  
}

-(void)_configureRecorder {
  
//  // Create the extended audio file
//  OSStatus result = ExtAudioFileCreateWithURL(_destinationFileURL,
//                                              kAudioFileCAFType,
//                                              &_destinationFormat,
//                                              NULL,
//                                              0,
//                                              &_destinationFile);
  [EZAudio checkResult:ExtAudioFileCreateWithURL(_destinationFileURL,
                                              kAudioFileCAFType,
                                              &_destinationFormat,
                                              NULL,
                                              kAudioFileFlags_EraseFile,
                                              &_destinationFile)
             operation:"Could not open audio file"];

//  if( result != noErr )
//  {
//    
//    // Open the existing audio file for writing
//    AudioFileID audioFileID;
//
//    [EZAudio checkResult:AudioFileOpenURL(_destinationFileURL,
//                                          kAudioFileWritePermission|kAudioFileReadPermission,
//                                          kAudioFileCAFType,
//                                          &audioFileID)
//               operation:"Failed to open existing audio file"];
//    
//    // Wrap the audio file with an extended audio file reference
//    [EZAudio checkResult:ExtAudioFileWrapAudioFileID(audioFileID,
//                                                     true,
//                                                     &_destinationFile)
//               operation:"Failed to wrap audio file reference with extended audio file"];
//    
//  }
  
  // Set the client format
  _clientFormat = _destinationFormat;
  if( _destinationFormat.mFormatID != kAudioFormatLinearPCM ){
    [EZAudio setCanonicalAudioStreamBasicDescription:_destinationFormat
                                    numberOfChannels:_destinationFormat.mChannelsPerFrame
                                         interleaved:YES];
  }
  
  UInt32 propertySize = sizeof(_clientFormat);
  [EZAudio checkResult:ExtAudioFileSetProperty(_destinationFile,
                                               kExtAudioFileProperty_ClientDataFormat,
                                               propertySize,
                                               &_clientFormat)
             operation:"Failed to set client data format on destination file"];
  
  // Instantiate the writer
  [EZAudio checkResult:ExtAudioFileWriteAsync(_destinationFile, 0, NULL)
             operation:"Failed to initialize with ExtAudioFileWriteAsync"];
  
  // Setup the audio converter
  [EZAudio checkResult:AudioConverterNew(&_sourceFormat, &_clientFormat, &_audioConverter)
             operation:"Failed to create new audio converter"];
  
}

#pragma mark - Events
-(void)appendDataFromBufferList:(AudioBufferList*)bufferList
                 withBufferSize:(UInt32)bufferSize {
  
  // Setup output buffers
  AudioBufferList *convertedData = [EZAudio audioBufferListWithNumberOfFrames:bufferSize
                                                             numberOfChannels:_clientFormat.mChannelsPerFrame
                                                                  interleaved:!(_clientFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved)];
  
  [EZAudio checkResult:AudioConverterFillComplexBuffer(_audioConverter,
                                                       complexInputDataProc,
                                                       &(EZRecorderConverterStruct){ .sourceBuffer = bufferList },
                                                       &bufferSize,
                                                       convertedData,
                                                       NULL)
             operation:"Failed while converting buffers"];
  
  // Write the destination audio buffer list into t
  [EZAudio checkResult:ExtAudioFileWriteAsync(_destinationFile,bufferSize,convertedData)
             operation:"Failed to write audio data to file"];
  
  // Free resources
  [EZAudio freeBufferList:convertedData];
  
}

-(void)closeAudioFile {
  if( _destinationFile ){
    [EZAudio checkResult:ExtAudioFileDispose(_destinationFile)
               operation:"Failed to close audio file for recorder"];
    _destinationFile = NULL;
  }
}

#pragma mark - Converter Processing
static OSStatus complexInputDataProc(AudioConverterRef             inAudioConverter,
                                     UInt32                        *ioNumberDataPackets,
                                     AudioBufferList               *ioData,
                                     AudioStreamPacketDescription  **outDataPacketDescription,
                                     void                          *inUserData) {
  EZRecorderConverterStruct *recorderStruct = (EZRecorderConverterStruct*)inUserData;
  
  if ( !recorderStruct->sourceBuffer ) {
    return -2222; // No More Data
  }

  memcpy(ioData,
         recorderStruct->sourceBuffer,
         sizeof(AudioBufferList)+(recorderStruct->sourceBuffer->mNumberBuffers-1)*sizeof(AudioBuffer));
  recorderStruct->sourceBuffer = NULL;
  
  return noErr;
}

#pragma mark - Cleanup
-(void)dealloc {
  if( _audioConverter )
  {
    [EZAudio checkResult:AudioConverterDispose(_audioConverter)
               operation:"Failed to dispose audio converter in recorder"];
  }
  if( _destinationFile )
  {
    [EZAudio checkResult:ExtAudioFileDispose(_destinationFile)
               operation:"Failed to dispose extended audio file in recorder"];
  }
}

@end
