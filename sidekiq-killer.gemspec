# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sidekiq/killer/version"

Gem::Specification.new do |spec|
  spec.name          = "noxa-sidekiq-killer"
  spec.version       = Sidekiq::Killer::VERSION
  spec.authors       = ["Karst Hammer"]
  spec.email         = ["k.hammer@youngcapital.nl"]

  spec.summary       = %q{Quiets and kills sidekiq when memory usage is too high}
  spec.description   = %q{Quiets and kills sidekiq processes when the RSS memory usage is too high.}
  spec.homepage      = "https://github.com/Noxa/sidekiq-killer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "get_process_mem"
  spec.add_dependency "sidekiq"
end
