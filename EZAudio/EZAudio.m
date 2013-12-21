//
//  EZAudio.m
//  EZAudio
//
//  Created by Syed Haris Ali on 11/21/13.
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

#import "EZAudio.h"

@implementation EZAudio

#pragma mark - AudioBufferList Utility
+(AudioBufferList *)audioBufferList {
  return (AudioBufferList*)malloc(sizeof(AudioBufferList));
}

+(void)freeBufferList:(AudioBufferList *)bufferList {
  if( bufferList ){
    for( int i = 0; i < bufferList->mNumberBuffers; i++ ){
      if( bufferList->mBuffers[i].mData ){
        free(bufferList->mBuffers[i].mData);
      }
    }
    free(bufferList);
  }
}

#pragma mark - AudioStreamBasicDescription Utility
+(void)printASBD:(AudioStreamBasicDescription)asbd {
  char formatIDString[5];
  UInt32 formatID = CFSwapInt32HostToBig(asbd.mFormatID);
  bcopy (&formatID, formatIDString, 4);
  formatIDString[4] = '\0';
  NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
  NSLog (@"  Format ID:           %10s",    formatIDString);
  NSLog (@"  Format Flags:        %10X",    (unsigned int)asbd.mFormatFlags);
  NSLog (@"  Bytes per Packet:    %10d",    (unsigned int)asbd.mBytesPerPacket);
  NSLog (@"  Frames per Packet:   %10d",    (unsigned int)asbd.mFramesPerPacket);
  NSLog (@"  Bytes per Frame:     %10d",    (unsigned int)asbd.mBytesPerFrame);
  NSLog (@"  Channels per Frame:  %10d",    (unsigned int)asbd.mChannelsPerFrame);
  NSLog (@"  Bits per Channel:    %10d",    (unsigned int)asbd.mBitsPerChannel);
}

+(void)setCanonicalAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd
                              numberOfChannels:(UInt32)nChannels
                                   interleaved:(BOOL)interleaved {
  asbd.mFormatID = kAudioFormatLinearPCM;
  int sampleSize = ((UInt32)sizeof(AudioSampleType));
  asbd.mFormatFlags = kAudioFormatFlagsCanonical;
  asbd.mBitsPerChannel = 8 * sampleSize;
  asbd.mChannelsPerFrame = nChannels;
  asbd.mFramesPerPacket = 1;
  if (interleaved)
    asbd.mBytesPerPacket = asbd.mBytesPerFrame = nChannels * sampleSize;
  else {
    asbd.mBytesPerPacket = asbd.mBytesPerFrame = sampleSize;
    asbd.mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
  }
}

#pragma mark - OSStatus Utility
+(void)checkResult:(OSStatus)result
         operation:(const char *)operation {
	if (result == noErr) return;
	char errorString[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(result);
	if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
		errorString[0] = errorString[5] = '\'';
		errorString[6] = '\0';
	} else
		// no, format it as an integer
		sprintf(errorString, "%d", (int)result);
	fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
	exit(1);
}

#pragma mark - Math Utility
+(float)MAP:(float)value
    leftMin:(float)leftMin
    leftMax:(float)leftMax
   rightMin:(float)rightMin
   rightMax:(float)rightMax {
  float leftSpan    = leftMax  - leftMin;
  float rightSpan   = rightMax - rightMin;
  float valueScaled = ( value  - leftMin ) / leftSpan;
  return rightMin + (valueScaled * rightSpan);
}

+(float)RMS:(float *)buffer
     length:(int)bufferSize {
  float sum = 0.0;
  for(int i = 0; i < bufferSize; i++)
    sum += buffer[i] * buffer[i];
  return sqrtf( sum / bufferSize );
}

#pragma mark - TPCircularBuffer Utility
+(void)circularBuffer:(TPCircularBuffer *)circularBuffer withSize:(int)size {
  TPCircularBufferInit(circularBuffer,size);
}

+(void)appendDataToCircularBuffer:(TPCircularBuffer*)circularBuffer
              fromAudioBufferList:(AudioBufferList*)audioBufferList {
  TPCircularBufferProduceBytes(circularBuffer,
                               audioBufferList->mBuffers[0].mData,
                               audioBufferList->mBuffers[0].mDataByteSize);
}

+(void)freeCircularBuffer:(TPCircularBuffer *)circularBuffer {
  TPCircularBufferClear(circularBuffer);
}

@end