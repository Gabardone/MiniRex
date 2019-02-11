# MiniRex
A compendium of Reactive-like utilities to help build better Apple platform apps in Swift.

Currently features a minimalistic API for generalized Swift publish/subscribe, further development will be based on needs and demand.

## Compatibility
MiniRex is currently being developed on Xcode 10.1, using Apple's latest SDK and Swift 4.2.

It's been used and tested on macOS 10.14 and iOS 12, but should work without changes on top of any other apple platform SDK since
it only depends on Foundation.

Some of the tests are macOS based, however, and will be clearly marked as such.

It should also work with minimal changes on any older Apple OS which supports Swift deployment.

## Installation
Just clone the repo whenever it works best for your project setup, either as a submodule or as a sibling repository.

Carthage should work fine if you set up with the project's github URL. No CocoaPods support planned at this time.

## Setup
MiniRex only depends on Foundation and the Swift standard library so you can easily add the framework straight to your project. You'll
need to perform the following steps:

- Add the MiniRex project to your workspace or your project.
- Add MiniRex as a dependency on your targets that will use it.
- Add a copy phase on your application's build process to copy the framework into the application's frameworks folder.

## How to Use
The whole API is based on the Publisher template struct, which has a single method that takes in a callback that gets called with a
parameter of type Publisher.Update and returns a Subscription object.

The Subscription objects are used to manage the lifetime of the subscription. They will either end the subscription when deallocated or
when its invalidate() method is called.

A few basic rules on further usage:

- Publishers will not own anything in the object graph. Those types that vend them will be responsible for keeping the published sources
alive as long as they should.
- Publishers are also safe against their sources being deallocated or otherwise no longer producing values. They will just stop posting
updates when that happens.
- If something is termed a "published value" it will always post an update to any new subscription with the value at the time of
subscription.
- There is no intrinsic guarantee on whether posting of updates to subscribers will be synchronous of asynchronous, unless documented
by the publisher vendor. In case of doubt, use a Publisher adapter to make it behave as desired.
- All update blocks passed on subscribe calls can be assumed to escape and thus live on as long as the returned Subscription is alive. In
other words, be careful what strong references you put in them.

A number of pre-built Publishers are also included for ease of adoption:

- Transformation publisher adapters. Allow to turn the updates from one Publisher into a different update type Publisher by providing a
simple transformation block.
- NotificationCenter based publishers, to easily adapt traditional Foundation notifications into MiniRex API.
- KVO based publishers, to easily adapt KVO observation into MiniRex API.
- A constant published value that just sends back an immutable value to new subscribers. Useful for testing purposes and implementation
of Publisher-vending protocols.
- A basic PublishedValue class that can be used to vend both a property and a Publisher that updates its subscribers when it changes. The
semantics of Publish/Subscribe imply reference, and besides the act of subscribing/unsubscribing require modification of the ultimate
publisher source, so it has to be a class instead of a struct.

## Contributing Ideas
While this framework is not based on particularly revolutionary ideas, I would love for it to be useful to a wide variety of developers. If you
feel a particular improvement would make it more so please let me know.

## To Do

- Filtering Publisher adapters.
- Queue-dispatching Publisher adapters.
- Tasks.

## Release History
* 0.1.0 (20181028)
 * First API version..

## License
Copyright 2018 Óscar Morales Vivó

Licensed under the MIT License: http://www.opensource.org/licenses/mit-license.php
