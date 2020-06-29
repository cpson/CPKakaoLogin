#
# Be sure to run `pod lib lint CPKakaoLogin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CPKakaoLogin'
  s.version          = '0.1.2'
  s.summary          = 'CPKakaoLogin.'
  s.swift_version    = '5.0'
  
  s.description      = <<-DESC
Easy KAKAO Login
                       DESC

  s.homepage         = 'https://github.com/cpson/CPKakaoLogin'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cpson' => 'cpsony2k@gmail.com' }
  s.source           = { :git => 'https://github.com/cpson/CPKakaoLogin.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.source_files = 'CPKakaoLogin/Classes/**/*'
  s.static_framework = true
  s.dependency 'KakaoOpenSDK'
end
