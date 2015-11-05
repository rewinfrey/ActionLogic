require File.expand_path('../lib/action_logic/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'action_logic'
  s.version = ActionLogic::VERSION
  s.date = '2015-11-03'
  s.summary = 'Business logic abstraction'
  s.description = 'Provides common interfaces for validating and abstracting business logic'
  s.authors = ["Rick Winfrey"]
  s.email = 'rick.winfrey@gmail.com'
  s.files = ["lib/action_logic.rb"]
  s.require_paths = ["lib"]
  s.homepage = 'https://github.com/bashrw/action_logic'
  s.license = 'MIT'

  s.add_development_dependency("rspec", "~> 3.3")
  s.add_development_dependency("pry", "~> 0.10")
end
