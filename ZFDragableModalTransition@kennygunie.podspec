#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "ZFDragableModalTransition@kennygunie"
  s.version          = "0.4"
  s.summary          = "fork of kennygunie"
  s.homepage         = "https://github.com/kennygunie/ZFDragableModalTransition"
  s.license          = 'MIT'
  s.author           = { "Amornchai Kanokpullwad" => "amornchai.zoon@gmail.com",
                        "Kien NGUYEN" => "kennygunie@gmail.com" }
  s.source           = { :git => "https://github.com/kennygunie/ZFDragableModalTransition.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.1'
  s.ios.deployment_target = '7.1'
  s.requires_arc = true

  s.source_files = 'Classes'

end
