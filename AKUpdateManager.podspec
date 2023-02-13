Pod::Spec.new do |s|

s.name = "AKUpdateManager"
s.summary = "AKUpdateManager manages your app updates."
s.requires_arc = true

s.version = "1.0.1"
s.license = { :type => "MIT", :file => "LICENSE" }
s.author = { "Amr Koritem" => "amr.koritem92@gmail.com" }
s.homepage = "https://github.com/AmrKoritem/AKUpdateManager"
s.source = { :git => "https://github.com/AmrKoritem/AKUpdateManager.git",
             :tag => "v#{s.version}" }

s.framework = "UIKit"
s.source_files = "Sources/AKUpdateManager/**/*.{swift}"
s.swift_version = "5.0"
s.ios.deployment_target = '13.0'
s.tvos.deployment_target = '13.0'

end
