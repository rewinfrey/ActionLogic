# ActionLogic

[![Codeship Status for rewinfrey/action_logic](https://codeship.com/projects/7737cf40-6808-0133-84a7-460d97cd31f0/status?branch=master)](https://codeship.com/projects/114179)
[![Gem Version](https://badge.fury.io/rb/action_logic.svg)](https://badge.fury.io/rb/action_logic)
[![Code Climate](https://codeclimate.com/github/rewinfrey/action_logic/badges/gpa.svg)](https://codeclimate.com/github/rewinfrey/action_logic)
[![Coverage Status](https://coveralls.io/repos/rewinfrey/action_logic/badge.svg?branch=master&service=github)](https://coveralls.io/github/rewinfrey/action_logic?branch=master)

### Introduction

This is a business logic abstraction gem that provides structure to the organization and composition of business logic in a Ruby or Rails application. `ActionLogic` is inspired by similar gems such as [ActiveInteraction](https://github.com/orgsync/active_interaction), [DecentExposure](https://github.com/hashrocket/decent_exposure), [Interactor](https://github.com/collectiveidea/interactor), [Light-Service](https://github.com/adomokos/light-service), [Mutations](https://github.com/cypriss/mutations), [Surrounded](https://github.com/saturnflyer/surrounded), [Trailblazer](https://github.com/apotonick/trailblazer) and [Wisper](https://github.com/krisleech/wisper). Why another business logic abstraction gem? `ActionLogic` seeks to provide teams of varying experience levels to find a common set of abstractions to work with that helps honor the SOLID principles, make resulting business logic code easy and simple to test and allow teams to spin up or refactor business domains quickly and efficiently.

### Overview

There are three levels of abstraction provided by `ActionLogic`:

* `ActionTask`
* `ActionUseCase`
* `ActionCoordinator`

Each level of abstraction operates with a shared, mutable data structure referred to as a `context` and is an instance of `ActionContext`.

### ActionTask

### ActionUseCase

### ActionCoordinator

### ActionContext

### Features

`ActionLogic` provides a number of convenience functionality that supports simple to complex business logic work flows while maintaining a simple and easy to understand API:

* Validations (`context` is verified to have all necessary attributes, have `presence` and are of the correct type)
* Custom error handling defined as a callback
* Prematurely halt or fail a workflow

### Validations

Validating that a shared `context` contains the necessary attributes (parameters) becomes increasingly important as your application grows in complexity and `ActionTask` or `ActionUseCase` classes are reused. `ActionLogic` makes it easy to validate your shared `context`s by providing three different validations:

* Attribute is defined on a context
* Attribute has a value (presence)
* Attribute has the correct type

Additionally, validations can be invoked in three ways in any execution context (`ActionTask`, `ActionUseCase` or `ActionCoordinator`):

* Before validations are invoked before the execution context is invoked
* After validations are invoked after the execution context is invoked
* Aroud validations are invoked before and after the execution context is invoked

Validations are defined and made available for all execution contexts with the same methods and format:

```ruby
class ExampleActionTask
  include ActionLogic::ActionTask
  
  validates_before :attribute1 => { :type => :integer, :presence => true },
                   :attribute2 => { :type => :string, :presence => true }
                   
  validates_after  :attribute3 => { :type => :boolean, :presence => true },
                   :attribute4 => { :type => :string,  :presence => true }
  
  validates_around :ids => { :type => :array, :presence => ->(ids) { !ids.empty? } }
  
  def call
    # set attribute3 on the shared context to satisfy the `validates_after` validations
    context.attribute3 = true
    
    # set attribute4 on the shared context to satisfy the `validates_after` validations
    context.attribute4 = "an example string value"
  end
end

# In order to satisfy ExampleActionTask's `validates_before` validations, we must provide an initial
# hash of attributes and values that satisfy the `validates_before` validations:
params = {
  :attribute1 => 1,
  :attribute2 => "another example string value"
}

# In order to satisfy ExampleActionTask's `validates_around` validation, we must provide an initial
# attribute and value that will satisfy the `validates_around` validation:
params[:ids] = [1, 2, 3, 4]

ExampleActionTask.execute(params) # => <ActionContext :success=true, :attribute1=1, :attribute2="another example string value", :attribute3=true, :attribute4="an example string value", :ids=[1,2,3,4] :message="">
```

### Supported Types For Validation

`ActionLogic` supports the following built in Ruby data types:

* :string
* :boolean (rather than TrueClass or FalseClass)
* :float
* :integer (rather than FixNum)
* :array
* :hash
* :nil (rather than NilClass)

Additionally, `ActionLogic` allows you to also validate user defined types (custom types):

```ruby

class CustomType1
end

class ExampleActionTask
  include ActionLogic::ActionTask
  
  :validates_before { :custom_type_attribute => { :type => :customtype1 } }
  
  def call
  end
end
```
