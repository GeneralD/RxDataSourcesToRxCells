Pod::Spec.new do |s|
	s.name = 'RxDataSourcesToRxCells'
	s.version = '0.0.1'
	s.license = { :type => "MIT", :file => "LICENSE" }
	s.summary = 'Supports to use both RxCells and RxDataSources.'
	s.homepage = 'https://github.com/GeneralD/RxDataSourcesToRxCells'
	s.social_media_url = 'https://twitter.com/TheDreamBoss'
	s.authors = { "Yumenosuke" => "yumejustice@gmail.com" }
	s.source = { :git => "https://github.com/GeneralD/RxDataSourcesToRxCells.git", :tag => s.version.to_s }

	s.ios.deployment_target = '9.0'
	s.requires_arc = true
	s.swift_versions = '5.0'

	s.dependency 'RxSwift', '~> 5'
	s.dependency 'RxCocoa', '~> 5'
	s.dependency 'RxCells'
	s.dependency 'RxDataSources'
	s.dependency 'Reusable'

	s.framework  = "Foundation"
	s.framework  = "UIKit"

	s.source_files = "Sources/*.swift"
end
