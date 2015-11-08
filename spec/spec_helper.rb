require 'simplecov'
SimpleCov.start

require 'coveralls'
Coveralls.wear!

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'action_logic'

RSpec.configure do |c|
  #c.fail_fast = true
  c.color = true
  c.formatter = 'documentation'
  c.order = 'rand'
end
