![alt text](https://s3-us-west-1.amazonaws.com/ezaudio-media/EZAudioJumbo-Alt.png "EZAudioLogo")

#EZAudio
A simple, intuitive audio framework for iOS and OSX.

*The Official EZAudio Page:*
http://syedharisali.com/projects/EZAudio/getting-started

## Update
Thank you everyone for using EZAudio! Just an update - I'm working on a 1.0.0 production version of EZAudio that will contain a bunch of improvements in the API, feature an EZAudioPlayer, and hooks for the DOUAudioStreamer for visualizing remote streaming audio. To make the next version of EZAudio even better I encourage you all to email me your feedback, feature requests, and experiences using the framework. Thanks!

##Features
![alt text](https://s3-us-west-1.amazonaws.com/ezaudio-media/EZAudioSummary.png "EZAudioFeatures")

**Awesome Components**

I've designed six core components to allow you to immediately get your hands dirty recording, playing, and visualizing audio data. These components simply plug into each other and build on top of the high-performance, low-latency AudioUnits API and give you an easy to use API written in Objective-C instead of pure C.

[EZMicrophone](#EZMicrophone)

A microphone class that provides its delegate audio data from the default device microphone with one line of code.

[EZRecorder](#EZRecorder)

A recorder class that provides a quick and easy way to write audio files from any datasource.

[EZAudioFile](#EZAudioFile)

An audio file class that reads/seeks through audio files and provides useful delegate callbacks. 

[EZOutput](#EZOutput)

An output class that will playback any audio it is provided by its datasource. 

[EZAudioPlot](#EZAudioPlot)

A CoreGraphics-based audio waveform plot capable of visualizing any float array as a buffer or rolling plot.

[EZAudioPlotGL](#EZAudioPlotGL)

An OpenGL-based, GPU-accelerated audio waveform plot capable of visualizing any float array as a buffer or rolling plot.

**Cross Platform**

`EZAudio` was designed to work transparently across all iOS and OSX devices. This means one universal API whether you're building for Mac or iOS. For instance, under the hood an `EZAudioPlot` knows that it will subclass a UIView for iOS or an NSView for OSX and the `EZMicrophone` knows to build on top of the RemoteIO AudioUnit for iOS, but defaults to the system defaults for input and output for OSX.

##Examples & Docs

Within this repo you'll find the examples for iOS and OSX to get you up to speed using each component and plugging them into each other. With just a few lines of code you'll be recording from the microphone, generating audio waveforms, and playing audio files like a boss. See the full Getting Started guide for an interactive look into each of components.

### Example Projects

**_EZAudioCoreGraphicsWaveformExample_** 

Shows how to use the `EZMicrophone` and `EZAudioPlot` to visualize the audio data from the microphone in real-time. The waveform can be displayed as a buffer or a rolling waveform plot (traditional waveform look). 

**_EZAudioOpenGLWaveformExample_**

Shows how to use the `EZMicrophone` and `EZAudioPlotGL` to visualize the audio data from the microphone in real-time. The drawing is using OpenGL so it is much faster and like the first example can display a buffer or rolling waveform.

**_EZAudioPlayFileExample_**

Shows how to use the `EZAudioFile`, `EZOutput`, and `EZAudioPlotGL` to playback, pause, and seek through an audio file while displaying its waveform as a buffer or a rolling waveform plot.

**_EZAudioRecordWaveformExample_**

Shows how to use the `EZMicrophone`, `EZRecorder`, and `EZAudioPlotGL` to record the audio from the microphone input to a file while displaying the audio waveform of the incoming data. You can then playback the newly recorded audio file using AVFoundation and keep adding more audio data to the tail of the file.

**_EZAudioWaveformFromFileExample_**

Shows how to use the `EZAudioFile` and `EZAudioPlot` to display the audio waveform an entire audio file. 

**_EZAudioPassThroughExample_**

Shows how to use the `EZMicrophone`, `EZOutput`, and the `EZAudioPlotGL` to pass the microphone input to the output for playback while displaying the audio waveform (as a buffer or rolling plot) in real-time. 

**_EZAudioFFTExample_**

Shows how to calculate the real-time FFT of the audio data coming from the `EZMicrophone` and the Accelerate framework. The audio data is plotted using the `EZAudioPlotGL` for the time domain plot and the `EZAudioPlot` for the frequency domain plot. 

![alt text](https://s3-us-west-1.amazonaws.com/ezaudio-media/fftMacExample.png)

### Documentation
The official documentation for EZAudio can be found here: http://cocoadocs.org/docsets/EZAudio/0.0.3/
<br>You can also generate the docset yourself using appledocs by running the appledocs on the EZAudio source folder.

##Getting Started
*To see the full project page, interactive Getting Started guide, and Documentation go here:*
http://syedharisali.com/projects/EZAudio/getting-started

To begin using `EZAudio` you must first make sure you have the proper build requirements and frameworks. Below you'll find explanations of each component and code snippets to show how to use each to perform common tasks like getting microphone data, updating audio waveform plots, reading/seeking through audio files, and performing playback.

###Build Requirements
**iOS**
- 6.0+


**OSX**
- 10.8+

###Frameworks
**iOS**
- AudioToolbox
- AVFoundation
- GLKit


**OSX**
- AudioToolbox
- AudioUnit
- CoreAudio
- QuartzCore
- OpenGL
- GLKit

###Adding To Project
You can add EZAudio to your project in a few ways: <br><br>1.) The easiest way to use EZAudio is via <a href="http://cocoapods.org/", target="_blank">Cocoapods</a>. Simply add EZAudio to your <a href="http://guides.cocoapods.org/using/the-podfile.html", target="_blank">Podfile</a> like so:

`
pod 'EZAudio', '~> 0.0.4'
`

2.) Alternatively, you could clone or fork this repo and just drag and drop the source into your project. 

*For more information see main project page:*
http://syedharisali.com/projects/EZAudio/getting-started

##Core Components
`EZAudio` currently offers four components that encompass a wide range of audio functionality. In addition to the functional aspects of these components such as pulling audio data, reading/writing from files, and performing playback they also take special care to hook into the interface components to allow developers to display visual feedback (see the Interface Components below).

###<a name="EZAudioFile"></a>EZAudioFile
Provides simple read/seek operations, pulls waveform amplitude data, and provides the `EZAudioFileDelegate` to notify of any read/seek action occuring on the `EZAudioFile`.

**_Relevant Example Projects_**
- EZAudioPlayFileExample (iOS)
- EZAudioPlayFileExample (OSX)
- EZAudioWaveformFromFileExample (iOS)
- EZAudioWaveformFromFileExample (OSX)

####Opening An Audio File
To open an audio file create a new instance of the `EZAudioFile` class.
```objectivec
// Declare the EZAudioFile as a strong property
@property (nonatomic,strong) EZAudioFile *audioFile;

...

// Initialize the EZAudioFile instance and assign it a delegate to receive the read/seek callbacks
self.audioFile = [EZAudioFile audioFileWithURL:[NSURL fileURLWithPath:@"/path/to/your/file"] 
                                   andDelegate:self];
```

####Getting Waveform Data

There is a `getWaveformDataWithCompletionBlock:` method to allow you to easily and asynchronously get the waveform amplitude data that will best represent the whole audio file (will calculate the best fit that's constrainted to ~2048 data points)
```objectivec
// Get the waveform data from the audio file asynchronously 
[audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
  // Update the audio plot with the waveform data (use the EZPlotTypeBuffer in this case)
  self.audioPlot.plotType = EZPlotTypeBuffer;
  [self.audioPlot updateBuffer:waveformData withBufferSize:length];
}];
```

####Reading From An Audio File

Reading audio data from a file requires you to create an AudioBufferList to hold the data. The `EZAudio` utility function, `audioBufferList`, provides a convenient way to get an allocated AudioBufferList to use. There is also a utility function, `freeBufferList:`, to use to free (or release) the AudioBufferList when you are done using that audio data.

**Note: You have to free the AudioBufferList, even in ARC.**
```objectivec
// Allocate a buffer list to hold the file's data
UInt32          frames      = 512;
AudioBufferList *bufferList = [EZAudio audioBufferList];
UInt32          bufferSize; // Read function will populate this value
BOOL            eof;        // Read function will populate this value
// Reads 512 frames from the audio file
[audioFile readFrames:frames
      audioBufferList:bufferList
           bufferSize:&bufferSize
                  eof:&eof];
// Cleanup when done working with audio data (yes, even in ARC)
[EZAudio freeBufferList:bufferList];
```

When a read occurs the `EZAudioFileDelegate` receives two events.

An event notifying the delegate of the read audio data as float arrays:
```objectivec
// The EZAudioFile method `readFrames:audioBufferList:bufferSize:eof:` triggers an event notifying the delegate of the read audio data as float arrays
-(void)     audioFile:(EZAudioFile *)audioFile
            readAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels {
  // The audio data from the read as a float buffer. You can feed this into an audio plot!
  dispatch_async(dispatch_get_main_queue(), ^{
    // Update that audio plot!
    [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
  });
}
```
and an event notifying the delegate of the new frame position within the `EZAudioFile`:
```objectivec
// The EZAudioFile method `readFrames:audioBufferList:bufferSize:eof:` triggers an event notifying the delegate of the new frame position within the file.
-(void)audioFile:(EZAudioFile *)audioFile updatedPosition:(SInt64)framePosition {
  dispatch_async(dispatch_get_main_queue(), ^{
    // Move that slider to this new position!
  });
}
```

####Seeking Through An Audio File

You can seek very easily through an audio file using the `EZAudioFile`'s seekToFrame: method. The `EZAudioFile` provides a `totalFrames` method to provide you the total amount of frames in an audio file so you can calculate a proper offset.
```objectivec
// Get the total number of frames for the audio file
SInt64 totalFrames = [self.audioFile totalFrames];
// Seeks halfway through the audio file
[self.audioFile seekToFrame:(totalFrames/2)];
```
When a seek occurs the `EZAudioFileDelegate` receives the seek event:
```objectivec
// The EZAudioFile method `seekToFrame:` triggers an event notifying the delegate of the new frame position within the file.
-(void)audioFile:(EZAudioFile *)audioFile updatedPosition:(SInt64)framePosition {
  dispatch_async(dispatch_get_main_queue(), ^{
    // Move that slider to this new position!
  });
}
```
###<a name="EZMicrophone"></a>EZMicrophone
Provides access to the default device microphone in one line of code and provides delegate callbacks to receive the audio data as an AudioBufferList and float arrays.

**_Relevant Example Projects_**
- EZAudioCoreGraphicsWaveformExample (iOS)
- EZAudioCoreGraphicsWaveformExample (OSX)
- EZAudioOpenGLWaveformExample (iOS)
- EZAudioOpenGLWaveformExample (OSX)
- EZAudioRecordExample (iOS)
- EZAudioRecordExample (OSX)

####Creating A Microphone

Create an `EZMicrophone` instance by declaring a property and initializing it like so:

```objectivec
// Declare the EZMicrophone as a strong property
@property (nonatomic,strong) EZMicrophone *microphone;

...

// Initialize the microphone instance and assign it a delegate to receive the audio data callbacks
self.microphone = [EZMicrophone microphoneWithDelegate:self];
```
Alternatively, you could also use the shared `EZMicrophone` instance and just assign its `EZMicrophoneDelegate`.
```objectivec
// Assign a delegate to the shared instance of the microphone to receive the audio data callbacks
[EZMicrophone sharedMicrophone].microphoneDelegate = self;
```

####Getting Microphone Data

To tell the microphone to start fetching audio use the `startFetchingAudio` function.

```objectivec
// Starts fetching audio from the default device microphone and sends data to EZMicrophoneDelegate
[self.microphone startFetchingAudio];
```
Once the `EZMicrophone` has started it will send the `EZMicrophoneDelegate` the audio back in a few ways.
An array of float arrays:
```objectivec
/**
 The microphone data represented as float arrays useful for:
    - Creating real-time waveforms using EZAudioPlot or EZAudioPlotGL
    - Creating any number of custom visualizations that utilize audio!
 */
-(void)   microphone:(EZMicrophone *)microphone
    hasAudioReceived:(float **)buffer
      withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
  // Getting audio data as an array of float buffer arrays that can be fed into the EZAudioPlot, EZAudioPlotGL, or whatever visualization you would like to do with the microphone data.
  dispatch_async(dispatch_get_main_queue(),^{
    // Visualize this data brah, buffer[0] = left channel, buffer[1] = right channel
    [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
  });
}
```
or the AudioBufferList representation:
```objectivec
/**
 The microphone data represented as CoreAudio's AudioBufferList useful for:
    - Appending data to an audio file via the EZRecorder
    - Playback via the EZOutput
    
 */
-(void)    microphone:(EZMicrophone *)microphone
        hasBufferList:(AudioBufferList *)bufferList
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels {
    // Getting audio data as an AudioBufferList that can be directly fed into the EZRecorder or EZOutput. Say whattt...
}
```
####Pausing/Resuming The Microphone

Pause or resume fetching audio at any time like so:
```objectivec
// Stop fetching audio
[self.microphone stopFetchingAudio];

// Resume fetching audio
[self.microphone startFetchingAudio];
```
Alternatively, you could also toggle the `microphoneOn` property (safe to use with Cocoa Bindings)
```objectivec
// Stop fetching audio
self.microphone.microphoneOn = NO;

// Start fetching audio
self.microphone.microphoneOn = YES;
```

###<a name="EZOutput"></a>EZOutput
Provides flexible playback to the default output device by asking the `EZOutputDataSource` for audio data to play. Doesn't care where the buffers come from (microphone, audio file, streaming audio, etc). The `EZOutputDataSource` has three functions that can provide audio data for the output callback. You should implement only **ONE** of these functions:
```objectivec
// Full override of the audio callback 
-(void)           output:(EZOutput*)output
 callbackWithActionFlags:(AudioUnitRenderActionFlags*)ioActionFlags
             inTimeStamp:(const AudioTimeStamp*)inTimeStamp
             inBusNumber:(UInt32)inBusNumber
          inNumberFrames:(UInt32)inNumberFrames
                  ioData:(AudioBufferList*)ioData;
                 
// Provides the audio callback with a circular buffer holding the audio data
-(TPCircularBuffer*)outputShouldUseCircularBuffer:(EZOutput *)output;

// Provides the audio callback with a buffer list, number of frames, and buffer size to use
-(void)             output:(EZOutput *)output
 shouldFillAudioBufferList:(AudioBufferList *)audioBufferList
        withNumberOfFrames:(UInt32)frames;
```

**_Relevant Example Projects_**
- EZAudioPlayFileExample (iOS)
- EZAudioPlayFileExample (OSX)
- EZAudioPassThroughExample (iOS)
- EZAudioPassThroughExample (OSX)

####Creating An Output

Create an `EZOutput` by declaring a property and initializing it like so:

```objectivec
// Declare the EZOutput as a strong property
@property (nonatomic,strong) EZOutput *output;

...

// Initialize the EZOutput instance and assign it a delegate to provide the output audio data
self.output = [EZOutput outputWithDataSource:self];
```
Alternatively, you could also use the shared output instance and just assign it an `EZOutputDataSource`. This is the preferred way to use the `EZOutput` (usually just have one per app).
```objectivec
// Assign a delegate to the shared instance of the output to provide the output audio data
[EZOutput sharedOutput].outputDataSource = self;
```
####Playback Using An AudioBufferList

One method to play back audio is to provide an AudioBufferList (for instance, reading from an `EZAudioFile`):
```objectivec
// Use the AudioBufferList datasource method to read from an EZAudioFile
-(void)             output:(EZOutput *)output
 shouldFillAudioBufferList:(AudioBufferList *)audioBufferList
        withNumberOfFrames:(UInt32)frames
{
  if( self.audioFile )
  {
    UInt32 bufferSize;
    [self.audioFile readFrames:frames
               audioBufferList:audioBufferList
                    bufferSize:&bufferSize
                           eof:&_eof];
    if( _eof )
    {
      [self seekToFrame:0];
    }
  }
}
```
####Playback Using A Circular Buffer

Another method is to provide a circular buffer via Michael Tyson's (who, btw is a serious badass and also wrote the Amazing Audio Engine for iOS) TPCircularBuffer containing the data. For instance, for passing the microphone input to the output for a basic passthrough:
```objectivec
// Declare circular buffer as global
TPCircularBuffer circularBuffer;
...
// Using an EZMicrophone, append the AudioBufferList from the microphone callback to the global circular buffer
-(void)    microphone:(EZMicrophone *)microphone
        hasBufferList:(AudioBufferList *)bufferList
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels {
  /**
   Append the audio data to a circular buffer
   */
  [EZAudio appendDataToCircularBuffer:&circularBuffer
                  fromAudioBufferList:bufferList];
}
// Pass the circular buffer to the EZOutputDataSource using the circular buffer callback
-(TPCircularBuffer *)outputShouldUseCircularBuffer:(EZOutput *)output {
  return &circularBuffer;
}
```
####Playback By Manual Override

And the last method is to completely override the output callback method and populate the AudioBufferList however you can imagine:
```objectivec
// Completely override the output callback function
-(void)           output:(EZOutput *)output
 callbackWithActionFlags:(AudioUnitRenderActionFlags *)ioActionFlags
             inTimeStamp:(const AudioTimeStamp *)inTimeStamp
             inBusNumber:(UInt32)inBusNumber
          inNumberFrames:(UInt32)inNumberFrames
                  ioData:(AudioBufferList *)ioData {
 // Fill the ioData with your audio data from anywhere
}
```
###<a name="EZRecorder"></a>EZRecorder
Provides a way to record any audio source to an audio file. This hooks into the other components quite nicely to do something like plot the audio waveform while recording to give visual feedback as to what is happening.

*Relevant Example Projects*
- EZAudioRecordExample (iOS)
- EZAudioRecordExample (OSX)

####Creating A Recorder

To create an `EZRecorder` you must start with an AudioStreamBasicDescription, which is just a CoreAudio structure representing the audio format of a file. The `EZMicrophone` and `EZAudioFile` both provide the AudioStreamBasicDescription as properties (for the `EZAudioFile` use the clientFormat property) that you can use when initializing the `EZRecorder`.

```objectivec
// Declare the EZRecorder as a strong property
@property (nonatomic,strong) EZRecorder *recorder;

...

// Here's how we would initialize the recorder for an EZMicrophone instance
self.recorder = [EZRecorder recorderWithDestinationURL:[NSURL fileURLWithPath:@"path/to/file.caf"]
                                       andSourceFormat:microphone.audioStreamBasicDescription];
                                       
// Here's how we would initialize the recorder for an EZAudioFile instance
self.recorder = [EZRecorder recorderWithDestinationURL:[NSURL fileURLWithPath:@"path/to/file.caf"]
                                       andSourceFormat:audioFile.clientFormat];
```

##Recording Some Audio

Once you've initialized your `EZRecorder` you can append data by passing in an AudioBufferList and its buffer size like so:
```objectivec
// Append the microphone data coming as a AudioBufferList with the specified buffer size to the recorder
-(void)    microphone:(EZMicrophone *)microphone
        hasBufferList:(AudioBufferList *)bufferList
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels {
  // Getting audio data as a buffer list that can be directly fed into the EZRecorder. This is happening on the audio thread - any UI updating needs a GCD main queue block.
  if( self.isRecording ){
    [self.recorder appendDataFromBufferList:bufferList
                             withBufferSize:bufferSize];
  } 
}
```

###Interface Components
`EZAudio` currently offers two drop in audio waveform components that help simplify the process of visualizing audio.

###<a name="EZAudioPlot"></a>EZAudioPlot
Provides an audio waveform plot that uses CoreGraphics to perform the drawing. On iOS this is a subclass of UIView while on OSX this is a subclass of NSView. Best used on OSX as the drawing falls on the CPU and needs to redisplay after every audio data update, but useful in iOS apps for displaying full, static waveforms.

*Relevant Example Projects*
- EZAudioCoreGraphicsWaveformExample (iOS)
- EZAudioCoreGraphicsWaveformExample (OSX)

####Creating An Audio Plot

You can create an audio plot in the interface builder by dragging in a UIView on iOS or an NSView on OSX onto your content area. Then change the custom class of the UIView/NSView to `EZAudioPlot`.
See full Getting Started page for how to: http://syedharisali.com/projects/EZAudio/getting-started

Alternatively, you can could create the audio plot programmatically

```objectivec
// Programmatically create an audio plot
EZAudioPlot *audioPlot = [[EZAudioPlot alloc] initWithFrame:self.view.frame];
[self.view addSubview:audioPlot];
```

####Customizing The Audio Plot

All plots offer the ability to change the background color, waveform color, plot type (buffer or rolling), toggle between filled and stroked, and toggle between mirrored and unmirrored (about the x-axis). For iOS colors are of the type UIColor while on OSX colors are of the type NSColor.

```objectivec
// Background color (use UIColor for iOS)
audioPlot.backgroundColor = [NSColor colorWithCalibratedRed:0.816 
                                                      green:0.349 
                                                       blue:0.255 
                                                      alpha:1];
// Waveform color (use UIColor for iOS)
audioPlot.color = [NSColor colorWithCalibratedRed:1.000 
                                            green:1.000 
                                             blue:1.000
                                            alpha:1];
// Plot type
audioPlot.plotType     = EZPlotTypeBuffer;
// Fill
audioPlot.shouldFill   = YES;
// Mirror
audioPlot.shouldMirror = YES;
```

####Updating The Audio Plot

All plots have only one update function, `updateBuffer:withBufferSize:`, which expects a float array and its length.
```objectivec
// The microphone component provides audio data to its delegate as an array of float buffer arrays.
-(void)    microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels {
  /** 
   Update the audio plot using the float array provided by the microphone:
     buffer[0] = left channel
     buffer[1] = right channel
   Note: Audio updates happen asynchronously so we need to make sure
         sure to update the plot on the main thread
   */
  dispatch_async(dispatch_get_main_queue(),^{
    [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
  });
}
```

###<a name="EZAudioPlotGL"></a>EZAudioPlotGL
Provides an audio waveform plot that uses OpenGL to perform the drawing. The API this class are exactly the same as those for the EZAudioPlot above. On iOS this is a subclass of the EZPlot and uses an embedded GLKViewController to perform the OpenGL drawing while on OSX this is a subclass of the NSOpenGLView. In most cases this is the plot you want to use, it's GPU-accelerated, has a low memory footprint, and performs amazingly on all devices.

*Relevant Example Projects*
- EZAudioOpenGLWaveformExample (iOS)
- EZAudioOpenGLWaveformExample (OSX)

####Creating An OpenGL Audio Plot

You can create an audio plot in the interface builder by dragging in a UIView on iOS or an NSOpenGLView on OSX onto your content area. Then change the custom class of the UIView/NSView to `EZAudioPlotGL`.
See full Getting Started page for how to: http://syedharisali.com/projects/EZAudio/getting-started

Alternatively, you can could create the `EZAudioPlotGL` programmatically
```objectivec
// Programmatically create an audio plot
EZAudioPlotGL *audioPlotGL = [[EZAudioPlotGL alloc] initWithFrame:self.view.frame];
[self.view addSubview:audioPlotGL];
```

####Customizing The OpenGL Audio Plot

All plots offer the ability to change the background color, waveform color, plot type (buffer or rolling), toggle between filled and stroked, and toggle between mirrored and unmirrored (about the x-axis). For iOS colors are of the type UIColor while on OSX colors are of the type NSColor.
```objectivec
// Background color (use UIColor for iOS)
audioPlotGL.backgroundColor = [NSColor colorWithCalibratedRed:0.816 
                                                        green:0.349 
                                                         blue:0.255 
                                                        alpha:1];
// Waveform color (use UIColor for iOS)
audioPlotGL.color = [NSColor colorWithCalibratedRed:1.000 
                                              green:1.000 
                                               blue:1.000
                                              alpha:1];
// Plot type
audioPlotGL.plotType     = EZPlotTypeBuffer;
// Fill
audioPlotGL.shouldFill   = YES;
// Mirror
audioPlotGL.shouldMirror = YES;
```

####Updating The OpenGL Audio Plot

All plots have only one update function, `updateBuffer:withBufferSize:`, which expects a float array and its length.
```objectivec
// The microphone component provides audio data to its delegate as an array of float buffer arrays.
-(void)    microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels {
  /** 
   Update the audio plot using the float array provided by the microphone:
     buffer[0] = left channel
     buffer[1] = right channel
   Note: Audio updates happen asynchronously so we need to make sure
         sure to update the plot on the main thread
   */
  dispatch_async(dispatch_get_main_queue(),^{
    [self.audioPlotGL updateBuffer:buffer[0] withBufferSize:bufferSize];
  });
}
```

##License
EZAudio is available under the MIT license. See the LICENSE file for more info.

##Contact & Contributers
Syed Haris Ali<br>
www.syedharisali.com<br>
syedhali07[at]gmail.com

##Acknowledgements
EZAudio could not have been created without the invaluable help of:
- <a href="http://atastypixel.com/blog/">Michael Tyson</a> for creating the <a href="http://atastypixel.com/blog/a-simple-fast-circular-buffer-implementation-for-audio-processing/">TPCircularBuffer</a> and the <a href="http://theamazingaudioengine.com/">Amazing Audio Engine</a>'s `AEFloatConverter`.
- Chris Adamson and Kevin Avila for writing the amazing book <a href="http://www.amazon.com/Learning-Core-Audio-Hands-On-Programming/dp/0321636848">Learning Core Audio</a>
