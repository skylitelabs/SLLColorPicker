Pod::Spec.new do |s|
  s.name         = 'SLLColorPicker'
  s.version      = '0.0.1'
  s.license      =  { :type => 'MIT', :file => 'LICENSE' }
  s.authors      =  { 'Leejay Schmidt' => 'leejay.schmidt@skylite.io' }
  s.summary      = 'A simple, circular color picker for iOS written in Objective C'
  s.homepage     = 'https://github.com/skylitelabs/SLLColorPicker'

# Source Info
  s.platform     =  :ios, '8.0'
  s.source       =  { :git => 'https://github.com/skylitelabs/SLLColorPicker.git', :tag => "0.0.1" }
  s.source_files = 'SLLColorPicker/SLLColorPicker.{h,m}'

  s.requires_arc = true
end
