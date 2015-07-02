Pod::Spec.new do |s|
  s.name         = "EZAudio"
  s.version      = "0.6.0"
  s.summary      = "A simple, intuitive audio framework for iOS and OSX useful for anyone doing audio processing and/or audio-based visualizations."
  s.homepage     = "https://github.com/syedhali/EZAudio"
  s.screenshots  = "https://s3-us-west-1.amazonaws.com/ezaudio-media/EZAudioSummary.png"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Syed Haris Ali" => "syedhali07@gmail.com" }
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.source       = { :git => "https://github.com/syedhali/EZAudio.git", :tag => s.version }
  s.source_files  = 'EZAudio/*.{h,m,c}'
  s.exclude_files = [ 'EZAudio/VERSION', 'EZAudio/TPCircularBuffer.{h,c}' ]
  s.ios.frameworks = 'AudioToolbox','AVFoundation','GLKit'
  s.osx.frameworks = 'AudioToolbox','AudioUnit','CoreAudio','QuartzCore','OpenGL','GLKit'
  s.dependency 'TPCircularBuffer', '~> 0.0'
  s.requires_arc = true;
end