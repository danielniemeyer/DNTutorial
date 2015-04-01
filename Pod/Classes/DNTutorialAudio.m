//
//  DNTutorialAudio.m
//  Pods
//
//  Created by Daniel Niemeyer on 3/31/15.
//
//

#import "DNTutorialAudio.h"

@interface DNTutorialAudio() <AVAudioPlayerDelegate>

@property (nonatomic, strong) NSURL         *URL;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation DNTutorialAudio

#pragma mark --
#pragma mark - Initialization
#pragma mark --

+ (id)audioWithURL:(NSURL *)URL
               key:(NSString *)key;
{
    // Proper initialization
    NSAssert(URL != nil, @"DNTutorialAudio: Cannot initialize action with no URL");
    NSAssert(key != nil, @"DNTutorialAudio: Cannot initialize action with invalid key");
    
    DNTutorialAudio *audio = [DNTutorialAudio new];
    audio.key = key;
    audio.URL = URL;
    return audio;
}

+ (id)audioWithPath:(NSString *)path
             ofType:(NSString *)type
                key:(NSString *)key;
{
    // Proper initialization
    NSAssert(path != nil, @"DNTutorialAudio: Cannot initialize action with no path");
    NSAssert(type != nil, @"DNTutorialAudio: Cannot initialize action with no type");
    NSAssert(key != nil, @"DNTutorialAudio: Cannot initialize action with invalid key");
    
    DNTutorialAudio *audio = [DNTutorialAudio new];
    
    @try {
        NSURL *URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:path ofType:type]];
        audio.URL = URL;
    }
    @catch (NSException *exception) {
        NSLog(@"DNTutorialAudio:   Cannot locate audio file!");
    }
    
    audio.key = key;
    return audio;
}

#pragma mark --
#pragma mark - Polimorphic Methods
#pragma mark --

- (void)setUpInView:(UIView *)aView;
{
    // Initialize audio player
    NSError *error;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.URL error:&error];
    self.audioPlayer = audioPlayer;
    
    // Check for errors
    if (error)
    {
        NSLog(@"DNTutorialAudio:   Error in audioPlayer: %@", [error localizedDescription]);
        return;
    }
    
    // Prepare to play
    audioPlayer.delegate = self;
    [audioPlayer prepareToPlay];
}

- (void)tearDown;
{
    [self.audioPlayer stop];
}

- (void)show;
{
    _actionCompleted = NO;
    
    [self.audioPlayer play];
}

- (void)dismiss;
{
    // Will dismiss element
    [_delegate willDismissElement:self];
    
    [self.audioPlayer pause];
    
    [_delegate didDismissElement:self];
}

- (void)startAnimating;
{
    return;
}

- (void)stopAnimating;
{
    return;
}

- (void)setCompleted:(BOOL)completed animated:(BOOL)animated;
{
    if (_actionCompleted && completed) {
        return;
    }
    
    _actionCompleted = completed;
    
    if (completed)
    {
        // Should dismiss
        [self dismiss];
    }
}

- (void)setPercentageCompleted:(CGFloat)percentage;
{
    // percentage alpha and position based on position
    if (percentage < 0 || _actionCompleted)
    {
        return;
    }
    
    _percentageCompleted = percentage;
    
    if (percentage >= 1.0)
    {
        // User action completed
        [self setCompleted:YES animated:NO];
    }
}

#pragma mark --
#pragma mark - Private Methods
#pragma mark --

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
{
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error;
{
    
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player;
{
    
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player;
{
    
}

@end
