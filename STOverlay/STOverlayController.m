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
    overlayView.label = label;
    overlayView.bezelRadius = radius;
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

- (void)endOverlay {
    NSWindow *parentWindow = _overlayWindow.parentWindow;
    [parentWindow removeChildWindow:_overlayWindow];
    [_overlayWindow close];
    _overlayWindow = nil;
    [_targetView removeObserver:self forKeyPath:@"frame"];
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
