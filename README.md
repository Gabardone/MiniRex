# MiniRex
A compendium of Reactive-like utilities to help build better Apple platform apps in Swift.

## Compatibility
MiniRex is currently being developed on Xcode 10.0, using Apple's latest SDK and Swift 4.2.

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
TBD

## Contributing Ideas
TBD

## Release History
* 0.0.1 (20181028)
 * Initial commit.

## License
Copyright 2018 Óscar Morales Vivó

Licensed under the MIT License: http://www.opensource.org/licenses/mit-license.php
