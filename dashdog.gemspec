# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dashdog/version'

Gem::Specification.new do |spec|
  spec.name          = "dashdog"
  spec.version       = Dashdog::VERSION
  spec.authors       = ["Serverworks Co.,Ltd."]
  spec.email         = ["terui@serverworks.co.jp"]

  spec.summary       = %q{Datadog dashboards management tool with Ruby DSL.}
  spec.description   = %q{Datadog dashboards management tool with Ruby DSL.}
  spec.homepage      = "https://github.com/serverworks/dashdog"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dogapi"
  spec.add_dependency "dslh", "~> 0.3.8"
  spec.add_dependency "thor", "~> 0.19.1"
  spec.add_dependency "coderay"
  spec.add_dependency "diffy"
  spec.add_dependency "parallel"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
