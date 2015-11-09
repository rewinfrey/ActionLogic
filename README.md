# ActionLogic

[![Codeship Status for rewinfrey/action_logic](https://codeship.com/projects/7737cf40-6808-0133-84a7-460d97cd31f0/status?branch=master)](https://codeship.com/projects/114179)
[![Gem Version](https://badge.fury.io/rb/action_logic.svg)](https://badge.fury.io/rb/action_logic)
[![Code Climate](https://codeclimate.com/github/rewinfrey/action_logic/badges/gpa.svg)](https://codeclimate.com/github/rewinfrey/action_logic)
[![Coverage Status](https://coveralls.io/repos/rewinfrey/action_logic/badge.svg?branch=master&service=github)](https://coveralls.io/github/rewinfrey/action_logic?branch=master)

### Introduction

This is a business logic abstraction gem that provides structure to the organization and composition of business logic in a Ruby or Rails application. `ActionLogic` is inspired by similar gems such as [ActiveInteraction](https://github.com/orgsync/active_interaction), [DecentExposure](https://github.com/hashrocket/decent_exposure), [Interactor](https://github.com/collectiveidea/interactor), [Light-Service](https://github.com/adomokos/light-service), [Mutations](https://github.com/cypriss/mutations), [Surrounded](https://github.com/saturnflyer/surrounded), [Trailblazer](https://github.com/apotonick/trailblazer) and [Wisper](https://github.com/krisleech/wisper). 

Why another business logic abstraction gem? `ActionLogic` seeks to provide teams of varying experience levels to work with a common set of abstractions that help to honor the SOLID principles, make resulting business logic code easy and simple to test and allow teams to spin up or refactor business domains quickly and efficiently.

### Overview

There are three levels of abstraction provided by `ActionLogic`:

* `ActionTask` (the core unit of work)
* `ActionUseCase` (contains one or many `ActionTask`s)
* `ActionCoordinator` (contains two or more `ActionUseCase`s)

Each level of abstraction operates with a shared, mutable data structure referred to as a `context` and is an instance of `ActionContext`. This shared `context` is threaded through each `ActionTask`, `ActionUseCase` and / or `ActionCoordinator` until all work in the defined business logic flow are completed and the resulting `context` is returned to the original caller (typically in a Rails application this will be a controller action).

### ActionTask

At the core of every `ActionLogic` work flow is an `ActionTask`. These units of work represent where concrete work is performed. All `ActionTask`s conform to the same basic structure and incorporate all the features of `ActionLogic` including validations, error handling and the ability to mutate the shared `context` made available to the `ActionTask`.

The following is a simple example of an `ActionTask`:

```ruby
class ActionTaskExample
  include ActionLogic::ActionTask
  
  def call
    context.example_attribute1 = "Example value"
    context.example_attribute2 = 123
  end
end
```

To invoke the above `ActionTask`:

```ruby
result = ActionTaskExample.execute
result # => <ActionContext :success=true, :example_attribute1="Example value", :example_attribute2=123, :message = "">
```

This is a simple example, but shows the basic structure of `ActionTask`s and the way they can be invoked by themselves in isolation. However, many of the business logic work flows we find ourselves needing in Rails applications require multiple steps or tasks to achieve the intended result. When we have a business workflow that requires multiple tasks, we can use the `ActionUseCase` abstraction to provide organization and a deterministic order for how the required `ActionTask`s are invoked.

### ActionUseCase

Most of the time our business logic work flows can be thought of as use cases of a given domain in our Rails application. Whether that domain is a user, account or notification domain, we can abstract a series of steps that need to be performed from a controller action into a well defined use case that specifies a series of tasks in order to satisfy that use case's goal. `ActionUseCase` represents a layer of abstraction that organizes multiple `ActionTask`s and executes them in a specified order with a shared `context`:

```ruby
class ActionUseCaseExample
  include ActionLogic::ActionUseCase
  
  # The `call` method is invoked prior to invoking any of the ActionTasks defined by the `tasks` method.
  # The purpose of the `call` method allows us to prepare the shared `context` prior to invoking the ActionTasks.
  def call
    context.example_attribute1 = "Example value"
    context.example_attribute2 = 123
  end
  
  def tasks
    [ActionTaskExample1,
     ActionTaskExample2,
     ActionTaskExample3]
  end
end
```

We see in the above example that an `ActionUseCase` differs from `ActionTask` by adding a `tasks` method. The `tasks` method defines a list of `ActionTask` classes that are invoked in order with the same shared `context` passed from task1 to task2 and so on until all tasks are invoked. Additionally, `ActionUseCase` requires us to define a `call` method that allows us to prepare any necessary attributes and values on the shared `context` prior to beginning the evaluation of the `ActionTask`s defined by the `tasks` method.

We can invoke the above `ActionUseCase` in the following way:

```ruby
ActionUseCaseExample.execute()
```

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
