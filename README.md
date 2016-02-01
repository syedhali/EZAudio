![alt text](http://i.imgur.com/ll5q68r.png "EZAudioLogo")

A simple, intuitive audio framework for iOS and OSX.

## Welcome to 1.0.0!
Thank you guys for being so patient over the last year - I've been working like crazy the last few weeks rewriting and extending the EZAudio core and interface components and squashing bugs. Finally, EZAudio is now at its 1.0.0 release with all new updated components, examples, and documentation. Happy coding!

## Apps Using EZAudio
I'd really like to start creating a list of projects made using EZAudio. If you've used EZAudio to make something cool, whether it's an app or open source visualization or whatever, please email me at syedhali07[at]gmail.com and I'll add it to our wall of fame!
To start it off:
- [Detour](https://www.detour.com/) - Gorgeous location-aware audio walks
- [Jumpshare](https://jumpshare.com/) - Incredibly fast, real-time file sharing

##Features

**Awesome Components**

I've designed six audio components and two interface components to allow you to immediately get your hands dirty recording, playing, and visualizing audio data. These components simply plug into each other and build on top of the high-performance, low-latency AudioUnits API and give you an easy to use API written in Objective-C instead of pure C.

[EZAudioDevice](#EZAudioDevice)

A useful class for getting all the current and available inputs/output on any Apple device. The `EZMicrophone`  and `EZOutput` use this to direct sound in/out from different hardware components.

[EZMicrophone](#EZMicrophone)

A microphone class that provides its delegate audio data from the default device microphone with one line of code.

[EZOutput](#EZOutput)

An output class that will playback any audio it is provided by its datasource.

[EZAudioFile](#EZAudioFile)

An audio file class that reads/seeks through audio files and provides useful delegate callbacks.

[EZAudioPlayer](#EZAudioPlayer)

A replacement for `AVAudioPlayer` that combines an `EZAudioFile` and a `EZOutput` to perform robust playback of any file on any piece of hardware.

[EZRecorder](#EZRecorder)

A recorder class that provides a quick and easy way to write audio files from any datasource.

[EZAudioPlot](#EZAudioPlot)

A Core Graphics-based audio waveform plot capable of visualizing any float array as a buffer or rolling plot.

[EZAudioPlotGL](#EZAudioPlotGL)

An OpenGL-based, GPU-accelerated audio waveform plot capable of visualizing any float array as a buffer or rolling plot.

**Cross Platform**

`EZAudio` was designed to work transparently across all iOS and OSX devices. This means one universal API whether you're building for Mac or iOS. For instance, under the hood an `EZAudioPlot` knows that it will subclass a UIView for iOS or an NSView for OSX and the `EZMicrophone` knows to build on top of the RemoteIO AudioUnit for iOS, but defaults to the system defaults for input and output for OSX.

##<a name="Examples">Examples & Docs

Within this repo you'll find the examples for iOS and OSX to get you up to speed using each component and plugging them into each other. With just a few lines of code you'll be recording from the microphone, generating audio waveforms, and playing audio files like a boss. See the full Getting Started guide for an interactive look into each of components.

### Example Projects

**_EZAudioCoreGraphicsWaveformExample_**

![CoreGraphicsWaveformExampleGif](https://cloud.githubusercontent.com/assets/1275640/8516226/1eb885ec-2366-11e5-8d76-3a4b4d982eb0.gif)

Shows how to use the `EZMicrophone` and `EZAudioPlot` to visualize the audio data from the microphone in real-time. The waveform can be displayed as a buffer or a rolling waveform plot (traditional waveform look).

**_EZAudioOpenGLWaveformExample_**

![OpenGLWaveformExampleGif](https://cloud.githubusercontent.com/assets/1275640/8516234/499f6fd2-2366-11e5-9771-7d0afae59391.gif)

Shows how to use the `EZMicrophone` and `EZAudioPlotGL` to visualize the audio data from the microphone in real-time. The drawing is using OpenGL so the performance much better for plots needing a lot of points.

**_EZAudioPlayFileExample_**

![PlayFileExample](https://cloud.githubusercontent.com/assets/1275640/8516245/711ca232-2366-11e5-8d20-2538164f3307.gif)

Shows how to use the `EZAudioPlayer` and `EZAudioPlotGL` to playback, pause, and seek through an audio file while displaying its waveform as a buffer or a rolling waveform plot.

**_EZAudioRecordWaveformExample_**

![RecordWaveformExample](https://cloud.githubusercontent.com/assets/1275640/8516310/86da80f2-2367-11e5-84aa-aea25a439a76.gif)

Shows how to use the `EZMicrophone`, `EZRecorder`, and `EZAudioPlotGL` to record the audio from the microphone input to a file while displaying the audio waveform of the incoming data. You can then playback the newly recorded audio file using AVFoundation and keep adding more audio data to the tail of the file.

**_EZAudioWaveformFromFileExample_**

![WaveformExample](https://cloud.githubusercontent.com/assets/1275640/8516597/f27240ea-236a-11e5-8ecd-68cf05b7ce40.gif)

Shows how to use the `EZAudioFile` and `EZAudioPlot` to animate in an audio waveform for an entire audio file.

**_EZAudioPassThroughExample_**

![PassthroughExample](https://cloud.githubusercontent.com/assets/1275640/8516692/7abfbe36-236c-11e5-9d69-4f82956177b3.gif)

Shows how to use the `EZMicrophone`, `EZOutput`, and the `EZAudioPlotGL` to pass the microphone input to the output for playback while displaying the audio waveform (as a buffer or rolling plot) in real-time.

**_EZAudioFFTExample_**

![FFTExample](https://cloud.githubusercontent.com/assets/1275640/8662077/5621705a-2971-11e5-88ed-9a865e422ade.gif)

Shows how to calculate the real-time FFT of the audio data coming from the `EZMicrophone` and the Accelerate framework. The audio data is plotted using two `EZAudioPlots` for the time and frequency displays.

### Documentation
The official documentation for EZAudio can be found here: http://cocoadocs.org/docsets/EZAudio/1.1.4/
<br>You can also generate the docset yourself using appledocs by running the appledocs on the EZAudio source folder.

##<a name="GettingStarted">Getting Started
To begin using `EZAudio` you must first make sure you have the proper build requirements and frameworks. Below you'll find explanations of each component and code snippets to show how to use each to perform common tasks like getting microphone data, updating audio waveform plots, reading/seeking through audio files, and performing playback.

###Build Requirements
**iOS**
- 6.0+

**OSX**
- 10.8+

###Frameworks
**iOS**
- Accelerate
- AudioToolbox
- AVFoundation
- GLKit

**OSX**
- Accelerate
- AudioToolbox
- AudioUnit
- CoreAudio
- QuartzCore
- OpenGL
- GLKit

###<a name="AddingToProject">Adding To Project
You can add EZAudio to your project in a few ways: <br><br>1.) The easiest way to use EZAudio is via <a href="http://cocoapods.org/", target="_blank">Cocoapods</a>. Simply add EZAudio to your <a href="http://guides.cocoapods.org/using/the-podfile.html", target="_blank">Podfile</a> like so:

`
pod 'EZAudio', '~> 1.1.4'
`

####<a name="AmazingAudioEngineCocoapod">Using EZAudio & The Amazing Audio Engine
If you're also using the Amazing Audio Engine then use the `EZAudio/Core` subspec like so:

`
pod 'EZAudio/Core', '~> 1.1.4'
`

2.) EZAudio now supports Carthage (thanks Andrew and Tommaso!). You can refer to Carthage's installation for a how-to guide:
https://github.com/Carthage/Carthage

3.) Alternatively, you can check out the iOS/Mac examples for how to setup a project using the EZAudio project as an embedded project and utilizing the frameworks. Be sure to set your header search path to the folder containing the EZAudio source.

##<a name="CoreComponents"></a>Core Components

`EZAudio` currently offers six audio components that encompass a wide range of functionality. In addition to the functional aspects of these components such as pulling audio data, reading/writing from files, and performing playback they also take special care to hook into the interface components to allow developers to display visual feedback (see the [Interface Components](#InterfaceComponents) below).

###<a name="EZAudioDevice"></a>EZAudioDevice
Provides a simple interface for obtaining the current and all available inputs and output for any Apple device. For instance, the iPhone 6 has three microphones available for input, while on OSX you can choose the Built-In Microphone or any available HAL device on your system. Similarly, for iOS you can choose from a pair of headphones connected or speaker, while on OSX you can choose from the Built-In Output, any available HAL device, or Airplay.

![EZAudioDeviceInputsExample](https://cloud.githubusercontent.com/assets/1275640/8535722/51e8f702-23fd-11e5-9f1c-8c45e80d19ef.gif)

####Getting Input Devices
To get all the available input devices use the `inputDevices` class method:
```objectivec
NSArray *inputDevices = [EZAudioDevice inputDevices];
```

or to just get the currently selected input device use the `currentInputDevice` method:
```objectivec
// On iOS this will default to the headset device or bottom microphone, while on OSX this will
// be your selected inpupt device from the Sound preferences
EZAudioDevice *currentInputDevice = [EZAudioDevice currentInputDevice];
```

####Getting Output Devices
Similarly, to get all the available output devices use the `outputDevices` class method:
```objectivec
NSArray *outputDevices = [EZAudioDevice outputDevices];
```

or to just get the currently selected output device use the `currentInputDevice` method:
```objectivec
// On iOS this will default to the headset speaker, while on OSX this will be your selected
// output device from the Sound preferences
EZAudioDevice *currentOutputDevice = [EZAudioDevice currentOutputDevice];
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
- EZAudioPassThroughExample (iOS)
- EZAudioPassThroughExample (OSX)
- EZAudioFFTExample (iOS)
- EZAudioFFTExample (OSX)

####Creating A Microphone

Create an `EZMicrophone` instance by declaring a property and initializing it like so:

```objectivec
// Declare the EZMicrophone as a strong property
@property (nonatomic, strong) EZMicrophone *microphone;

...

// Initialize the microphone instance and assign it a delegate to receive the audio data
// callbacks
self.microphone = [EZMicrophone microphoneWithDelegate:self];
```
Alternatively, you could also use the shared `EZMicrophone` instance and just assign its `EZMicrophoneDelegate`.
```objectivec
// Assign a delegate to the shared instance of the microphone to receive the audio data
// callbacks
[EZMicrophone sharedMicrophone].delegate = self;
```

####Setting The Device
The `EZMicrophone` uses an `EZAudioDevice` instance to select what specific hardware destination it will use to pull audio data. You'd use this if you wanted to change the input device like in the EZAudioCoreGraphicsWaveformExample for [iOS](https://github.com/syedhali/EZAudio/tree/master/EZAudioExamples/iOS/EZAudioCoreGraphicsWaveformExample) or [OSX](https://github.com/syedhali/EZAudio/tree/master/EZAudioExamples/OSX/EZAudioCoreGraphicsWaveformExample). At any time you can change which input device is used by setting the device property:
```objectivec
NSArray *inputs = [EZAudioDevice inputDevices];
[self.microphone setDevice:[inputs lastObject]];
```

Anytime the `EZMicrophone` changes its device it will trigger the `EZMicrophoneDelegate` event:
```objectivec

- (void)microphone:(EZMicrophone *)microphone changedDevice:(EZAudioDevice *)device
{
    // This is not always guaranteed to occur on the main thread so make sure you
    // wrap it in a GCD block
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update UI here
	    NSLog(@"Changed input device: %@", device);
    });
}
```
**Note: For iOS this can happen automatically if the AVAudioSession changes the current device.**

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
 The microphone data represented as non-interleaved float arrays useful for:
    - Creating real-time waveforms using EZAudioPlot or EZAudioPlotGL
    - Creating any number of custom visualizations that utilize audio!
 */
-(void)   microphone:(EZMicrophone *)microphone
    hasAudioReceived:(float **)buffer
      withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
{
    __weak typeof (self) weakSelf = self;
	// Getting audio data as an array of float buffer arrays that can be fed into the
	// EZAudioPlot, EZAudioPlotGL, or whatever visualization you would like to do with
	// the microphone data.
	dispatch_async(dispatch_get_main_queue(),^{
		// Visualize this data brah, buffer[0] = left channel, buffer[1] = right channel
		[weakSelf.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
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
 withNumberOfChannels:(UInt32)numberOfChannels
{
	// Getting audio data as an AudioBufferList that can be directly fed into the EZRecorder
	// or EZOutput. Say whattt...
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
Provides flexible playback to the default output device by asking the `EZOutputDataSource` for audio data to play. Doesn't care where the buffers come from (microphone, audio file, streaming audio, etc). As of 1.0.0 the `EZOutputDataSource` has been simplified to have only one method to provide audio data to your `EZOutput` instance.
```objectivec
// The EZOutputDataSource should fill out the audioBufferList with the given frame count.
// The timestamp is provided for sample accurate calculation, but for basic use cases can
// be ignored.
- (OSStatus)        output:(EZOutput *)output
 shouldFillAudioBufferList:(AudioBufferList *)audioBufferList
        withNumberOfFrames:(UInt32)frames
                 timestamp:(const AudioTimeStamp *)timestamp;
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
@property (nonatomic, strong) EZOutput *output;
...

// Initialize the EZOutput instance and assign it a delegate to provide the output audio data
self.output = [EZOutput outputWithDataSource:self];
```
Alternatively, you could also use the shared output instance and just assign it an `EZOutputDataSource` if you will only have one `EZOutput` instance for your application.
```objectivec
// Assign a delegate to the shared instance of the output to provide the output audio data
[EZOutput sharedOutput].delegate = self;
```
####Setting The Device
The `EZOutput` uses an `EZAudioDevice` instance to select what specific hardware destination it will output audio to. You'd use this if you wanted to change the output device like in the [EZAudioPlayFileExample](https://github.com/syedhali/EZAudio/tree/master/EZAudioExamples/OSX/EZAudioPlayFileExample) for OSX. At any time you can change which output device is used by setting the `device` property:
```objectivec
// By default the EZOutput uses the default output device, but you can change this at any time
EZAudioDevice *currentOutputDevice = [EZAudioDevice currentOutputDevice];
[self.output setDevice:currentOutputDevice];
```

Anytime the `EZOutput` changes its device it will trigger the `EZOutputDelegate` event:
```objectivec
- (void)output:(EZOutput *)output changedDevice:(EZAudioDevice *)device
{
    NSLog(@"Change output device to: %@", device);
}
```

####Playing Audio

#####Setting The Input Format

When providing audio data the `EZOutputDataSource` will expect you to fill out the AudioBufferList provided with whatever `inputFormat` that is set on the `EZOutput`. By default the input format is a stereo, non-interleaved, float format (see [defaultInputFormat](http://cocoadocs.org/docsets/EZAudio/1.1.2/Classes/EZOutput.html#//api/name/defaultInputFormat) for more information). If you're dealing with a different input format (which is typically the case), just set the `inputFormat` property. For instance:
```objectivec
// Set a mono, float format with a sample rate of 44.1 kHz
AudioStreamBasicDescription monoFloatFormat = [EZAudioUtilities monoFloatFormatWithSampleRate:44100.0f];
[self.output setInputFormat:monoFloatFormat];
```
#####Implementing the EZOutputDataSource

An example of implementing the `EZOutputDataSource` is done internally in the `EZAudioPlayer` using an `EZAudioFile` to read audio from an audio file on disk like so:
```objectivec
- (OSStatus)        output:(EZOutput *)output
 shouldFillAudioBufferList:(AudioBufferList *)audioBufferList
        withNumberOfFrames:(UInt32)frames
                 timestamp:(const AudioTimeStamp *)timestamp
{
    if (self.audioFile)
    {
        UInt32 bufferSize; // amount of frames actually read
        BOOL eof; // end of file
        [self.audioFile readFrames:frames
                   audioBufferList:audioBufferList
                        bufferSize:&bufferSize
                               eof:&eof];
        if (eof && [self.delegate respondsToSelector:@selector(audioPlayer:reachedEndOfAudioFile:)])
        {
            [self.delegate audioPlayer:self reachedEndOfAudioFile:self.audioFile];
        }
        if (eof && self.shouldLoop)
        {
            [self seekToFrame:0];
        }
        else if (eof)
        {
            [self pause];
            [self seekToFrame:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:EZAudioPlayerDidReachEndOfFileNotification
                                                                object:self];
        }
    }
    return noErr;
}
```

I created a sample project that uses the `EZOutput` to act as a signal generator to play sine, square, triangle, sawtooth, and noise waveforms. **Here's a snippet of code to generate a sine tone**:
```objectivec
...
double const SAMPLE_RATE = 44100.0;

- (void)awakeFromNib
{
    //
    // Create EZOutput to play audio data with mono format (EZOutput will convert
    // this mono, float "inputFormat" to a clientFormat, i.e. the stereo output format).
    //
    AudioStreamBasicDescription inputFormat = [EZAudioUtilities monoFloatFormatWithSampleRate:SAMPLE_RATE];
    self.output = [EZOutput outputWithDataSource:self inputFormat:inputFormat];
    [self.output setDelegate:self];
    self.frequency = 200.0;
    self.sampleRate = SAMPLE_RATE;
    self.amplitude = 0.80;
}

- (OSStatus)        output:(EZOutput *)output
 shouldFillAudioBufferList:(AudioBufferList *)audioBufferList
        withNumberOfFrames:(UInt32)frames
                 timestamp:(const AudioTimeStamp *)timestamp
{
    Float32 *buffer = (Float32 *)audioBufferList->mBuffers[0].mData;
    size_t bufferByteSize = (size_t)audioBufferList->mBuffers[0].mDataByteSize;
    double theta = self.theta;
    double frequency = self.frequency;
    double thetaIncrement = 2.0 * M_PI * frequency / SAMPLE_RATE;
    if (self.type == GeneratorTypeSine)
    {
        for (UInt32 frame = 0; frame < frames; frame++)
        {
            buffer[frame] = self.amplitude * sin(theta);
            theta += thetaIncrement;
            if (theta > 2.0 * M_PI)
            {
                theta -= 2.0 * M_PI;
            }
        }
        self.theta = theta;
    }
    else if (... other shapes in full source)
}
```

For the full implementation of the square, triangle, sawtooth, and noise functions here: (https://github.com/syedhali/SineExample/blob/master/SineExample/GeneratorViewController.m#L220-L305)

Once the `EZOutput` has started it will send the `EZOutputDelegate` the audio back as float arrays for visualizing. These are converted inside the `EZOutput` component from whatever input format you may have provided. For instance, if you provide an interleaved, signed integer AudioStreamBasicDescription for the `inputFormat` property then that will be automatically converted to a stereo, non-interleaved, float format when sent back in the delegate `playedAudio:...` method below:
An array of float arrays:
```objectivec
/**
 The output data represented as non-interleaved float arrays useful for:
    - Creating real-time waveforms using EZAudioPlot or EZAudioPlotGL
    - Creating any number of custom visualizations that utilize audio!
 */
- (void)       output:(EZOutput *)output
          playedAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
	// Update plot, buffer[0] = left channel, buffer[1] = right channel
    });
}
```

####Pausing/Resuming The Output
Pause or resume the output component at any time like so:
```objectivec
// Stop fetching audio
[self.output stopPlayback];

// Resume fetching audio
[self.output startPlayback];
```

####Chaining Audio Unit Effects
Internally the `EZOutput` is using an AUGraph to chain together a converter, mixer, and output audio units. You can hook into this graph by subclassing `EZOutput` and implementing the method:
```objectivec
// By default this method connects the AUNode representing the input format converter to
// the mixer node. In subclasses you can add effects in the chain between the converter
// and mixer by creating additional AUNodes, adding them to the AUGraph provided below,
// and then connecting them together.
- (OSStatus)connectOutputOfSourceNode:(AUNode)sourceNode
                  sourceNodeOutputBus:(UInt32)sourceNodeOutputBus
                    toDestinationNode:(AUNode)destinationNode
              destinationNodeInputBus:(UInt32)destinationNodeInputBus
                              inGraph:(AUGraph)graph;
```

This was inspired by the audio processing graph from CocoaLibSpotify (Daniel Kennett of Spotify has [an excellent blog post](http://ikennd.ac/blog/2012/04/augraph-basics-in-cocoalibspotify/) explaining how to add an EQ to the CocoaLibSpotify AUGraph).

Here's an example of how to add a delay audio unit (`kAudioUnitSubType_Delay`):
```objectivec
// In interface, declare delay node info property
@property (nonatomic, assign) EZAudioNodeInfo *delayNodeInfo;

// In implementation, overwrite the connection method
- (OSStatus)connectOutputOfSourceNode:(AUNode)sourceNode
                  sourceNodeOutputBus:(UInt32)sourceNodeOutputBus
                    toDestinationNode:(AUNode)destinationNode
              destinationNodeInputBus:(UInt32)destinationNodeInputBus
                              inGraph:(AUGraph)graph
{
    self.delayNodeInfo = (EZAudioNodeInfo *)malloc(sizeof(EZAudioNodeInfo));

    // A description for the time/pitch shifter Device
    AudioComponentDescription delayComponentDescription;
    delayComponentDescription.componentType = kAudioUnitType_Effect;
    delayComponentDescription.componentSubType = kAudioUnitSubType_Delay;
    delayComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    delayComponentDescription.componentFlags = 0;
    delayComponentDescription.componentFlagsMask = 0;

    [EZAudioUtilities checkResult:AUGraphAddNode(graph,
                                                 &delayComponentDescription,
                                                 &self.delayNodeInfo->node)
                        operation:"Failed to add node for time shift"];

    // Get the time/pitch shifter Audio Unit from the node
    [EZAudioUtilities checkResult:AUGraphNodeInfo(graph,
                                                  self.delayNodeInfo->node,
                                                  NULL,
                                                  &self.delayNodeInfo->audioUnit)
                        operation:"Failed to get audio unit for delay node"];

    // connect the output of the input source node to the input of the time/pitch shifter node
    [EZAudioUtilities checkResult:AUGraphConnectNodeInput(graph,
                                                          sourceNode,
                                                          sourceNodeOutputBus,
                                                          self.delayNodeInfo->node,
                                                          0)
                        operation:"Failed to connect source node into delay node"];

    // connect the output of the time/pitch shifter node to the input of the destination node, thus completing the chain.
    [EZAudioUtilities checkResult:AUGraphConnectNodeInput(graph,
                                                          self.delayNodeInfo->node,
                                                          0,
                                                          destinationNode,
                                                          destinationNodeInputBus)
                        operation:"Failed to connect delay to destination node"];
    return noErr;
}

// Clean up
- (void)dealloc
{
    free(self.delayNodeInfo);
}
```

###<a name="EZAudioFile"></a>EZAudioFile
Provides simple read/seek operations, pulls waveform amplitude data, and provides the `EZAudioFileDelegate` to notify of any read/seek action occuring on the `EZAudioFile`. This can be thought of as the NSImage/UIImage equivalent of the audio world.

**_Relevant Example Projects_**
- EZAudioWaveformFromFileExample (iOS)
- EZAudioWaveformFromFileExample (OSX)

####Opening An Audio File
To open an audio file create a new instance of the `EZAudioFile` class.
```objectivec
// Declare the EZAudioFile as a strong property
@property (nonatomic, strong) EZAudioFile *audioFile;

...

// Initialize the EZAudioFile instance and assign it a delegate to receive the read/seek callbacks
self.audioFile = [EZAudioFile audioFileWithURL:[NSURL fileURLWithPath:@"/path/to/your/file"] delegate:self];
```

####Getting Waveform Data

The EZAudioFile allows you to quickly fetch waveform data from an audio file with as much or little detail as you'd like.
```objectivec
__weak typeof (self) weakSelf = self;
// Get a waveform with 1024 points of data. We can adjust the number of points to whatever level
// of detail is needed by the application
[self.audioFile getWaveformDataWithNumberOfPoints:1024
                                  completionBlock:^(float **waveformData,
                                                    int length)
{
     [weakSelf.audioPlot updateBuffer:waveformData[0]
                       withBufferSize:length];
}];
```

####Reading From An Audio File

Reading audio data from a file requires you to create an AudioBufferList to hold the data. The `EZAudio` utility function, `audioBufferList`, provides a convenient way to get an allocated AudioBufferList to use. There is also a utility function, `freeBufferList:`, to use to free (or release) the AudioBufferList when you are done using that audio data.

**Note: You have to free the AudioBufferList, even in ARC.**
```objectivec
// Allocate an AudioBufferList to hold the audio data (the client format is the non-compressed
// in-app format that is used for reading, it's different than the file format which is usually
// something compressed like an mp3 or m4a)
AudioStreamBasicDescription clientFormat = [self.audioFile clientFormat];
UInt32 numberOfFramesToRead = 512;
UInt32 channels = clientFormat.mChannelsPerFrame;
BOOL isInterleaved = [EZAudioUtilities isInterleaved:clientFormat];
AudioBufferList *bufferList = [EZAudioUtilities audioBufferListWithNumberOfFrames:numberOfFramesToRead
                                                                 numberOfChannels:channels
                                                                      interleaved:isInterleaved];

// Read the frames from the EZAudioFile into the AudioBufferList
UInt32 framesRead;
UInt32 isEndOfFile;
[self.audioFile readFrames:numberOfFramesToRead
           audioBufferList:bufferList
                bufferSize:&framesRead
                       eof:&isEndOfFile]
```

When a read occurs the `EZAudioFileDelegate` receives two events.

An event notifying the delegate of the read audio data as float arrays:
```objectivec
-(void)     audioFile:(EZAudioFile *)audioFile
            readAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.audioPlot updateBuffer:buffer[0]
                          withBufferSize:bufferSize];
    });
}
```
and an event notifying the delegate of the new frame position within the `EZAudioFile`:
```objectivec
-(void)audioFile:(EZAudioFile *)audioFile updatedPosition:(SInt64)framePosition
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
		// Update UI
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

// Alternatively, you can seek using seconds
NSTimeInterval duration = [self.audioFile duration];
[self.audioFile setCurrentTime:duration/2.0];
```
When a seek occurs the `EZAudioFileDelegate` receives the seek event:
```objectivec
-(void)audioFile:(EZAudioFile *)audioFile updatedPosition:(SInt64)framePosition
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
		// Update UI
    });
}
```

###<a name="EZAudioPlayer"></a>EZAudioPlayer
Provides a class that combines the `EZAudioFile` and `EZOutput` for file playback of all Core Audio supported formats to any hardware device. Because the `EZAudioPlayer` internally hooks into the `EZAudioFileDelegate` and `EZOutputDelegate`, you should implement the `EZAudioPlayerDelegate` to receive the `playedAudio:...` and `updatedPosition:` events. The EZAudioPlayFileExample projects for [iOS](https://github.com/syedhali/EZAudio/tree/master/EZAudioExamples/iOS/EZAudioPlayFileExample) and [OSX](https://github.com/syedhali/EZAudio/tree/master/EZAudioExamples/OSX/EZAudioPlayFileExample) shows how to use the `EZAudioPlayer` to play audio files, visualize the samples with an audio plot, adjust the volume, and change the output device using the `EZAudioDevice` class. The `EZAudioPlayer` primarily uses `NSNotificationCenter` to post notifications because often times you have one audio player and multiple UI elements that need to listen for player events to properly update.

####Creating An Audio Player
```objectivec
// Declare the EZAudioFile as a strong property
@property (nonatomic, strong) EZAudioFile *audioFile;

...

// Create an EZAudioPlayer with a delegate that conforms to EZAudioPlayerDelegate
self.player = [EZAudioPlayer audioPlayerWithDelegate:self];
```

####Playing An Audio File
The `EZAudioPlayer` uses an internal `EZAudioFile` to provide data to its `EZOutput` for output via the `EZOutputDataSource`. You can provide an `EZAudioFile` by just setting the `audioFile` property on the `EZAudioPlayer` will make a copy of the `EZAudioFile` at that file path url for its own use.
```objectivec
// Set the EZAudioFile for playback by setting the `audioFile` property
EZAudioFile *audioFile = [EZAudioFile audioFileWithURL:[NSURL fileURLWithPath:@"/path/to/your/file"]];
[self.player setAudioFile:audioFile];

// This, however, will not pause playback if a current file is playing. Instead
// it's encouraged to use `playAudioFile:` instead if you're swapping in a new
// audio file while playback is already running
EZAudioFile *audioFile = [EZAudioFile audioFileWithURL:[NSURL fileURLWithPath:@"/path/to/your/file"]];
[self.player playAudioFile:audioFile];
```

As audio is played the `EZAudioPlayerDelegate` will receive the `playedAudio:...`, `updatedPosition:...`, and, if the audio file reaches the end of the file, the `reachedEndOfAudioFile:` events. A typical implementation of the `EZAudioPlayerDelegate` would be something like:
```objectivec
- (void)  audioPlayer:(EZAudioPlayer *)audioPlayer
          playedAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
          inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    // Update an EZAudioPlot or EZAudioPlotGL to reflect the audio data coming out
    // of the EZAudioPlayer (post volume and pan)
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.audioPlot updateBuffer:buffer[0]
                          withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------

- (void)audioPlayer:(EZAudioPlayer *)audioPlayer
    updatedPosition:(SInt64)framePosition
        inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    // Update any UI controls including sliders and labels
    // display current time/duration
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!weakSelf.positionSlider.highlighted)
        {
            weakSelf.positionSlider.floatValue = (float)framePosition;
            weakSelf.positionLabel.integerValue = framePosition;
        }
    });
}
```

####Seeking
You can seek through the audio file in a similar fashion as with the `EZAudioFile`. That is, using the `seekToFrame:` or `currentTime` property.
```objectivec
// Get the total number of frames and seek halfway
SInt64 totalFrames = [self.player totalFrames];
[self.player seekToFrame:(totalFrames/2)];

// Alternatively, you can seek using seconds
NSTimeInterval duration = [self.player duration];
[self.player setCurrentTime:duration/2.0];
```

####Setting Playback Parameters
Because the `EZAudioPlayer` wraps the `EZOutput` you can adjust the volume and pan parameters for playback.
```objectivec
// Make it half as loud, 0 = silence, 1 = full volume. Default is 1.
[self.player setVolume:0.5];

// Make it only play on the left, -1 = left, 1 = right. Default is 0.0 (center)
[self.player setPan:-1.0];
```

####Getting Audio File Parameters
The `EZAudioPlayer` wraps the `EZAudioFile` and provides a high level interface for pulling values like current time, duration, the frame index, total frames, etc.
```objectivec
NSTimeInterval  currentTime          = [self.player currentTime];
NSTimeInterval  duration             = [self.player duration];
NSString       *formattedCurrentTime = [self.player formattedCurrentTime]; // MM:SS formatted
NSString       *formattedDuration    = [self.player formattedDuration];    // MM:SS formatted
SInt64          frameIndex           = [self.player frameIndex];
SInt64          totalFrames          = [self.player totalFrames];
```

In addition, the `EZOutput` properties are also offered at a high level as well:
```objectivec
EZAudioDevice *outputDevice = [self.player device];
BOOL 	       isPlaying    = [self.player isPlaying];
float          pan          = [self.player pan];
float          volume       = [self.player volume];
```

####Notifications
The `EZAudioPlayer` provides the following notifications (as of 1.1.2):
```objectivec
/**
 Notification that occurs whenever the EZAudioPlayer changes its `audioFile` property. Check the new value using the EZAudioPlayer's `audioFile` property.
 */
FOUNDATION_EXPORT NSString * const EZAudioPlayerDidChangeAudioFileNotification;

/**
 Notification that occurs whenever the EZAudioPlayer changes its `device` property. Check the new value using the EZAudioPlayer's `device` property.
 */
FOUNDATION_EXPORT NSString * const EZAudioPlayerDidChangeOutputDeviceNotification;

/**
 Notification that occurs whenever the EZAudioPlayer changes its `output` component's `pan` property. Check the new value using the EZAudioPlayer's `pan` property.
 */
FOUNDATION_EXPORT NSString * const EZAudioPlayerDidChangePanNotification;

/**
 Notification that occurs whenever the EZAudioPlayer changes its `output` component's play state. Check the new value using the EZAudioPlayer's `isPlaying` property.
 */
FOUNDATION_EXPORT NSString * const EZAudioPlayerDidChangePlayStateNotification;

/**
 Notification that occurs whenever the EZAudioPlayer changes its `output` component's `volume` property. Check the new value using the EZAudioPlayer's `volume` property.
 */
FOUNDATION_EXPORT NSString * const EZAudioPlayerDidChangeVolumeNotification;

/**
 Notification that occurs whenever the EZAudioPlayer has reached the end of a file and its `shouldLoop` property has been set to NO.
 */
FOUNDATION_EXPORT NSString * const EZAudioPlayerDidReachEndOfFileNotification;

/**
 Notification that occurs whenever the EZAudioPlayer performs a seek via the `seekToFrame` method or `setCurrentTime:` property setter. Check the new `currentTime` or `frameIndex` value using the EZAudioPlayer's `currentTime` or `frameIndex` property, respectively.
 */
FOUNDATION_EXPORT NSString * const EZAudioPlayerDidSeekNotification;
```

###<a name="EZRecorder"></a>EZRecorder
Provides a way to record any audio source to an audio file. This hooks into the other components quite nicely to do something like plot the audio waveform while recording to give visual feedback as to what is happening. The `EZRecorderDelegate` provides methods to listen to write events and a final close event on the `EZRecorder` (explained [below](#EZRecorderDelegateExplanation)).

*Relevant Example Projects*
- EZAudioRecordExample (iOS)
- EZAudioRecordExample (OSX)

####Creating A Recorder

To create an `EZRecorder` you must provide at least 3 things: an NSURL representing the file path of where the audio file should be written to (an existing file will be overwritten), a `clientFormat` representing the format in which you will be providing the audio data, and either an `EZRecorderFileType` or an `AudioStreamBasicDescription` representing the file format of the audio data on disk.

```objectivec
// Provide a file path url to write to, a client format (always linear PCM, this is the format
// coming from another component like the EZMicrophone's audioStreamBasicDescription property),
// and a EZRecorderFileType constant representing either a wav (EZRecorderFileTypeWAV),
// aiff (EZRecorderFileTypeAIFF), or m4a (EZRecorderFileTypeM4A) file format. The advantage of
// this is that the `fileFormat` property will be automatically filled out for you.
+ (instancetype)recorderWithURL:(NSURL *)url
                   clientFormat:(AudioStreamBasicDescription)clientFormat
                       fileType:(EZRecorderFileType)fileType;

// Alternatively, you can provide a file path url to write to, a client format (always linear
// PCM, this is the format coming from another component like the EZMicrophone's
// audioStreamBasicDescription property), a `fileFormat` representing your custom
// AudioStreamBasicDescription, and an AudioFileTypeID that corresponds with your `fileFormat`.
+ (instancetype)recorderWithURL:(NSURL *)url
                   clientFormat:(AudioStreamBasicDescription)clientFormat
                     fileFormat:(AudioStreamBasicDescription)fileFormat
                audioFileTypeID:(AudioFileTypeID)audioFileTypeID;

```

Start by declaring an instance of the EZRecorder (you will have one of these per audio file written out)
```objectivec
// Declare the EZRecorder as a strong property
@property (nonatomic, strong) EZRecorder *recorder;
```

and initialize it using one of the two initializers from above. For instance, using the `EZRecorderFileType` shortcut initializer you could create an instance like so:
```objectivec
// Example using an EZMicrophone and a string called kAudioFilePath representing a file
// path location on your computer to write out a M4A file.
self.recorder = [EZRecorder recorderWithURL:[NSURL fileURLWithPath:@"/path/to/your/file.m4a"]
                               clientFormat:[self.microphone audioStreamBasicDescription]
                                   fileType:EZRecorderFileTypeM4A];
```

or to configure your own custom file format, say to write out a 8000 Hz, iLBC file:
```objectivec
// Example using an EZMicrophone, a string called kAudioFilePath representing a file
// path location on your computer, and an iLBC file format.
AudioStreamBasicDescription iLBCFormat = [EZAudioUtilities iLBCFormatWithSampleRate:8000];
self.recorder = [EZRecorder recorderWithURL:[NSURL fileURLWithPath:@"/path/to/your/file.caf"]
                               clientFormat:[self.microphone audioStreamBasicDescription]
                                 fileFormat:iLBCFormat
                            audioFileTypeID:kAudioFileCAFType];
```

####Recording Some Audio

Once you've initialized your `EZRecorder` you can append data by passing in an AudioBufferList and its buffer size like so:
```objectivec
// Append the microphone data coming as a AudioBufferList with the specified buffer size
// to the recorder
-(void)    microphone:(EZMicrophone *)microphone
        hasBufferList:(AudioBufferList *)bufferList
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as a buffer list that can be directly fed into the EZRecorder. This is
    // happening on the audio thread - any UI updating needs a GCD main queue block.
    if (self.isRecording)
    {
        // Since we set the recorder's client format to be that of the EZMicrophone instance,
        // the audio data coming in represented by the AudioBufferList can directly be provided
        // to the EZRecorder. The EZRecorder will internally convert the audio data from the
        // `clientFormat` to `fileFormat`.
        [self.recorder appendDataFromBufferList:bufferList
                                 withBufferSize:bufferSize];
    }
}
```

#####<a name="EZRecorderDelegateExplanation"></a>Responding to an EZRecorder after it has written audio data

Once audio data has been successfully written with the `EZRecorder` it will notify the `EZRecorderDelegate` of the event so it can respond via:
```objectivec
// Triggers after the EZRecorder's `appendDataFromBufferList:withBufferSize:` method is called
// so you can update your interface accordingly.
- (void)recorderUpdatedCurrentTime:(EZRecorder *)recorder
{
    __weak typeof (self) weakSelf = self;
    // This will get triggerd on the thread that the write occured on so be sure to wrap your UI
    // updates in a GCD main queue block! However, I highly recommend you first pull the values
    // you'd like to update the interface with before entering the GCD block to avoid trying to
    // fetch a value after the audio file has been closed.
    NSString *formattedCurrentTime = [recorder formattedCurrentTime]; // MM:SS formatted
    dispatch_async(dispatch_get_main_queue(), ^{
    	// Update label
        weakSelf.currentTimeLabel.stringValue = formattedCurrentTime;
    });
}
```

####Closing An Audio File
When you're recording is done be sure to call the `closeAudioFile` method to make sure the audio file written to disk is properly closed before you attempt to read it again.

```objectivec
// Close the EZRecorder's audio file BEFORE reading
[self.recorder closeAudioFile];
```

This will trigger the EZRecorder's delegate method:
```objectivec
- (void)recorderDidClose:(EZRecorder *)recorder
{
    recorder.delegate = nil;
}
```

##<a name="InterfaceComponents"></a>Interface Components
`EZAudio` currently offers two drop in audio waveform components that help simplify the process of visualizing audio.

###<a name="EZAudioPlot"></a>EZAudioPlot
Provides an audio waveform plot that uses CoreGraphics to perform the drawing. On iOS this is a subclass of UIView while on OSX this is a subclass of NSView. As of the 1.0.0 release, the waveforms are drawn using CALayers where compositing is done on the GPU. As a result, there have been some huge performance gains and CPU usage per real-time (i.e. 60 frames per second redrawing) plot is now about 2-3% CPU as opposed to the 20-30% we were experiencing before.

*Relevant Example Projects*
- EZAudioCoreGraphicsWaveformExample (iOS)
- EZAudioCoreGraphicsWaveformExample (OSX)
- EZAudioRecordExample (iOS)
- EZAudioRecordExample (OSX)
- EZAudioWaveformFromFileExample (iOS)
- EZAudioWaveformFromFileExample (OSX)
- EZAudioFFTExample (iOS)
- EZAudioFFTExample (OSX)

####Creating An Audio Plot

You can create an audio plot in the interface builder by dragging in a UIView on iOS or an NSView on OSX onto your content area. Then change the custom class of the UIView/NSView to `EZAudioPlot`.

![EZAudioPlotInterfaceBuilder](https://cloud.githubusercontent.com/assets/1275640/8532901/47d6f9ce-23e6-11e5-9766-d9969e630338.gif)

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
audioPlot.plotType = EZPlotTypeBuffer;
// Fill
audioPlot.shouldFill = YES;
// Mirror
audioPlot.shouldMirror = YES;
```

####IBInspectable Attributes

Also, as of iOS 8 you can adjust the background color, color, gain, shouldFill, and shouldMirror parameters directly in the Interface Builder via the IBInspectable attributes:

![EZAudioPlotInspectableAttributes](https://cloud.githubusercontent.com/assets/1275640/8530670/288840c8-23d7-11e5-954b-644ed4ed67b4.png)

####Updating The Audio Plot

All plots have only one update function, `updateBuffer:withBufferSize:`, which expects a float array and its length.
```objectivec
// The microphone component provides audio data to its delegate as an array of float buffer arrays.
- (void)   microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    /**
     Update the audio plot using the float array provided by the microphone:
       buffer[0] = left channel
       buffer[1] = right channel
     Note: Audio updates happen asynchronously so we need to make sure
         sure to update the plot on the main thread
     */
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}
```

###<a name="EZAudioPlotGL"></a>EZAudioPlotGL
Provides an audio waveform plot that uses OpenGL to perform the drawing. The API this class are exactly the same as those for the EZAudioPlot above. On iOS this is a subclass of the GLKView while on OSX this is a subclass of the NSOpenGLView. In most cases this is the plot you want to use, it's GPU-accelerated, can handle lots of points  while displaying 60 frames per second (the EZAudioPlot starts to choke on anything greater than 1024), and performs amazingly on all devices. The only downside is that you can only have one OpenGL plot onscreen at a time. However, you can combine OpenGL plots with Core Graphics plots in the view hierachy (see the EZAudioRecordExample for an example of how to do this).

*Relevant Example Projects*
- EZAudioOpenGLWaveformExample (iOS)
- EZAudioOpenGLWaveformExample (OSX)
- EZAudioPlayFileExample (iOS)
- EZAudioPlayFileExample (OSX)
- EZAudioRecordExample (iOS)
- EZAudioRecordExample (OSX)
- EZAudioPassThroughExample (iOS)
- EZAudioPassThroughExample (OSX)

####Creating An OpenGL Audio Plot

You can create an audio plot in the interface builder by dragging in a UIView on iOS or an NSView on OSX onto your content area. Then change the custom class of the UIView/NSView to `EZAudioPlotGL`.

![EZAudioPlotGLInterfaceBuilder](https://cloud.githubusercontent.com/assets/1275640/8532900/47d62346-23e6-11e5-8128-07c6641f4af8.gif)

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
audioPlotGL.plotType = EZPlotTypeBuffer;
// Fill
audioPlotGL.shouldFill = YES;
// Mirror
audioPlotGL.shouldMirror = YES;
```

####IBInspectable Attributes

Also, as of iOS 8 you can adjust the background color, color, gain, shouldFill, and shouldMirror parameters directly in the Interface Builder via the IBInspectable attributes:

![EZAudioPlotGLInspectableAttributes](https://cloud.githubusercontent.com/assets/1275640/8530670/288840c8-23d7-11e5-954b-644ed4ed67b4.png)

####Updating The OpenGL Audio Plot

All plots have only one update function, `updateBuffer:withBufferSize:`, which expects a float array and its length.
```objectivec
// The microphone component provides audio data to its delegate as an array of float buffer arrays.
- (void)   microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    /**
     Update the audio plot using the float array provided by the microphone:
       buffer[0] = left channel
       buffer[1] = right channel
     Note: Audio updates happen asynchronously so we need to make sure
         sure to update the plot on the main thread
     */
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.audioPlotGL updateBuffer:buffer[0] withBufferSize:bufferSize];
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
The following people rock:
- My brother, [Reza Ali](http://www.syedrezaali.com/), for walking me through all the gritty details of OpenGL and his constant encouragement through this journey to 1.0.0.
- [Aure Prochazka](http://aure.com/) for his amazing work on [AudioKit](http://audiokit.io/) and his encouragement to bring EZAudio to 1.0.0
- [Daniel Kennett](http://ikennd.ac/) for writing [this great blog post](http://ikennd.ac/blog/2012/04/augraph-basics-in-cocoalibspotify/) that inspired the rewrite of the `EZOutput` in 1.0.0.
- [Michael Tyson](http://atastypixel.com/blog/) for creating the [TPCircularBuffer](http://atastypixel.com/blog/a-simple-fast-circular-buffer-implementation-for-audio-processing/) and all his contributions to the community including the Amazing Audio Engine, Audiobus, and all the tasty pixel blog posts.
- Chris Adamson and Kevin Avila for writing the amazing [Learning Core Audio](http://www.amazon.com/Learning-Core-Audio-Hands-On-Programming/dp/0321636848) book.
