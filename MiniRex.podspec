Pod::Spec.new do |s|
s.name = 'MiniRex'
s.version = '1.0.3'
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.summary = 'Lightweight, easy to use and Swift-friendly generalized Publish/Subscribe types and utilities.'
s.homepage = 'https://github.com/Gabardone/MiniRex'
s.authors = { 'Óscar Morales Vivó' => 'oscarmv@mac.com' }
s.source = { :git => 'https://github.com/Gabardone/MiniRex.git', :tag => s.version }
s.swift_version = '5.0'
s.source_files = 'MiniRex/MiniRex/**/*.{swift,h}'
s.ios.deployment_target = '8.0'
s.tvos.deployment_target = '9.0'
s.watchos.deployment_target = '2.0'
s.macos.deployment_target = '10.9'
s.framework = 'Foundation'
end
