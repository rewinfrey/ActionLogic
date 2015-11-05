class Validations
  ALL_VALIDATIONS = { :integer_test => { :type => :integer, :presence => true },
                      :float_test   => { :type => :float, :presence => true },
                      :string_test  => { :type => :string, :presence => true },
                      :bool_test    => { :type => :boolean, :presence => true },
                      :hash_test    => { :type => :hash, :presence => true },
                      :array_test   => { :type => :array, :presence => true },
                      :symbol_test  => { :type => :symbol, :presence => true },
                      :nil_test     => { :type => :nil } }
end
