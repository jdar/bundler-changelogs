lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bundler/console/version'

Gem::Specification.new do |spec|
  spec.name          = 'bundler-console'
  spec.version       = Bundler::Console::VERSION
  spec.authors       = ['Kevin Deisz']
  spec.email         = ['kevin.deisz@gmail.com']

  spec.summary       = 'A bundler plugin that starts an IRB session with your gem dependencies.'
  spec.homepage      = 'https://github.com/kddeisz/bundler-console'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16.a'
  spec.add_development_dependency 'rake', '~> 12.2'
  spec.add_development_dependency 'minitest', '~> 5.10'
end