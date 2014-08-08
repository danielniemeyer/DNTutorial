# DNTutorial

[![CI Status](http://img.shields.io/travis/danielniemeyer/DNTutorial.svg?style=flat)](https://travis-ci.org/danielniemeyer/DNTutorial)
[![Version](https://img.shields.io/cocoapods/v/DNTutorial.svg?style=flat)](http://cocoadocs.org/docsets/DNTutorial)
[![License](https://img.shields.io/cocoapods/l/DNTutorial.svg?style=flat)](http://cocoadocs.org/docsets/DNTutorial)
[![Platform](https://img.shields.io/cocoapods/p/DNTutorial.svg?style=flat)](http://cocoadocs.org/docsets/DNTutorial)

DNTutorial manages a set of tutorial elements that guide the user on how to interact with your app.

The implementation of DNTutorial is very simple and was mainly by Paper from Facebook.


## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

To use DNTutorial, import the DNTutorial header file to your view controller and add it as a delegate of DNTutorial.
To present a tutorial, simply create the tutorial elements you would like to present.

An example of creating a tutorial sequence.

<DNTutorialBanner *banner = [DNTutorialBanner bannerWithMessage:@"A banner message" completionMessage:@"Completion message" key:@"banner"];
    
    DNTutorialGesture *scrollGesture = [DNTutorialGesture gestureWithPosition:center type:DNTutorialGestureTypeScrollLeft key:@"gesture"];

    DNTutorialStep *step = [DNTutorialStep stepWithTutorialElements:@[banner, scrollGesture] forKey:@"step"];
    
    [DNTutorial presentTutorialWithSteps:@[step1] inView:self.view delegate:self];>


To style the appearance of a banner simply call the style method

<[banner styleWithColor:[UIColor blackColor] completedColor:[UIColor blueColor] opacity:0.7 font:[UIFont systemFontOfSize:13]];>

## Customization

DNTutorial comes with two standard tutorial elements (DNTutorialBanner, DNTutorialGesture).

Both standard classes derive from the same base class, DNTutorialElement.
This polimorphic class provides an easy framework for you to come up with your own tutorial element subclasses that can
work with the tutorial system right from outside the box.

And if you come up with a cool class, just submit a pull request so that I can add it to the repo.

## Installation

There are two options:

1. DNTutorial is available as DNTutorial in [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "DNTutorial"

2. Manually add the files into your Xcode project. Slightly simpler, but updates are also manual.

DNTutorial requires iOS 7 or later.

## TODO

- Add ability to hide and show a tutorial step and see how it syncs with skipping a tutorial step.

- Dismiss objects based on user actions √
- Look into NSObject as the base type for tutorialElements √
- Add a tutorial step middleman object that handles tutorial progress of middle objects and can take a block before shouldPresentObject: with an associated key √

- Generalize tutorial system to take many tutorial objects as inputs √
- Flexible implementation with polimorphic base classes for easy customizable subclasses √
- Pass tutorial key as viewcontroller class name and use it to track current tutorial state √
- Save state on user defaults √

## Author

Daniel Niemeyer

## License

DNTutorial is available under the MIT license. See the LICENSE file for more info.