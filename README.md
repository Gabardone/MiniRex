# MiniRex
A compendium of Reactive-like utilities to help build better Apple platform apps in Swift.

Currently features a minimalistic API for generalized Swift publish/subscribe, further development will be based on needs and demand.

## Compatibility
MiniRex is currently being developed on Xcode 10.2, using Apple's latest SDK and Swift 5.

It's been used and tested on latest versions of macOS 10.14 and iOS 12, but should work without changes on top of any other apple
platform SDK since it only depends on Foundation. It's also currently being deployed on at least one mac app store released product
that supports macOS 10.11 and up.

It should also work with minimal changes on any older Apple OS which supports Swift deployment (currently macOS 10.9+ and iOS 7+).

## Installation
Carthage is the recommended approach to integrate MiniRex on an existing project. It works fine if set up with the project's github URL.

Or just get it through CocoaPods if that's your thing. Pod name is "MiniRex"

One can also just clone the repo whenever it works best for your project setup, either as a submodule or as a sibling repository.

## Setup
MiniRex only depends on Foundation and the Swift standard library so you can easily add the framework straight to your project. You'll
need to perform the following steps:

- Add the MiniRex project to your workspace or your project.
- Add MiniRex as a dependency on your targets that will use it.
- Add a copy phase on your application's build process to copy the framework into the application's frameworks folder.

## How to Use
The whole API is based on the Publisher template protocol, which has a single method that takes in a callback that gets called with a
parameter of type Publisher.Update and returns a Subscription object.

The Subscription objects are used to manage the lifetime of the subscription. They will either end the subscription when deallocated or
when its invalidate() method is called.

A few basic rules on further usage:

- Publishers should not own anything in the object graph. Those types that vend them will be responsible for keeping the published
sources alive as long as they should.
- Publishers should also be safe against their sources being deallocated or otherwise no longer producing values. They will just stop
posting updates when that happens.
- There is no intrinsic guarantee on whether posting of updates to subscribers will be synchronous of asynchronous, unless
documented by the publisher vendor. In case of doubt, use a Publisher dispatch adapter to make it behave as desired.
- Unless otherwise documented or using a dispatch adapter (see below) there's also no guarantee on what queue the updates will
happen in.
- All update blocks passed on subscribe calls can be assumed to escape and thus live on as long as the returned Subscription is alive.
In other words, be careful what strong references you put in them.
- There's currently three types of publishers depending on their behavior. They all implement the Publisher protocol but have their own
semantics, initializers and utilities. Any documentation that refers to the below terms is assuming that the behaviors described for them
will be applying. They are the following:
  * **Broadcasters**: Of type `Broadcaster<Update>` Offer no guarantees for when updates are called. Examples are notification
  publishers. event publishers or publishers that update subscribers on a repeating  timer. Examples include notification broadcaster
  adapters and the `SimpleBroadcaster<Update>` type.
  * **Published Values**: Of type `Published<Value>` These are vending a specific type of value. Subscribing to them will always
  trigger an initial update callback with the value current at the time of subscription (this call need not be synchronous although it could
  be). Further update calls will happen as the published value changes. `Equatable` values will only update subscribers when their
  value change, non-equatable reference types when their identity changes. Examples include KVO publishers which include the .initial
  KVO observation option, and the PublishedProperty class' `publishedValue` property.
  * **Tasks**: These model asynchronous casts. They may optionally post updates with task progress but once they post anupdate with
  an error or the result of the task they are guaranteed to not post any further updates.

A number of pre-built Utilities are also included for ease of adoption:

- Transformation publisher adapters. Those for `Published<Value>` will preserve equality/identity semantics when possible. The ones
for `Broadcaster<Update>` will just post the transformed update values.
- NotificationCenter based `Broadcaster`, to easily adapt traditional Foundation notifications into MiniRex API.
- KVO based publishers (including prebuilt `Published<Value>` types), to easily adapt KVO observation into MiniRex API.
- A constant `Published<Value>` that just sends back an immutable value to new subscribers. Useful for testing purposes and stub
implementation of published value-vending protocols.
- A basic PublishedProperty class that can be used to vend both a property and a `Published<Value>` that updates its subscribers
when it changes. The semantics of Publish/Subscribe imply reference, and besides the act of subscribing/unsubscribing require
modification of the ultimate publisher source, so it has to be a class instead of a struct.
- Dispatch adapters, for all kind of Publisher types, both for subscription and for update callbacks. They make it easy to build
components that do their work on a specific queue, bridging other work being done in different dispatch queues.
- Tasks for URL Data downloads and file reads. Feed either of them a URL, then subscribe to the returned Task to initiate the
download/file read.

## Contributing Ideas
While this framework is not based on particularly revolutionary ideas, I would love for it to be useful to a wide variety of developers. If you
feel a particular improvement would make it more so please let me know.

## To Do

- Tasks test coverage.

## Release History
* 2.0.0 (20190602): New API, full unit test coverage for `Broadcaster<Update>` & `Published<Value>`
* 1.0.5 (20190417): Fix to SimpleBroadcaster (couldn't be initialized from outside the library). Added several missing unit tests.
* 1.0.4 (20190415): Support for CocoaPods
* 1.0.3 (20190411): Fixes for URL data task cancelation flow.
* 1.0.2 (20190411): Fixes for Task and added URL data Task (for your take home interview software project needs)
* 1.0.1 (20190409): Initial implementation of generic Task publishers and single update subscriptions.
* 1.0.0 (20190407): Adopted naming conventions throughout for Publisher behavior (Broadcaster/Published Value/Task). Renaming of type
means this release is not compatible with prior versions but updating should be simple enough.
* 0.2.3 (20190221): Fixed crashing issues related to nullable property KVO published values.
* 0.2.2 (20190212): Efficient published value behavior for `Equatable` and reference types.
* 0.2.1 (20190212): Added published value transformer utilities.
* 0.2.0 (20190211): Added Carthage support
* 0.1.0 (20181028): First API version..

## License
Copyright 2018-2019 Óscar Morales Vivó

Licensed under the MIT License: http://www.opensource.org/licenses/mit-license.php
