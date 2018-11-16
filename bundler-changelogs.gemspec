# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bundler/changelogs/version'

Gem::Specification.new do |spec|
  spec.name          = 'bundler-changelogs'
  spec.version       = Bundler::Changelogs::VERSION
  spec.authors       = ['Darius Roberts']
  spec.email         = ['darius.roberts@gmail.com']

  spec.summary       = 'A bundler plugin that shows changelogs of ' \
                       'your gem dependencies that specify changelog urls [not yet filtered to git version updates].'
  spec.homepage      = 'https://github.com/jdar/bundler-changelogs'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.11'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rubocop', '~> 0.58'
  spec.add_development_dependency 'simplecov', '~> 0.15'
end
