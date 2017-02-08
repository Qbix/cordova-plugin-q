Pod::Spec.new do |spec|
  spec.name         = 'cordova-plugin-q'
  spec.version      = '0.3'
  spec.license      = { :type => 'BSD' }
  spec.homepage     = 'https://kvofreelance@bitbucket.org/qbixtemp/cordova-plugin-q.git'
  spec.authors      = { 'Igor Martsekha' => 'igor@qbix.com' }
  spec.summary      = 'Cordova base plugin for Q plugin'
  spec.source       = { :git => 'https://kvofreelance@bitbucket.org/qbixtemp/cordova-plugin-q.git', :tag => spec.version }
  spec.source_files = 'src/ios/*.{h,m}','src/ios/**/*{g,m}','src/ios/**/**/*{g,m}','src/ios/**/**/**/*{g,m}'
  spec.resources    = 'src/ios/**/*.{storyboard}'
end