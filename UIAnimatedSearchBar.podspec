#
# Be sure to run `pod lib lint UIAnimatedSearchBar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UIAnimatedSearchBar'
  s.version          = '0.0.2'
  s.summary          = 'UIAnimatedSearchBar in an animated search bar with similar functionality to UISearchBar'

  s.description      = <<-DESC
The UIAnimatedSearchBar is similar to the standard UISearchBar but with the added animation of the search glass. I have tried to add the same functionality that UISearchBar comes with. The cancel button and the bookmark button can both be added just like UISearchBar. Additionally there is a UIAnimatedSearchBarDelegate that mirrors the same functionality that UISearchBarDelegate offers.
                       DESC

  s.homepage         = 'https://github.com/KyleBurkholder/UIAnimatedSearchBar'
  s.screenshots     = 'https://raw.githubusercontent.com/KyleBurkholder/UIAnimatedSearchBar/master/Example/Tests/ReferenceImages/Tests/Customization__Bookmark_button_shows_iPhone11_4_320x568%402x.png', 'https://raw.githubusercontent.com/KyleBurkholder/UIAnimatedSearchBar/master/Example/Tests/ReferenceImages/Tests/Customization__placeholder_text_works_iPhone11_4_320x568%402x.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'KyleBurkholder' => 'kburkho@gmail.com' }
  s.source           = { :git => 'https://github.com/KyleBurkholder/UIAnimatedSearchBar.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/_KyleBurkholder'

  s.ios.deployment_target = '11.0'
  s.swift_version = '4.0'

  s.source_files = 'UIAnimatedSearchBar/Classes/**/*'

  s.resource = 'UIAnimatedSearchBar/Assets/*.xcassets'
end
