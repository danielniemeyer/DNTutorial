#
# Be sure to run `pod lib lint DNTutorial.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "DNTutorial"
  s.version          = "0.1.0"
  s.summary          = "DNTutorial manages a set of tutorial objects that interact with the user."
  s.description      = <<-DESC
                       DNTutorial manages a set of tutorial objects that interact with the user.
 Once the user completes a task, the tutotial message will never be displayed again.
 If the user interacts with a feature that could toggle a tutorial message, that message should never be displayed to the user.

 Tutorials consist of multiple types and all elements inheret from a single DNTutorialElement base class.
 DNTutorialBanner displays a banner with an appropriate message and an action that triggers its dismissal.
 DNTutorialGesture displays a gesture motion with a starting location and direction.
 DNTutorialBoth displays a gesture montion alongside a banner with a progress banner
                       DESC
  s.homepage         = "https://github.com/danielniemeyer/DNTutorial"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Daniel Niemeyer" => "danieldn94@gmail.com" }
  s.source           = { :git => "https://github.com/danielniemeyer/DNTutorial.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/danielniemeyer'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resources = 'Pod/Assets/*.png'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
