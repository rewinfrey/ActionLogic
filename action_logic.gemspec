require File.expand_path('../lib/action_logic/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'action_logic'
  s.summary = 'Business logic abstraction'
  s.homepage = 'https://github.com/rewinfrey/action_logic'
  s.license = 'MIT'

  s.files = `git ls-files`.split($\) - ['resources']
	s.executables = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  s.version = ActionLogic::VERSION

  s.authors = ["Rick Winfrey"]
  s.email = 'rick.winfrey@gmail.com'
  s.date = '2016-01-18'
  s.description = 'Provides common interfaces for validating and abstracting business logic'

  s.add_development_dependency("rspec", "~> 3.3")
  s.add_development_dependency("pry", "~> 0.10")
  s.add_development_dependency("rake", "~> 10")
  s.add_development_dependency("simplecov", "~> 0.10.0")
  s.add_development_dependency("coveralls", "~> 0.8.3")
end
