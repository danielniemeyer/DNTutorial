# DNTutorial

[![CI Status](http://img.shields.io/travis/danielniemeyer/DNTutorial.svg?style=flat)](https://travis-ci.org/danielniemeyer/DNTutorial)
[![Version](https://img.shields.io/cocoapods/v/DNTutorial.svg?style=flat)](http://cocoadocs.org/docsets/DNTutorial)
[![License](https://img.shields.io/cocoapods/l/DNTutorial.svg?style=flat)](http://cocoadocs.org/docsets/DNTutorial)
[![Platform](https://img.shields.io/cocoapods/p/DNTutorial.svg?style=flat)](http://cocoadocs.org/docsets/DNTutorial)

## Introduction

App Tutorial inspirations

- https://github.com/lostinthepines/TutorialKit
- https://github.com/kronik/UIViewController-Tutorial

## TODO

- Dismiss objects based on user actions
- Look into NSObject as the base type for tutorialElements
- Add a tutorial step middleman object that handles tutorial progress of middle objects and can take a block before shouldPresentObject: with an associated key.

- Generalize tutorial system to take many tutorial objects as inputs √
- Flexible implementation with polimorphic base classes for easy cuztomizable subclasses √
- Pass tutorial key as viewcontroller class name and use it to track current tutorial state √
- Save state on user defualts √

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

DNTutorial is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "DNTutorial"

## Author

Daniel Niemeyer, danieldn94@gmail.com

## License

DNTutorial is available under the MIT license. See the LICENSE file for more info.

