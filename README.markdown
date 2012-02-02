# STOverlay

## What's this?

STOverlay is a Cocoa classes for transparent overlay.

## Usage

``` objc
- (IBAction)beginOverlay:(id)sender {
    // self.overlay is an instance of STOverlayController
    [self.overlayController beginOverlayToView:self.targetView
                                     withLabel:@"Loading..."
                                        offset:20.0
                                        radius:10.0];
}

- (IBAction)endOverlay:(id)sender {
    [self.overlayController endOverlay];
}
```

## Screenshots

* [Screenshot #1](http://gyazo.com/538f74d88d41395c14810639c8225919)
* [Screenshot #2](http://gyazo.com/e20a18f1a606f102488eca8c9df9ed7e)

# License

The BSD License
