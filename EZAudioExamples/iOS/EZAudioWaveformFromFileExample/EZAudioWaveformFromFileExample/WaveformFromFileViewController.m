//
//  WaveformFromFileViewController.m
//  EZAudioWaveformFromFileExample
//
//  Created by Syed Haris Ali on 12/15/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//

#import "WaveformFromFileViewController.h"

@interface WaveformFromFileViewController (){
  AudioBufferList *readBuffer;
}
@end

@implementation WaveformFromFileViewController
@synthesize audioPlot = _audioPlot;
@synthesize audioFile = _audioFile;
@synthesize eof = _eof;
@synthesize filePathLabel = _filePathLabel;

#pragma mark - Customize the Audio Plot
-(void)viewDidLoad
{
  
    [super viewDidLoad];

    /*
    Customizing the audio plot's look
    */
    // Background color
    self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.169 green: 0.643 blue: 0.675 alpha: 1];
    // Waveform color
    self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    // Plot type
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    // Fill
    self.audioPlot.shouldFill      = YES;
    // Mirror
    self.audioPlot.shouldMirror    = YES;

    /*
    Load in the sample file
    */
    [self openFileWithFilePathURL:[NSURL fileURLWithPath:kAudioFileDefault]];
    
//    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchedAudioPlot:)];
//    [self.audioPlot addGestureRecognizer:pinchGestureRecognizer];
//    
//    UIPanGestureRecognizer *panGestureRecongizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedAudioPlot:)];
//    [self.audioPlot addGestureRecognizer:panGestureRecongizer];
    
    self.audioPlot.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.scrollView.backgroundColor = self.audioPlot.backgroundColor;
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = 4.75f;
}

//- (void)pinchedAudioPlot:(UIPinchGestureRecognizer *)pinchGestureRecognizer
//{
//    CATransform3D transform = CATransform3DScale(self.audioPlot.waveformLayer.transform,
//                                                 pinchGestureRecognizer.scale,
//                                                 1.0,
//                                                 1.0);
//    pinchGestureRecognizer.scale = 1.0f;
//    CGAffineTransform affineTransform = CATransform3DGetAffineTransform(transform);
//    CGFloat scaleFactor = sqrt(powf(affineTransform.a, 2) + powf(affineTransform.c, 2));
//    if (scaleFactor >= 1.0)
//    { 
//        [CATransaction begin];
//        [CATransaction setDisableActions:YES];
//        self.audioPlot.waveformLayer.transform = transform;
//        [CATransaction commit];
//    }
//    
//    [self checkWaveformFitsInView];
//}
//
//- (void)pannedAudioPlot:(UIPanGestureRecognizer *)panGestureRecognizer
//{
//    CGAffineTransform affineTransform = CATransform3DGetAffineTransform(self.audioPlot.waveformLayer.transform);
//    CGFloat scaleFactor = sqrt(powf(affineTransform.a, 2) + powf(affineTransform.c, 2));
//    CGPoint translation = [panGestureRecognizer translationInView:self.audioPlot];
//    [panGestureRecognizer setTranslation:CGPointZero inView:self.audioPlot];
//    CGPoint waveformLayerCenter = self.audioPlot.waveformLayerCenter;
//    waveformLayerCenter = CGPointMake(waveformLayerCenter.x - translation.x / scaleFactor, waveformLayerCenter.y);
//    
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    self.audioPlot.waveformLayerCenter = waveformLayerCenter;
//    [CATransaction commit];
//    
//    [self checkWaveformFitsInView];
//}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
                       withView:(UIView *)view
                        atScale:(CGFloat)scale
{
    NSLog(@"end content offset: %@", NSStringFromCGPoint(scrollView.contentOffset));
//    scrollView.contentSize = CGPointZero;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [scrollView setContentOffset: CGPointMake(scrollView.contentOffset.x, 0)];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.audioPlot;
}

#pragma mark - Action Extensions
-(void)openFileWithFilePathURL:(NSURL*)filePathURL
{
    self.audioFile          = [EZAudioFile audioFileWithURL:filePathURL];
    self.eof                = NO;
    self.filePathLabel.text = filePathURL.lastPathComponent;

    // Plot the whole waveform
    self.audioPlot.plotType     = EZPlotTypeBuffer;
//    self.audioPlot.shouldFill   = YES;
    self.audioPlot.shouldMirror = YES;
    self.audioPlot.optimizeForRealtimePlot = NO;
    [self.audioFile getWaveformDataWithNumberOfPoints:1024 completion:^(EZAudioFloatData *waveformData) {
        [self.audioPlot updateBuffer:waveformData.buffers[0] withBufferSize:waveformData.bufferSize];
    }];
}

@end
