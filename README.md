# ActionLogic

[![Codeship Status for rewinfrey/action_logic](https://codeship.com/projects/7737cf40-6808-0133-84a7-460d97cd31f0/status?branch=master)](https://codeship.com/projects/114179)
[![Gem Version](https://badge.fury.io/rb/action_logic.svg)](https://badge.fury.io/rb/action_logic)
[![Code Climate](https://codeclimate.com/github/rewinfrey/action_logic/badges/gpa.svg)](https://codeclimate.com/github/rewinfrey/action_logic)
[![Coverage Status](https://coveralls.io/repos/rewinfrey/action_logic/badge.svg?branch=master&service=github)](https://coveralls.io/github/rewinfrey/action_logic?branch=master)

### Introduction

This is a business logic abstraction gem that provides structure to the organization and composition of business logic in a Ruby or Rails application. `ActionLogic` is inspired by gems like [ActiveInteraction](https://github.com/orgsync/active_interaction), [DecentExposure](https://github.com/hashrocket/decent_exposure), [Interactor](https://github.com/collectiveidea/interactor), [Light-Service](https://github.com/adomokos/light-service), [Mutations](https://github.com/cypriss/mutations), [Surrounded](https://github.com/saturnflyer/surrounded), [Trailblazer](https://github.com/apotonick/trailblazer) and [Wisper](https://github.com/krisleech/wisper).

Why another business logic abstraction gem? `ActionLogic` provides teams of various experience levels with a minimal yet powerful set of abstractions that promote easy to write and easy to understand code. By using `ActionLogic`, teams can more quickly and easily write business logic that honors the SOLID principles, is easy to test and easy to reason about, and provides a flexible foundation from which teams can model and define their application's business domains by focusing on reusable units of work that can be composed and validated with one another.

### Contents

* [`ActionContext`](#action_context)
* [`ActionTask`](#action_task)
* [`ActionUseCase`](#action_use_case)
* [`ActionCoordinator`](#action_coordinator)
* [Succeeding an `ActionContext`](#succeed_context)
* [Failing an `ActionContext`](#fail_context)
* [Halting an `ActionContext`](#halt_context)
* [Custom `ActionContext` Status](#custom_status)
* [Error Handling](#error_handling)
* [Attribute Validations](#attribute_validations)
* [Type Validations](#type_validations)
* [Custom Type Validations](#custom_type_validations)
* [Presence Validations](#presence_validations)
* [Custom Presence Validations](#custom_presence_validations)
* [Before Validations](#before_validations)
* [After Validations](#after_validations)
* [Around Validations](#around_validations)

### Overview

At the core
There are three levels of abstraction provided by `ActionLogic`:

* [`ActionTask` (the core unit of work)](#actiontask)
* [`ActionUseCase` (contains one or many `ActionTasks`)](#actionusecase)
* [`ActionCoordinator` (contains two or more `ActionUseCases`)](#actioncoordinator)

Each level of abstraction operates with a shared, mutable data structure referred to as a `context` and is an instance of `ActionContext`. This shared `context` is threaded through each `ActionTask`, `ActionUseCase` and / or `ActionCoordinator` until all work is completed. The resulting `context` is returned to the original caller (typically in a Rails application this will be a controller action).

### ActionTask<a name="actiontask"></a>

At the core of every `ActionLogic` work flow is an `ActionTask`. These classes are the lowest level of abstraction in `ActionLogic` and are where concrete work is performed. All `ActionTasks` conform to the same structure and incorporate all features of `ActionLogic` including validations and error handling.

The following is a simple example of an `ActionTask` that includes before and after validations, and also demonstrates how an `ActionTask` is invoked :

```ruby
class ActionTaskExample
  include ActionLogic::ActionTask

  validates_before :expected_attribute1 => { :type => :string },
                   :expected_attribute2 => { :type => :integer, :presence => true }
  validates_after  :example_attribute1 => { :type => :string, :presence => ->(example_attribute1) { !example_attribute1.empty? } }

  def call
    # adds `example_attribute1` to the shared `context` with the value "Example value"
    context.example_attribute1 = "New value from context attributes: #{context.expected_attribute1} #{context.expected_attribute2}"
  end
end

result = ActionTaskExample.execute(:expected_attribute1 => "example", :expected_attribute2 => 123)

result # => #<ActionLogic::ActionContext expected_attribute1="example", expected_attribute2=123, status=:success, example_attribute1="New value from context attributes: example 123">
```

The `ActionTaskExample` is invoked using the static method `execute` which takes an optional hash of attributes that is converted into an `ActionContext`. Assuming the before validations are satisfied, the `call` method is invoked. In the body of the `call` method the `ActionTask` can access the shared `ActionContext` instance via a `context` object. This shared `context` object allows for getting and setting attributes as needed. When the `call` method returns, the `context` is validated against any defined after validations, and the `context` is then returned to the caller.

The diagram below is a visual representation of how an `ActionTask` is evaluted when its `execute` method is invoked from a caller:

<img src="https://github.com/rewinfrey/action_logic/blob/master/resources/action_task_diagram.png" />

Although this example is for the `ActionTask` abstraction, `ActionUseCase` and `ActionCoordinator` follow the same pattern. The difference is that `ActionUseCase` is designed to organize multiple `ActionTasks`, and `ActionCoordinator` is designed to organize many `ActionUseCases`.

### ActionUseCase<a name="actionusecase"></a>

In many cases the business logic required by a Rails application requires multiple steps or tasks to complete. `ActionUseCase` represents a layer of abstraction that organizes multiple `ActionTasks` and executes each `ActionTask` in the order they are defined. A single, shared `context` is passed to each `ActionTask`. The following is a simple example:

```ruby
class ActionUseCaseExample
  include ActionLogic::ActionUseCase

  # The `call` method is invoked prior to invoking any of the ActionTasks defined by the `tasks` method.
  # The purpose of the `call` method allows us to prepare the shared `context` prior to invoking the ActionTasks.
  def call
    context # => #<ActionLogic::ActionContext status=:success>
    context.example_usecase1 = true
  end

  def tasks
    [ActionTaskExample1,
     ActionTaskExample2,
     ActionTaskExample3]
  end
end

class ActionTaskExample1
  include ActionLogic::ActionTask

  def call
    context # => #<ActionLogic::ActionContext status=:success, example_usecase1=true>
    context.example_task1 = true
  end
end

class ActionTaskExample2
  include ActionLogic::ActionTask

  def call
    context # => #<ActionLogic::ActionContext status=:success, example_usecase1=true, example_task1=true>
    context.example_task2 = true
  end
end

class ActionTaskExample3
  include ActionLogic::ActionTask

  def call
    context # => #<ActionLogic::ActionContext status=:success, example_usecase1=true, example_task1=true, example_task2=true>
    context.example_task3 = true
  end
end

# To invoke the ActionUseCaseExample, we call its execute method:
result = ActionUseCaseExample.execute

result # => #<ActionLogic::ActionContext status=:success, example_usecase1=true, example_task1=true, example_task2=true, example_task3=true>
```

By following the value of the shared `context` from the `ActionUseCaseExample` to each of the `ActionTask` classes, it is possible to see how the shared `context` is mutated to accomodate the various attributes and their values each execution context adds to the `context`. It also reveals the order in which the `ActionTasks` are evaluated, and indicates that the `call` method of the `ActionUseCaseExample` is invoked prior to any of the `ActionTasks` defined in the `tasks` method.

Rails applications that continue to grow in complexity and size will eventually require stringing together multiple `use cases` of related business logic. When this need arises we can utilize the `ActionCoordinator` abstraction.

### ActionCoordinator<a name="actioncoordinator"></a>

### ActionContext<a name="actioncontext"></a>

### Features<a name="features"</a>

`ActionLogic` provides a number of convenience functionality that supports simple to complex business logic work flows while maintaining a simple and easy to understand API:

* Validations (`context` is verified to have all necessary attributes, have `presence` and are of the correct type)
* Custom error handling defined as a callback
* Prematurely halt or fail a workflow

### Validations<a name="validations"></a>

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

ExampleActionTask.execute(params) # => #<ActionLogic::ActionContext attribute1=1, attribute2="another example string value", ids=[1, 2, 3, 4], status=:success, attribute3=true, attribute4="an example string value">
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
