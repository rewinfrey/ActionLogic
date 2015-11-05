require 'fixtures/custom_types'

class Validations
  ALL_VALIDATIONS = { :integer_test => { :type => :integer, :presence => true },
                      :float_test   => { :type => :float, :presence => true },
                      :string_test  => { :type => :string, :presence => true },
                      :bool_test    => { :type => :boolean, :presence => true },
                      :hash_test    => { :type => :hash, :presence => true },
                      :array_test   => { :type => :array, :presence => true },
                      :symbol_test  => { :type => :symbol, :presence => true },
                      :nil_test     => { :type => :nil } }

  INVALID_ATTRIBUTES = { :integer_test => nil,
                         :float_test   => nil,
                         :string_test  => nil,
                         :bool_test    => nil,
                         :hash_test    => nil,
                         :array_test   => nil,
                         :symbol_test  => nil,
                         :nil_test     => 1 }

  VALID_ATTRIBUTES = { :integer_test => 1,
                       :float_test => 1.0,
                       :string_test => "string",
                       :bool_test => true,
                       :hash_test => {},
                       :array_test => [],
                       :symbol_test => :symbol,
                       :nil_test => nil }

  CUSTOM_TYPE_VALIDATION1 = { :custom_type => { :type => :customtype1, :presence => true } }

  CUSTOM_TYPE_ATTRIBUTES1 = { :custom_type => CustomType1.new }

  CUSTOM_TYPE_VALIDATION2 = { :custom_type => { :type => :customtype2, :presence => true } }

  CUSTOM_TYPE_ATTRIBUTES2 = { :custom_type => CustomType2.new }

  PRESENCE_VALIDATION = { :integer_test => { :presence => true } }

  CUSTOM_PRESENCE_VALIDATION = { :array_test => { :presence => ->(array_test) { array_test.any? } } }
end
