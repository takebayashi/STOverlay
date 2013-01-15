// 
// Copyright (c) 2012, Shun Takebayashi
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// 

#import "STOverlayController.h"
#import "STOverlayWindow.h"
#import "STOverlayView.h"

@interface STOverlayController ()

- (void)beginOverlayToView:(NSView *)targetView withLabel:(NSString *)label radius:(CGFloat)radius;

@end

@implementation STOverlayController {
    STOverlayWindow *_overlayWindow;
    __weak NSView *_targetView;
    NSButton *closeButton;
}

@synthesize labelColor = _labelColor, labelFont = _labelFont;

- (id)init {
    self = [super init];
    if (self) {
        //init label font and color properties
        self.labelFont = [NSFont systemFontOfSize:48.0];
        self.labelColor  = [NSColor redColor];
        self.hasCloseButton = YES;
    }
    
    return self;
}

- (void)createCloseButtonInView:(NSView *)overlayView {
    if (closeButton) {
        closeButton = nil;
    }
    
    CGRect f = CGRectZero;
    f.size.width = f.size.height = 24;
    closeButton = [[NSButton alloc] initWithFrame:f];
    closeButton.imagePosition = NSImageOnly;
    closeButton.image = [NSImage imageNamed:@"close"];
    closeButton.bezelStyle = NSShadowlessSquareBezelStyle;
    [closeButton setBordered:NO];
    closeButton.showsBorderOnlyWhileMouseInside = YES;
    [[closeButton cell] setHighlightsBy:NSChangeGrayCellMask];
    
    [closeButton setButtonType:NSMomentaryChangeButton];
    
    closeButton.action = @selector(closeButtonPressed:);
    closeButton.target = self;
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [overlayView addSubview:closeButton];
    
    //make button sits in top right corner
    NSMutableArray *constraints = [NSMutableArray array];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"[closeButton(24)]-6-|"
                                      options:0
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(closeButton)]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|-6-[closeButton(24)]"
                                      options:0
                                      metrics:nil
                                      views:NSDictionaryOfVariableBindings(closeButton)]];
    
    [overlayView addConstraints:constraints];
}

- (void)beginOverlayToView:(NSView *)targetView withLabel:(NSString *)label radius:(CGFloat)radius {
    _targetView = targetView;
    [targetView addObserver:self
                 forKeyPath:@"frame"
                    options:NSKeyValueObservingOptionNew
                    context:NULL];
    NSWindow *parentWindow = _targetView.window;
    NSRect overlayRect = [parentWindow convertRectToScreen:[_targetView.superview convertRectToBacking:_targetView.frame]];
    _overlayWindow = [[STOverlayWindow alloc] initWithContentRect:overlayRect];
    [_overlayWindow setReleasedWhenClosed:NO];
    STOverlayView *overlayView = [_overlayWindow overlayView];
    //configure label
    overlayView.label = label;
    overlayView.labelColor = self.labelColor;
    overlayView.labelFont = self.labelFont;
    overlayView.bezelRadius = radius;
    
    //create button if needed
    if (self.hasCloseButton) {
        [self createCloseButtonInView:overlayView];
    }
    
    [parentWindow addChildWindow:_overlayWindow ordered:NSWindowAbove];
}

- (void)beginOverlayToView:(NSView *)targetView
                 withLabel:(NSString *)label
                    radius:(CGFloat)radius
                    offset:(CGFloat)offset {
    [self beginOverlayToView:targetView withLabel:label radius:radius];
    NSDictionary *metrics = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:offset]
                                                        forKey:@"offset"];
    NSDictionary *views = [NSDictionary dictionaryWithObject:[_overlayWindow overlayView]
                                                      forKey:@"overlayView"];
    NSMutableArray *constraints = [NSMutableArray array];
    
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(offset)-[overlayView]-(offset)-|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(offset)-[overlayView]-(offset)-|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:views]];
    
    [_overlayWindow.contentView addConstraints:constraints];
}

- (void)beginOverlayToView:(NSView *)targetView
                 withLabel:(NSString *)label
                    radius:(CGFloat)radius
                    offset:(CGFloat)offset
                 hideAfter:(NSInteger)delay {
    [self beginOverlayToView:targetView withLabel:label radius:radius offset:offset];
    
    [self hideOverlayAfter:delay];
}

- (void)beginOverlayToView:(NSView *)targetView
                 withLabel:(NSString *)label
                    radius:(CGFloat)radius
                      size:(NSSize)size {
    [self beginOverlayToView:targetView withLabel:label radius:radius];
    NSDictionary *metrics = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat:size.width], @"width",
                             [NSNumber numberWithFloat:size.height], @"height",
                             nil];
    STOverlayView *overlayView = [_overlayWindow overlayView];
    NSDictionary *views = NSDictionaryOfVariableBindings(overlayView);
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"[overlayView(width)]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[overlayView(height)]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:overlayView
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_overlayWindow.contentView
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:overlayView
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_overlayWindow.contentView
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0]];
    [_overlayWindow.contentView addConstraints:constraints];
}

- (void)beginOverlayToView:(NSView *)targetView
                 withLabel:(NSString *)label
                    radius:(CGFloat)radius
                      size:(NSSize)size
                 hideAfter:(NSInteger)delay {
    [self beginOverlayToView:targetView withLabel:label radius:radius size:size];
    
    [self hideOverlayAfter:delay];
    
}

- (void)hideOverlayAfter:(NSInteger)delay {
    //set timeout to hide view
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        [self endOverlay];
    });
}

- (void)endOverlay {
    NSWindow *parentWindow = _overlayWindow.parentWindow;
    [parentWindow removeChildWindow:_overlayWindow];
    [_overlayWindow close];
    _overlayWindow = nil;
    [_targetView removeObserver:self forKeyPath:@"frame"];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self endOverlay];
}

- (BOOL)isOverlay {
    return _overlayWindow != nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"frame"] && object == _targetView) {
        NSWindow *parentWindow = _targetView.window;
        NSRect overlayRect = [parentWindow convertRectToScreen:[_targetView.superview convertRectToBacking:_targetView.frame]];
        [_overlayWindow setFrame:overlayRect display:NO];
    }
}

@end
