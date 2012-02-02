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

@implementation STOverlayController {
    STOverlayWindow *_overlayWindow;
    NSView *_targetView;
}

- (void)beginOverlayToView:(NSView *)targetView {
    _targetView = targetView;
    [targetView addObserver:self
                 forKeyPath:@"frame"
                    options:NSKeyValueObservingOptionNew
                    context:NULL];
    NSWindow *parentWindow = _targetView.window;
    NSRect overlayRect = [parentWindow convertRectToScreen:_targetView.frame];
    _overlayWindow = [[STOverlayWindow alloc] initWithContentRect:overlayRect];
    [parentWindow addChildWindow:_overlayWindow ordered:NSWindowAbove];
}

- (void)endOverlay {
    NSWindow *parentWindow = _overlayWindow.parentWindow;
    [parentWindow removeChildWindow:_overlayWindow];
    [_overlayWindow close];
    _overlayWindow = nil;
    [_targetView removeObserver:self forKeyPath:@"frame"];
    _targetView = nil;
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
        NSRect overlayRect = [parentWindow convertRectToScreen:_targetView.frame];
        [_overlayWindow setFrame:overlayRect display:NO];
    }
}

@end
