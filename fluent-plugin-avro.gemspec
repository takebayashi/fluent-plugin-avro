# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-avro"
  spec.version       = "0.0.3"
  spec.authors       = ["Shun Takebayashi"]
  spec.email         = ["shun@takebayashi.asia"]

  spec.description   = "Avro formatter plugin for Fluentd"
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/takebayashi/fluent-plugin-avro"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "avro", "~> 1.8"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit", "~> 3.1"
  spec.add_runtime_dependency "fluentd", "~> 0.12.0"
end
