Pod::Spec.new do |s|
  s.name        = "SwifterJSON"
  s.version     = "1.1"
  s.summary     = "SwifterJSON makes it easy to deal with JSON data in Swift"
  s.homepage    = "https://github.com/rokgregoric/SwifterJSON"
  s.license     = { :type => 'MIT', :file => 'LICENSE' }
  s.author      = { "rokgregoric" => "rok.gregoric@gmail.com" }

  s.requires_arc = true
  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source   = { :git => "https://github.com/rokgregoric/SwifterJSON.git", :tag => s.version }
  s.source_files = "Source/*.swift"
end