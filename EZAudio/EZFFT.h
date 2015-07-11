//
//  EZFFT.h
//  PitchDetector
//
//  Created by Syed Haris Ali on 7/10/15.
//  Copyright (c) 2015 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@class EZFFT;

//------------------------------------------------------------------------------
#pragma mark - EZFFTDelegate
//------------------------------------------------------------------------------

/**
 <#Description#>
 */
@protocol EZFFTDelegate <NSObject>

@optional

///-----------------------------------------------------------
/// @name Getting FFT Output Data
///-----------------------------------------------------------

/**
 <#Description#>
 @param fft        <#fft description#>
 @param fftData    <#fftData description#>
 @param bufferSize <#bufferSize description#>
 */
- (void)        fft:(EZFFT *)fft
 updatedWithFFTData:(float *)fftData
         bufferSize:(vDSP_Length)bufferSize;

@end

//------------------------------------------------------------------------------
#pragma mark - EZFFT
//------------------------------------------------------------------------------

/**
 <#Description#>
 */
@interface EZFFT : NSObject

//------------------------------------------------------------------------------
#pragma mark - Initializers
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Initializers
///-----------------------------------------------------------

/**
 <#Description#>
 
 @param maximumBufferSize <#maximumBufferSize description#>
 @param sampleRate        <#sampleRate description#>
 
 @return <#return value description#>
 */
- (instancetype)initWithMaximumBufferSize:(vDSP_Length)maximumBufferSize
                               sampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 <#Description#>
 
 @param maximumBufferSize <#maximumBufferSize description#>
 @param sampleRate        <#sampleRate description#>
 @param delegate          <#delegate description#>
 
 @return <#return value description#>
 */
- (instancetype)initWithMaximumBufferSize:(vDSP_Length)maximumBufferSize
                               sampleRate:(float)sampleRate
                                 delegate:(id<EZFFTDelegate>)delegate;

//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------

///-----------------------------------------------------------
/// @name Class Initializers
///-----------------------------------------------------------

/**
 <#Description#>
 
 @param maximumBufferSize <#maximumBufferSize description#>
 @param sampleRate        <#sampleRate description#>
 
 @return <#return value description#>
 */
+ (instancetype)fftWithMaximumBufferSize:(vDSP_Length)maximumBufferSize
                              sampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 <#Description#>
 
 @param maximumBufferSize <#maximumBufferSize description#>
 @param sampleRate        <#sampleRate description#>
 @param delegate          <#delegate description#>
 
 @return <#return value description#>
 */
+ (instancetype)fftWithMaximumBufferSize:(vDSP_Length)maximumBufferSize
                              sampleRate:(float)sampleRate
                                delegate:(id<EZFFTDelegate>)delegate;

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 <#Description#>
 */
@property (weak, nonatomic) id<EZFFTDelegate> delegate;

/**
 <#Description#>
 */
@property (readonly, nonatomic) COMPLEX_SPLIT complexSplit;

/**
 <#Description#>
 */
@property (readonly, nonatomic) float *fftData;

/**
 <#Description#>
 */
@property (readonly, nonatomic) FFTSetup fftSetup;

/**
 <#Description#>
 */
@property (readonly, nonatomic) float *invertedFFTData;

/**
 <#Description#>
 */
@property (readonly, nonatomic) float maxFrequency;

/**
 <#Description#>
 */
@property (readonly, nonatomic) vDSP_Length maxFrequencyIndex;

/**
 <#Description#>
 */
@property (readonly, nonatomic) float maxFrequencyMagnitude;

/**
 <#Description#>
 */
@property (readonly, nonatomic) vDSP_Length maximumBufferSize;

/**
 <#Description#>
 */
@property (readwrite, nonatomic) float sampleRate;

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

/**
 <#Description#>
 @param buffer     <#buffer description#>
 @param bufferSize <#bufferSize description#>
 @return <#return value description#>
 */
- (float *)computeFFTWithBuffer:(float *)buffer withBufferSize:(UInt32)bufferSize;

//------------------------------------------------------------------------------
#pragma mark - Subclass
//------------------------------------------------------------------------------

/**
 <#Description#>
 */
- (void)setup;

@end

//------------------------------------------------------------------------------
#pragma mark - EZFFTRolling
//------------------------------------------------------------------------------

/**
 <#Description#>
 */
@interface EZFFTRolling : EZFFT

//------------------------------------------------------------------------------
#pragma mark - Initializers
//------------------------------------------------------------------------------

/**
 <#Description#>
 @param windowSize <#windowSize description#>
 @param sampleRate <#sampleRate description#>
 @return <#return value description#>
 */
- (instancetype)initWithWindowSize:(vDSP_Length)windowSize
                        sampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 <#Description#>
 
 @param windowSize <#windowSize description#>
 @param sampleRate <#sampleRate description#>
 @param delegate   <#delegate description#>
 
 @return <#return value description#>
 */
- (instancetype)initWithWindowSize:(vDSP_Length)windowSize
                        sampleRate:(float)sampleRate
                          delegate:(id<EZFFTDelegate>)delegate;

//------------------------------------------------------------------------------

/**
 <#Description#>
 
 @param windowSize        <#windowSize description#>
 @param historyBufferSize <#historyBufferSize description#>
 @param sampleRate        <#sampleRate description#>
 
 @return <#return value description#>
 */
- (instancetype)initWithWindowSize:(vDSP_Length)windowSize
                 historyBufferSize:(vDSP_Length)historyBufferSize
                        sampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 <#Description#>
 
 @param windowSize        <#windowSize description#>
 @param historyBufferSize <#historyBufferSize description#>
 @param sampleRate        <#sampleRate description#>
 @param delegate          <#delegate description#>
 
 @return <#return value description#>
 */
- (instancetype)initWithWindowSize:(vDSP_Length)windowSize
                 historyBufferSize:(vDSP_Length)historyBufferSize
                        sampleRate:(float)sampleRate
                          delegate:(id<EZFFTDelegate>)delegate;

//------------------------------------------------------------------------------
#pragma mark - Class Initializers
//------------------------------------------------------------------------------

/**
 <#Description#>
 
 @param windowSize <#windowSize description#>
 @param sampleRate <#sampleRate description#>
 
 @return <#return value description#>
 */
+ (instancetype)fftWithWindowSize:(vDSP_Length)windowSize
                       sampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 <#Description#>
 
 @param windowSize <#windowSize description#>
 @param sampleRate <#sampleRate description#>
 @param delegate   <#delegate description#>
 
 @return <#return value description#>
 */
+ (instancetype)fftWithWindowSize:(vDSP_Length)windowSize
                       sampleRate:(float)sampleRate
                         delegate:(id<EZFFTDelegate>)delegate;

//------------------------------------------------------------------------------

/**
 <#Description#>
 
 @param windowSize        <#windowSize description#>
 @param historyBufferSize <#historyBufferSize description#>
 @param sampleRate        <#sampleRate description#>
 
 @return <#return value description#>
 */
+ (instancetype)fftWithWindowSize:(vDSP_Length)windowSize
                historyBufferSize:(vDSP_Length)historyBufferSize
                       sampleRate:(float)sampleRate;

//------------------------------------------------------------------------------

/**
 <#Description#>
 
 @param windowSize        <#windowSize description#>
 @param historyBufferSize <#historyBufferSize description#>
 @param sampleRate        <#sampleRate description#>
 @param delegate          <#delegate description#>
 
 @return <#return value description#>
 */
+ (instancetype)fftWithWindowSize:(vDSP_Length)windowSize
                historyBufferSize:(vDSP_Length)historyBufferSize
                       sampleRate:(float)sampleRate
                         delegate:(id<EZFFTDelegate>)delegate;

//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------

/**
 <#Description#>
 */
@property (readonly, nonatomic) vDSP_Length windowSize;

//------------------------------------------------------------------------------

/**
 <#Description#>
 */
@property (readonly, nonatomic) float *timeDomainData;

//------------------------------------------------------------------------------

/**
 <#Description#>
 */
@property (readonly, nonatomic) UInt32 timeDomainBufferSize;

@end