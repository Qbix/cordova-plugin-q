Pod::Spec.new do |spec|
  spec.name         = 'cordova-plugin-q'
  spec.version      = '0.2'
  spec.license      = { :type => 'BSD' }
  spec.homepage     = 'https://kvofreelance@bitbucket.org/qbixtemp/cordova-plugin-q.git'
  spec.authors      = { 'Igor Martsekha' => 'igor@qbix.com' }
  spec.summary      = 'Cordova base plugin for Q plugin'
  spec.source       = { :git => 'https://kvofreelance@bitbucket.org/qbixtemp/cordova-plugin-q.git', :tag => 'v0.2' }
  spec.source_files = 'src/ios/*.{h,m}'
end