//
//  EZRecorder.h
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

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/**
 To ensure valid recording formats are used when recording to a file the EZRecorderFileType describes the most common file types that a file can be encoded in. Each of these types can be used to output recordings as such:
 
 EZRecorderFileTypeAIFF - .aif, .aiff, .aifc, .aac
 EZRecorderFileTypeM4A  - .m4a, .mp4
 EZRecorderFileTypeWAV  - .wav
 
 */
typedef NS_ENUM(NSInteger, EZRecorderFileType)
{
    /**
     Recording format that describes AIFF file types. These are uncompressed, LPCM files that are completely lossless, but are large in file size.
     */
    EZRecorderFileTypeAIFF,
    /**
     Recording format that describes M4A file types. These are compressed, but yield great results especially when file size is an issue.
     */
    EZRecorderFileTypeM4A,
    /**
     Recording format that describes WAV file types. These are uncompressed, LPCM files that are completely lossless, but are large in file size.
     */
    EZRecorderFileTypeWAV
};

/**
 The EZRecorder provides a flexible way to create an audio file and append raw audio data to it. The EZRecorder will convert the incoming audio on the fly to the destination format so no conversion is needed between this and any other component. Right now the only supported output format is 'caf'. Each output file should have its own EZRecorder instance (think 1 EZRecorder = 1 audio file).
 */
@interface EZRecorder : NSObject

#pragma mark - Initializers
///-----------------------------------------------------------
/// @name Initializers
///-----------------------------------------------------------

/**
 Creates a new instance of an EZRecorder using a destination file path URL and the source format of the incoming audio.
 @param url                 An NSURL specifying the file path location of where the audio file should be written to.
 @param sourceFormat        The AudioStreamBasicDescription for the incoming audio that will be written to the file.
 @param destinationFileType A constant described by the EZRecorderFileType that corresponds to the type of destination file that should be written. For instance, an AAC file written using an '.m4a' extension would correspond to EZRecorderFileTypeM4A. See EZRecorderFileType for all the constants and mapping combinations.
 @return The newly created EZRecorder instance.
 */
-(instancetype)initWithDestinationURL:(NSURL*)url
                        sourceFormat:(AudioStreamBasicDescription)sourceFormat
                 destinationFileType:(EZRecorderFileType)destinationFileType;


#pragma mark - Class Initializers
///-----------------------------------------------------------
/// @name Class Initializers
///-----------------------------------------------------------

/**
 Class method to create a new instance of an EZRecorder using a destination file path URL and the source format of the incoming audio.
 @param url                 An NSURL specifying the file path location of where the audio file should be written to.
 @param sourceFormat        The AudioStreamBasicDescription for the incoming audio that will be written to the file.
 @param destinationFileType A constant described by the EZRecorderFileType that corresponds to the type of destination file that should be written. For instance, an AAC file written using an '.m4a' extension would correspond to EZRecorderFileTypeM4A. See EZRecorderFileType for all the constants and mapping combinations.
 @return The newly created EZRecorder instance.
 */
+(instancetype)recorderWithDestinationURL:(NSURL*)url
                            sourceFormat:(AudioStreamBasicDescription)sourceFormat
                     destinationFileType:(EZRecorderFileType)destinationFileType;

//------------------------------------------------------------------------------
#pragma mark - Getters
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Getting The Recorder's Properties
///-----------------------------------------------------------

//------------------------------------------------------------------------------

/**
 Provides the current offset in the audio file as an NSTimeInterval (i.e. in seconds).  When setting this it will determine the correct frame offset and perform a `seekToFrame` to the new time offset.
 @warning Make sure the new current time offset is less than the `duration` or you will receive an invalid seek assertion.
 */
@property (nonatomic, readwrite) NSTimeInterval currentTime;

//------------------------------------------------------------------------------

/**
 Provides the duration of the audio file in seconds.
 */
@property (readonly) NSTimeInterval duration;
//------------------------------------------------------------------------------

/**
 Provides the current time as an NSString with the time format MM:SS.
 */
@property (readonly) NSString *formattedCurrentTime;

//------------------------------------------------------------------------------

/**
 Provides the duration as an NSString with the time format MM:SS.
 */
@property (readonly) NSString *formattedDuration;

//------------------------------------------------------------------------------

/**
 Provides the frame index (a.k.a the seek positon) within the audio file as SInt64. This can be helpful when seeking through the audio file.
 @return The current frame index within the audio file as a SInt64.
 */
@property (readonly) SInt64 frameIndex;
//------------------------------------------------------------------------------

/**
 Provides the total frame count of the audio file in the file format.
 @return The total number of frames in the audio file in the AudioStreamBasicDescription representing the file format as a SInt64.
 */
@property (readonly) SInt64 totalFrames;

//------------------------------------------------------------------------------

/**
 Provides the file path that's currently being used by the recorder.
 @return  The NSURL representing the file path of the audio file path being used for recording.
 */
- (NSURL *)url;

#pragma mark - Events
///-----------------------------------------------------------
/// @name Appending Data To The Audio File
///-----------------------------------------------------------

/**
 Appends audio data to the tail of the output file from an AudioBufferList.
 @param bufferList The AudioBufferList holding the audio data to append
 @param bufferSize The size of each of the buffers in the buffer list.
 */
-(void)appendDataFromBufferList:(AudioBufferList*)bufferList
                 withBufferSize:(UInt32)bufferSize;

///-----------------------------------------------------------
/// @name Closing The Audio File
///-----------------------------------------------------------

/**
 Finishes writes to the audio file and closes it.
 */
-(void)closeAudioFile;

//------------------------------------------------------------------------------
#pragma mark - Subclass
//------------------------------------------------------------------------------

/**
 By default the output file is written out with 2 channels (so whatever the 
 @return <#return value description#>
 */
- (int)numberOfChannels;

@end