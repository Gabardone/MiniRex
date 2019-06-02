Pod::Spec.new do |podspec|
    podspec.name = 'MiniRex'
    podspec.version = '2.0.0'
    podspec.license = { :type => 'MIT', :file => 'LICENSE' }
    podspec.summary = 'Lightweight, easy to use and Swift-friendly generalized Publish/Subscribe types and utilities.'
    podspec.homepage = 'https://github.com/Gabardone/MiniRex'
    podspec.authors = { 'Oscar Morales Vivo' => 'oscarmv@mac.com' }
    podspec.source = { :git => 'https://github.com/Gabardone/MiniRex.git', :tag => 'MiniRex-2.0.0' }
    podspec.swift_version = '5.0'
    podspec.source_files = 'MiniRex/MiniRex/**/*.{swift,h}'
    podspec.ios.deployment_target = '8.0'
    podspec.macos.deployment_target = '10.9'
    podspec.tvos.deployment_target = '9.0'
    podspec.watchos.deployment_target = '2.0'
    podspec.framework = 'Foundation'

    podspec.test_spec 'MiniRexTests' do |test_spec|
        # Skipping watchOS on tests due to lack of XCTest support.
        test_spec.ios.deployment_target = '8.0'
        test_spec.macos.deployment_target = '10.9'
        test_spec.tvos.deployment_target = '9.0'
        test_spec.source_files = 'MiniRex/MiniRexTests/**/*.{swift}'
    end
end
