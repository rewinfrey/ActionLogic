$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))
require 'active_logic'

RSpec.configure do |c|
  #c.fail_fast = true
  c.formatter = 'documentation'
  c.order = 'rand'
end
