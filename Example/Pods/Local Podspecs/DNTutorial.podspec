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
  s.version          = "0.1.2"
  s.summary          = "DNTutorial provides an easy to use introductory tutorial system based on Paper by Facebook."
  s.description      = <<-DESC
                       DNTutorial provides an easy to use introductory tutorial system based on Paper by Facebook.
 Once the user completes a task, the tutorial message will never be displayed again.
 If the user interacts with a feature that could toggle a tutorial message, that message should never be displayed to the user.
 s
                       DESC
  s.homepage         = "https://github.com/danielniemeyer/DNTutorial"
  s.screenshots      = "http://f.cl.ly/items/3o0n1K2V2z1L1e0t2X09/tutorial.gif"
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
