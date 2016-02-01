//
//  AppDelegate.m
//  WaveformFromFile
//
//  Created by Syed Haris Ali on 12/1/13.
//  Updated by Syed Haris Ali on 1/23/16.
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

#import "AppDelegate.h"

@implementation AppDelegate

//------------------------------------------------------------------------------
#pragma mark - Customize the Audio Plot
//------------------------------------------------------------------------------

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
    //
    // Customizing the audio plot's look
    //
    
    //
    // Background color
    //
    self.audioPlot.backgroundColor = [NSColor colorWithCalibratedRed: 0.169 green: 0.643 blue: 0.675 alpha: 1];
    
    //
    // Waveform color
    //
    self.audioPlot.color           = [NSColor colorWithCalibratedRed: 1.000 green: 1.000 blue: 1.000 alpha: 1];
    
    //
    // Plot type
    //
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    
    //
    // Fill
    //
    self.audioPlot.shouldFill      = YES;
    
    //
    // Mirror
    //
    self.audioPlot.shouldMirror    = YES;
    
    //
    // Don't optimze for real-time because we don't need to re-render
    // the view 60 frames per second
    //
    self.audioPlot.shouldOptimizeForRealtimePlot = NO;
    
    //
    // Customize the layer with a shadow for fun
    //
    self.audioPlot.waveformLayer.shadowOffset = CGSizeMake(0.0, -1.0);
    self.audioPlot.waveformLayer.shadowRadius = 0.0;
    self.audioPlot.waveformLayer.shadowColor = [NSColor colorWithCalibratedRed: 0.069 green: 0.543 blue: 0.575 alpha: 1].CGColor;
    self.audioPlot.waveformLayer.shadowOpacity = 1.0;
    
    //
    // Open the default file included with the example
    //
    [self openFileWithFilePathURL:[NSURL fileURLWithPath:kAudioFileDefault]];
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void)openFile:(id)sender
{
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    openDlg.canChooseFiles = YES;
    openDlg.canChooseDirectories = NO;
    openDlg.delegate = self;
    if ([openDlg runModal] == NSModalResponseOK)
    {
        NSArray *selectedFiles = [openDlg URLs];
        [self openFileWithFilePathURL:selectedFiles.firstObject];
    }
}

//------------------------------------------------------------------------------

- (void)snapshot:(id)sender
{
    NSBitmapImageRep *imageRep = [self.audioPlot bitmapImageRepForCachingDisplayInRect:self.audioPlot.bounds];
    [self.audioPlot cacheDisplayInRect:self.audioPlot.bounds toBitmapImageRep:imageRep];
    NSData *data = [imageRep representationUsingType:NSPNGFileType properties:@{}];
    NSString *filePath = [NSString stringWithFormat:@"%@/Documents/waveform.png",NSHomeDirectory()];
    [data writeToFile:filePath atomically:NO];
}

//------------------------------------------------------------------------------
#pragma mark - Action Extensions
//------------------------------------------------------------------------------

- (void)openFileWithFilePathURL:(NSURL*)filePathURL
{
    //
    // Load the audio file and customize the UI
    //
    self.audioFile                 = [EZAudioFile audioFileWithURL:filePathURL];
    self.filePathLabel.stringValue = filePathURL.lastPathComponent;
    
    //
    // Change back to a buffer plot, but mirror and fill the waveform
    //
    self.audioPlot.plotType     = EZPlotTypeBuffer;
    self.audioPlot.shouldFill   = YES;
    self.audioPlot.shouldMirror = YES;
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.11f];
    [self.audioPlot clear];
    [CATransaction commit];
    
    //
    // Plot the whole waveform
    //
    __weak typeof (self) weakSelf = self;
    [self.audioFile getWaveformDataWithNumberOfPoints:1024
                                           completion:^(float **waveformData,
                                                        int length)
     {
         [weakSelf.audioPlot updateBuffer:waveformData[0]
                           withBufferSize:length];
     }];
}

//------------------------------------------------------------------------------
#pragma mark - NSOpenSavePanelDelegate
//------------------------------------------------------------------------------

//
// Here's an example how to filter the open panel to only show the supported
// file types by the EZAudioFile (which are just the audio file types supported
// by Core Audio).
//
- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename
{
    NSString *ext = [filename pathExtension];
    NSArray *fileTypes = [EZAudioFile supportedAudioFileTypes];
    BOOL isDirectory = [ext isEqualToString:@""];
    return [fileTypes containsObject:ext] || isDirectory;
}

@end
