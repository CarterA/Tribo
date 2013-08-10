# CZAFileWatcher #

CZAFileWatcher is a simple Objective-C wrapper around Apple's [FSEvents][fsevents] system for watching files. It is small (less than 100 lines of code), compact (a single header/implementation pair, no dependencies), and provides a convenient way of monitoring the filesystem for activity. CZAFileWatcher uses Automatic Reference Counting (ARC) and Objective-C Blocks.

### Installation ###

Just add `CZAFileWatcher.h` and `CZAFileWatcher.m` to your project and `#import "CZAFileWatcher.h"` whenever you need to access the class.

### Usage ###

First, set up an array of filesystem URLs:

	NSURL *desktopURL = [[NSFileManager defaultManager] URLForDirectory:NSDesktopDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSArray *URLs = @[desktopURL];

Next, instantiate a CZAFileWatcher object, keeping in mind that the object is immutable after creation:

    CZAFileWatcher *watcher = [CZAFileWatcher fileWatcherForURLs:@[desktopURL] changesHandler:^(NSArray *changedURLs) {
        // Respond to the change...
    }];

And start the watcher:

    [watcher startWatching];

That's all there is to it! You can always stop watching the URLs by calling `-stopWatching`.

A working example program (`watch-file.m`) is included in this repository. The watch-file command-line interface (CLI) accepts file paths as arguments and watches them, printing a message whenever a change is detected.

### License ###

CZAFileWatcher is released under the MIT License, which can be found in the License.md file.

[fsevents]: https://developer.apple.com/library/mac/#documentation/Darwin/Reference/FSEvents_Ref/Reference/reference.html