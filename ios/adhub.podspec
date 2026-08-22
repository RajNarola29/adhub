Pod::Spec.new do |s|
  s.name             = 'adhub'
  s.version          = '0.2.7'
  s.summary          = 'A Flutter package that simplifies ad integration with a unified API for banner, interstitial, and rewarded ads.'
  s.description      = <<-DESC
A Flutter package that simplifies ad integration with a unified API for banner, interstitial, and rewarded ads.
                       DESC
  s.homepage         = 'https://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'adhub' => 'noreply@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  s.dependency 'GoogleMobileAdsMediationAppLovin'
  s.dependency 'GoogleMobileAdsMediationFacebook'
  s.dependency 'GoogleMobileAdsMediationUnity'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
