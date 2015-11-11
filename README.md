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

* [`ActionTask` (the core unit of work)](#action_task)
* [`ActionUseCase` (contains one or many `ActionTasks`)](#action_use_case)
* [`ActionCoordinator` (contains two or more `ActionUseCases`)](#action_coordinator)

Each level of abstraction operates with a shared, mutable data structure referred to as a `context` and is an instance of `ActionContext`. This shared `context` is threaded through each `ActionTask`, `ActionUseCase` and / or `ActionCoordinator` until all work is completed. The resulting `context` is returned to the original caller (typically in a Rails application this will be a controller action).

### ActionTask<a name="action_task"></a>

At the core of every `ActionLogic` work flow is an `ActionTask`. These classes are the lowest level of abstraction in `ActionLogic` and are where concrete work is performed. All `ActionTasks` conform to the same structure and incorporate all features of `ActionLogic` including validations and error handling.

To implement an `ActionTask` class you must define a `call` method. You can also specify any before, after or around validations or an error handler. The following code example demonstrates an `ActionTask` class that includes before and after validations, and also demonstrates how an `ActionTask` is invoked :

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

# ActionTasks are invoked by calling an `execute` static method directly on the class with an optional hash of key value pairs:
result = ActionTaskExample.execute(:expected_attribute1 => "example", :expected_attribute2 => 123)

# The result object is the shared context object (an instance of ActionContext):
result # => #<ActionLogic::ActionContext expected_attribute1="example", expected_attribute2=123, status=:success, example_attribute1="New value from context attributes: example 123">
```

The `ActionTaskExample` is invoked using the static method `execute` which takes an optional hash of attributes that is converted into an `ActionContext`. Assuming the before validations are satisfied, the `call` method is invoked. In the body of the `call` method the `ActionTask` can access the shared `ActionContext` instance via a `context` object. This shared `context` object allows for getting and setting attributes as needed. When the `call` method returns, the `context` is validated against any defined after validations, and the `context` is then returned to the caller.

The diagram below is a visual representation of how an `ActionTask` is evaluted when its `execute` method is invoked from a caller:

<img src="https://raw.githubusercontent.com/rewinfrey/action_logic/master/resources/action_task_diagram.png" />

Although this example is for the `ActionTask` abstraction, `ActionUseCase` and `ActionCoordinator` follow the same pattern. The difference is that `ActionUseCase` is designed to organize multiple `ActionTasks`, and `ActionCoordinator` is designed to organize many `ActionUseCases`.

### ActionUseCase<a name="action_use_case"></a>

As business logic grows in complexity the number of steps or tasks required to fulfill that business logic tends to increase. Managing this complexity is a problem every team must face. Abstractions can help teams of varying experience levels work together and promote code that remains modular and simple to understand and extend. `ActionUseCase` represents a layer of abstraction that organizes multiple `ActionTasks` and executes each `ActionTask` in the order they are defined. Each task receives the same shared `context` so tasks can be composed together.

To implement an `ActionUseCase` class you must define a `call` method and a `tasks` method. You also can specify any before, after or around validations or an error handler. The following is an example showcasing how an `ActionUseCase` class organizes the execution of multiple `ActionTasks` and defines before and after validations on the shared `context`:

```ruby
class ActionUseCaseExample
  include ActionLogic::ActionUseCase

  validates_before :expected_attribute1 => { :type => :string },
                   :expected_attribute2 => { :type => :integer, :presence => true }
  validates_after  :example_task1    => { :type => :boolean, :presence => true },
                   :example_task2    => { :type => :boolean, :presence => true },
                   :example_task3    => { :type => :boolean, :presence => true },
                   :example_usecase1 => { :type => :boolean, :presence => true }

  # The `call` method is invoked prior to invoking any of the ActionTasks defined by the `tasks` method.
  # The purpose of the `call` method allows us to prepare the shared `context` prior to invoking the ActionTasks.
  def call
    context # => #<ActionLogic::ActionContext expected_attribute1="example", expected_attribute2=123, status=:success>
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
  validates_after :example_task1 => { :type => :boolean, :presence => true }

  def call
    context # => #<ActionLogic::ActionContext expected_attribute1="example", expected_attribute2=123, status=:success, example_usecase1=true>
    context.example_task1 = true
  end
end

class ActionTaskExample2
  include ActionLogic::ActionTask
  validates_after :example_task2 => { :type => :boolean, :presence => true }

  def call
    context # => #<ActionLogic::ActionContext expected_attribute1="example", expected_attribute2=123, status=:success, example_usecase1=true, example_task1=true>
    context.example_task2 = true
  end
end

class ActionTaskExample3
  include ActionLogic::ActionTask
  validates_after :example_task3 => { :type => :boolean, :presence => true }

  def call
    context # => #<ActionLogic::ActionContext expected_attribute1="example", expected_attribute2=123, status=:success, example_usecase1=true, example_task1=true, example_task2=true>
    context.example_task3 = true
  end
end

# To invoke the ActionUseCaseExample, we call its execute method with the required attributes:
result = ActionUseCaseExample.execute(:expected_attribute1 => "example", :expected_attribute2 => 123)

result # => #<ActionLogic::ActionContext expected_attribute1="example", expected_attribute2=123, status=:success, example_usecase1=true, example_task1=true, example_task2=true, example_task3=true>
```

By following the value of the shared `context` from the `ActionUseCaseExample` to each of the `ActionTask` classes, it is possible to see how the shared `context` is mutated to accomodate the various attributes and their values each execution context adds to the `context`. It also reveals the order in which the `ActionTasks` are evaluated, and indicates that the `call` method of the `ActionUseCaseExample` is invoked prior to any of the `ActionTasks` defined in the `tasks` method.

To help visualize the flow of execution when an `ActionUseCase` is invoked, this diagram aims to illustrate the relationship between `ActionUseCase` and `ActionTasks` and the order in which operations are performed:

<img src="https://raw.githubusercontent.com/rewinfrey/action_logic/master/resources/action_use_case_diagram.png" />

### ActionCoordinator<a name="action_coordinator"></a>

Sometimes the behavior we wish our Ruby or Rails application to provide requires us to coordinate work between various domains of our application's business logic. The `ActionCoordinator` abstraction is intended to help coordinate multiple `ActionUseCases` by allowing you to define a plan of which `ActionUseCases` to invoke depending on the outcome of each `ActionUseCase` execution. The `ActionCoordinator` abstraction is the highest level of abstraction in `ActionLogic`.

To implement an `ActionCoordinator` class, you must define a `call` method in addition to a `plan` method. The purpose of the `plan` method is to define a state transition map that links together the various `ActionUseCase` classes the `ActionCoordinator` is organizing, as well as allowing you to define error or halt scenarios based on the result of each `ActionUseCase`. The following code example demonstrates a simple `ActionCoordinator`:

```ruby
class ActionCoordinatorExample
  include ActionLogic::ActionCoordinator

  def call
    context.required_attribute1 = "required attribute 1"
    context.required_attribute2 = "required attribute 2"
  end

  def plan
    {
      ActionUseCaseExample1 => { :success => ActionUseCaseExample2,
                                 :failure => ActionUseCaseFailureExample },
      ActionUseCaseExample2 => { :success => nil,
                                 :failure => ActionUseCaseFailureExample },
      ActionUseCaseFailureExample => { :success => nil }
    }
  end
end

class ActionUseCaseExample1
  include ActionLogic::ActionUseCase

  validates_before :required_attribute1 => { :type => :string }

  def call
    context # => #<ActionLogic::ActionContext status=:success, required_attribute1="required attribute 1", required_attribute2="required attribute 2">
    context.example_usecase1 = true
  end

  # Normally `tasks` would define multiple tasks, but in this example, I've used one ActionTask to keep the overall code example smaller
  def tasks
    [ActionTaskExample1]
  end
end

class ActionUseCaseExample2
  include ActionLogic::ActionUseCase

  validates_before :required_attribute2 => { :type => :string }

  def call
    context # => #<ActionLogic::ActionContext status=:success, required_attribute1="required attribute 1", required_attribute2="required attribute 2", example_usecase1=true, example_task1=true>
    context.example_usecase2 = true
  end

  # Normally `tasks` would define multiple tasks, but in this example, I've used one ActionTask to keep the overall code example smaller
  def tasks
    [ActionTaskExample2]
  end
end

# In this example, we are not calling ActionUseCaseFailureExample, but is used to illustrate the purpose of the `plan` of our ActionCoordinator
# in the event of a failure in one of the consumed `ActionUseCases`
class ActionUseCaseFailureExample
  include ActionLogic::ActionUseCase

  def call
  end

  def tasks
    [ActionTaskLogFailure,
     ActionTaskEmailFailure]
  end
end

class ActionTaskExample1
  include ActionLogic::ActionTask
  validates_after :example_task1 => { :type => :boolean, :presence => true }

  def call
    context # => #<ActionLogic::ActionContext status=:success, required_attribute1="required attribute 1", required_attribute2="required attribute 2", example_usecase1=true>
    context.example_task1 = true
  end
end

class ActionTaskExample2
  include ActionLogic::ActionTask
  validates_after :example_task2 => { :type => :boolean, :presence => true }

  def call
    context # => #<ActionLogic::ActionContext status=:success, required_attribute1="required attribute 1", required_attribute2="required attribute 2", example_usecase1=true, example_task1=true, example_usecase2=true>
    context.example_task2 = true
  end
end

result = ActionCoordinatorExample.execute

result # => #<ActionLogic::ActionContext status=:success, required_attribute1="required attribute 1", required_attribute2="required attribute 2", example_usecase1=true, example_task1=true, example_usecase2=true, example_task2=true>
```

<img src="https://raw.githubusercontent.com/rewinfrey/action_logic/master/resources/action_coordinator_diagram.png" />

### ActionContext<a name="action_context"></a>

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
