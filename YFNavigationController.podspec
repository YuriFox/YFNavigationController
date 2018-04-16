Pod::Spec.new do |s|

  s.name         = "YFNavigationController"
  s.version      = "1.0"
  s.summary      = "YFNavigationController is custom UINavigationController"


  s.homepage     = "https://github.com/YuriFox/YFNavigationController"

  s.license      = { :type => "Apache 2.0", :file => "LICENSE" }

  s.author             = { "YuriFox" => "yuri17fox@gmail.com" }

  s.platform     = :ios, "9.0"
  #

  s.source       = { :git => "https://github.com/YuriFox/YFNavigationController.git", :tag => s.version.to_s }

  s.source_files  = "YFNavigationController/*.swift"

end
