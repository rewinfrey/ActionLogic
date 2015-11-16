# ActionLogic

[![Codeship Status for rewinfrey/action_logic](https://codeship.com/projects/7737cf40-6808-0133-84a7-460d97cd31f0/status?branch=master)](https://codeship.com/projects/114179)
[![Gem Version](https://badge.fury.io/rb/action_logic.svg)](https://badge.fury.io/rb/action_logic)
[![Code Climate](https://codeclimate.com/github/rewinfrey/action_logic/badges/gpa.svg)](https://codeclimate.com/github/rewinfrey/action_logic)
[![Coverage Status](https://coveralls.io/repos/rewinfrey/action_logic/badge.svg?branch=master&service=github)](https://coveralls.io/github/rewinfrey/action_logic?branch=master)

### Introduction

This is a business logic abstraction gem that provides structure to the organization and composition of business logic in a Ruby or Rails application. `ActionLogic` is inspired by gems like [ActiveInteraction](https://github.com/orgsync/active_interaction), [DecentExposure](https://github.com/hashrocket/decent_exposure), [Interactor](https://github.com/collectiveidea/interactor), [Light-Service](https://github.com/adomokos/light-service), [Mutations](https://github.com/cypriss/mutations), [Surrounded](https://github.com/saturnflyer/surrounded), [Trailblazer](https://github.com/apotonick/trailblazer) and [Wisper](https://github.com/krisleech/wisper).

Why another business logic abstraction gem? `ActionLogic` provides teams of various experience levels with a minimal yet powerful set of abstractions that promote easy to write and easy to understand code. By using `ActionLogic`, teams can more quickly and easily write business logic that honors the SOLID principles, is easy to test and easy to reason about, and provides a flexible foundation from which teams can model and define their application's business domains by focusing on reusable units of work that can be composed and validated with one another.

### Contents

* [Backstory](#backstory)
* [Overview](#overview)
* [`ActionContext`](#actioncontext)
* [`ActionTask`](#actiontask)
* [`ActionUseCase`](#actionusecase)
* [`ActionCoordinator`](#actioncoordinator)
* [Succeeding an `ActionContext`](#succeeding-an-actioncontext)
* [Failing an `ActionContext`](#failing-an-actioncontext)
* [Halting an `ActionContext`](#halting-an-actioncontext)
* [Custom `ActionContext` Status](#custom-actioncontext)
* [Error Handling](#error-handling)
* [Attribute Validations](#attribute-validations)
* [Type Validations](#type-validations)
* [Custom Type Validations](#custom-type-validations)
* [Presence Validations](#presence-validations)
* [Custom Presence Validations](#custom-presence-validations)
* [Before Validations](#before-validations)
* [After Validations](#after-validations)
* [Around Validations](#around-validations)

### Backstory

Consider a traditional e-commerce Rails application. Users can shop online and add items to their shopping cart until they are ready to check out.
The happy path scenario might go something like this: the user submits their order form, an orders controller action records the order in the database,
submits the order total to a payment processor, waits for a response from the payment processor, and upon a success response from the payment processor sends
an order confirmation email to the user, the order is sent internally to the warehouse for fulfillment which requires creating various records in the database,
and finally the server responds to the initial POST request with a rendered html page including a message indicating the order was successfully processed. In this
work flow there are at least 7 distinct steps or tasks that must be satisfied in order for the application's business logic to be considered correct according
to specifications.

Although this flow works well for most users, there are other users whose credit card information might be expired or users who might attempt to check out when
your application's payment processor service is down. Additional edge case scenarios start to pop up in error logs as exception emails fill up your inbox.
What happens when that user that is notorious for having 100 tabs open forgets to complete the checkout process and submits a two week old order form that
includes an item that your e-commerce store no longer stocks? What happens if an item is sold out? The edge cases and exception emails pile up, and as each one comes in
you add more and more logic to that controller action.

What once was a simple controller action designed with only the happy path of a successful checkout in mind has now become 100 lines long with 5 to 10 levels
of nested if statements. The voice of Uncle Bob starts ringing in your ears and you know there must be a better way. You think on it for awhile and consider not only
the technical challenges of refactoring this code, but you'd also like to make this code reusable and modular. You want this code to be easy to test and easy to maintain.
You want to honor the SOLID principles by writing classes that are singularly focused and easy to extend. You reason these new classes should only have to change if the
business logic they execute changes. You see that there are relationships between the entities and you see the possibility of abstractions that allow entities of similar types
to interact nicely with each other. You begin thinking about interfaces and the Liskov Substitution Principle, and eventually your mind turns towards domains and data modeling.
Where does it end you wonder?

But you remember your team. It's a team of people all wanting to do their best, and represent a variety of backgrounds and experiences. Each person has varying degress of familiarity
with different types of abstractions and approaches, and you wonder what abstractions might be as easy to work with for a new developer as they are for an experienced developer?
You consider DSL's you've used in the past and wonder what is that ideal balance between magic and straightforward OOP design?

As more and more questions pile up in the empty space of your preferred text editor, you receive another exception email for a new problem with the order flow. The questions about
how to refactor this code transform into asking questions about how can you edit the existing code to add the new fix? Add a new nested if statement? You do what you can given the
constraints you're faced with, and add another 5 lines and another nested if statement. You realize there is not enough time to make this refactor happen, and you've got to push the
fix out as soon as possible. Yet, as you merge your feature branch in master and deploy a hotfix, you think surely there must be a better way.

`ActionLogic` was born from many hours thinking about these questions and considering how it might be possible to achieve a generic set of abstractions to help guide
business logic that would promote the SOLID principles and be easy for new and experienced developers to understand and extend. It's not a perfect abstraction (as nothing is),
but *can* help simplify your application's business logic by encouraging you to consider the smallest units of work required for your business logic while offering features
like type and presence validation that help reduce or eliminate boiler plate, defensive code (nil checks anyone?). However, as with all general purpose libraries, your mileage
will vary.

### Overview

There are three levels of abstraction provided by `ActionLogic`:

* [`ActionTask` (a concrete unit of work)](#action_task)
* [`ActionUseCase` (organizes two or more `ActionTasks`)](#action_use_case)
* [`ActionCoordinator` (coordinates two or more `ActionUseCases`)](#action_coordinator)

Each level of abstraction operates with a shared, mutable data structure referred to as a `context` and is an instance of `ActionContext`. This shared `context` is threaded
through each `ActionTask`, `ActionUseCase` and / or `ActionCoordinator` until all work is completed. The resulting `context` is returned to the original caller
(typically in a Rails application this will be a controller action). In the problem described above we might have an `ActionUseCase` for organizing the checkout order flow,
and each of the distinct steps would be represented by a separate `ActionTask`. However, overtime it may make more sense to split apart the singular `ActionUseCase` for the order
flow into smaller `ActionUseCases` that are isolated by their domain (users, payment processor, inventory / warehouse, email, etc.). Considering that we limit our `ActionUseCases` to
single domains, then the `ActionCoordinator` abstraction would allow us to coordinate communication between the `ActionUseCases` and their `ActionTasks` to fulfill the necessary
work required when a user submits a checkout order form.

The diagram below illustrates how the `ActionTask`, `ActionUseCase` and `ActionCoordinator` abstractions work together, and the role of `ActionContext` as the primary, single input:

<img src="https://raw.githubusercontent.com/rewinfrey/action_logic/master/resources/overview_diagram.png" />

### ActionContext

The glue that binds the three layers of abstraction provided in `ActionLogic` is `ActionContext`. Anytime an `ActionTask`, `ActionUseCase` or `ActionCoordinator` is invoked
an instance of `ActionContext` is created and passed as an input parameter to the receiving execution context. Because each of the three abstractions works in the same way
with `ActionContext`, it is intended to be a relatively simple "learn once understand everywhere" abstraction.

Instances of `ActionContext` are always referred to within the body of `call` methods defined in any `ActionTask`, `ActionUseCase` or `ActionCoordinator` as `context`. An
instance of `ActionContext` is a thin wrapper around Ruby's standard library [`OpenStruct`](http://ruby-doc.org/stdlib-2.0.0/libdoc/ostruct/rdoc/OpenStruct.html). This allows
instances of `ActionContext` to be maximally flexible. Arbitrary attributes can be defined on a `context` and their values can be of any type.

In addition to allowing arbitrary attributes and values to be defined on a `context`, instances of `ActionContext` also conform to a set of simple rules:

* Every `context` instance is instantiated with a default `status` of `:success`
* A `context` responds to `success?` which returns true if the `status` is `:success`
* A `context` responds to `fail!` which sets the `status` to `:failure`
* A `context` responds to `fail?` which returns true if the `status` is `:failure`
* A `context` rseponds to `halt!` which sets the `status` to `:halted`
* A `context` responds to `halted?` which returns true if the `status` is `:halted`

Enough with the words, let's look at some code! The following shows an instance of `ActionContext` and its various abilities:

```ruby
context = ActionLogic::ActionContext.new

context # => #<ActionLogic::ActionContext status=:success>

# default status is `:success`:
context.status # => :success

# defining a new attribute called `name` with the value `"Example"`:
context.name = "Example"

# retrieving the value of the `name` attribute:
context.name # => "Example"

# you can set attributes to anything, including Procs:
context.lambda_example = -> { "here" }

context.lambda_example # => #<Proc:0x007f8d6b0a9ba0@-:11 (lambda)>

context.lambda_example.call # => "here"

# contexts can be failed:
context.fail!

context.status # => :failure

context.failure? # => true

# contexts can also be halted:
context.halt!

context.status # => :halted

context.halted? # => true
```

Now that we have seen what `ActionContext` can do, let's take a look at the lowest level of absraction in `ActionLogic` that consumes instances of `ActionContext`, the `ActionTask`
abstraction.

### ActionTask

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

### ActionUseCase

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

### ActionCoordinator

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

### Succeeding an `ActionContext`
By default, the value of the `status` attribute of instances of `ActionContext` is `:success`. Normally this is useful information for the caller of an `ActionTask`, `ActionUseCase` or `ActionCoordinator`
because it informs the caller that the various execution context(s) were successful. In other words, a `:success` status indicates that none of the execution contexts had a failure
or halted execution.

### Failing an `ActionContext`
Using `context.fail!` does two important things: it immediately stops the execution of any proceeding business logic (prevents any additional `ActionTasks` from executing)
and also sets the status of the `context` as `:failure`. This status is most applicable to the caller or an `ActionCoordinator` that might have a plan specifically for a `:failure`
status of a resulting `ActionUseCase`.

### Halting an `ActionContext`
Like, failing a context, Using `context.halt!` does two important things: it immediately halts the execution of any proceeding business logic (prevents any additional `ActionTasks`
from executing) and also sets the status of the `context` as `:halted`. The caller may use that information to define branching logic or an `ActionCoordinator` may use that
information as part of its `plan`.

### Custom `ActionContext` Status
It is worthwhile to point out that you should not feel limited to only using the three provided statuses of `:success`, `:failure` or `:halted`. It is easy to implement your
own system of statuses if you prefer. For example, consider a system that is used to defining various status codes or disposition codes to indicate the result of some business
logic. Instances of `ActionContext` can be leveraged to indicate these disposition codes by using the `status` attribute, or by defining custom attributes. You are encouraged
to expirement and play with the flexibility provided to you by `ActionContext` in determining what is optimal for your given code contexts and your team.

```ruby
class RailsControllerExample < ApplicationController
  def create
		case create_use_case.status
		when :disposition_1 then ActionUseCaseSuccess1.execute(create_use_case)
		when :disposition_2 then ActionUseCaseSuccess2.execute(create_use_case)
		when :disposition_9 then ActionUseCaseFailure.execute(create_use_case)
		else
		  ActionUseCaseDefault.execute(create_use_case)
		end
	end

	private

	def create_use_case
	  @create_use_case ||= ActionUseCaseExample.execute(params)
	end
end
```

Although this contrived example would be ideal for an `ActionCoordinator` (because the result of `ActionUseCaseExample` drives the execution of the next `ActionUseCase`), this
example serves to show that `status` can be used with custom disposition codes to drive branching behavior.

### Error Handling
During execution of an `ActionTask`, `ActionUseCase` or `ActionCoordinator` you may wish to define custom behavior for handling errors. Within any of these classes
you can define an `error` method that receives as its input the error exception. Invoking an `error` method does not make any assumptions about the `status` of the
underlying `context`. Execution of the `ActionTask`, `ActionUseCase` or `ActionCoordinator` also stops after the `error` method returns, and execution of the work
flow continues as normal unless the `context` is failed or halted.

The following example is a simple illustration of how an `error` method is invoked for an `ActionTask`:

```ruby
class ActionTaskExample
  include ActionLogic::ActionTask

  def call
    context.before_raise = true
    raise "Something broke"
    context.after_raise = true
  end

  def error(e)
    context.e = "the error is passed in as an input parameter: #{e.class}"
  end
end

result = ActionTaskExample.execute

# the status of the context is not mutated
result.status # => :success

result.e # => "the error is passed in as an input parameter: RuntimeError"

result.before_raise # => true

result.after_raise # => nil
```

It is important to note that defining an `error` method is **not** required. If at any point in the execution of an `ActionTask`, `ActionUseCase` or `ActionCoordinator`
an uncaught exception is thrown **and** an `error` method is **not** defined, the exception is raised to the caller.

### Attribute Validations
The most simple and basic type of validation offered by `ActionLogic` is attribute validation. To require that an attribute be defined on an instance of `ActionContext`, you
need only specify the name of the attribute and an empty hash with one of the three validation types (before, after or around):

```ruby
class ActionTaskExample
  include ActionLogic::ActionTask

  validates_before :required_attribute1 => {}

  def call
  end
end

result = ActionTaskExample.execute(:required_attribute1 => true)

result.status # => :success

result.required_attribute1 # => true
```

However, in the above example, if we were to invoke the `ActionTaskExample` without the `required_attribute1` parameter, the before validation would fail and raise
an `ActionLogic::MissingAttributeError` and also detail which attribute is missing:

```ruby
class ActionTaskExample
  include ActionLogic::ActionTask

  validates_before :required_attribute1 => {}

  def call
  end
end

ActionTaskExample.execute # ~> [:required_attribute1] (ActionLogic::MissingAttributeError)
```

Attribute validations are defined in the same way regardless of the timing of the validation ([before](#before_validations), [after](#after_validations) or
[around](#around_validations)). Please refer to the relevant sections for examples of their usage.

### Type Validations
In addition to attribute validations, `ActionLogic` also allows you to validate against the type of the value of the attribute you expect to be defined in an instance
of `ActionContext`. To understand the default types `ActionLogic` validates against, please see the following example:

```ruby
class ActionTaskExample
  include ActionLogic::ActionTask

  validates_after :integer_test => { :type => :integer },
                  :float_test   => { :type => :float },
                  :string_test  => { :type => :string },
                  :bool_test    => { :type => :boolean },
                  :hash_test    => { :type => :hash },
                  :array_test   => { :type => :array },
                  :symbol_test  => { :type => :symbol },
                  :nil_test     => { :type => :nil }

  def call
    context.integer_test = 123
    context.float_test   = 1.0
    context.string_test  = "test"
    context.bool_test    = true
    context.hash_test    = {}
    context.array_test   = []
    context.symbol_test  = :symbol
    context.nil_test     = nil
  end
end

result = ActionTaskExample.execute

result # => #<ActionLogic::ActionContext status=:success,
            #                            integer_test=123,
            #                            float_test=1.0,
            #                            string_test="test",
            #                            bool_test=true,
            #                            hash_test={},
            #                            array_test=[],
            #                            symbol_test=:symbol,
            #                            nil_test=nil>
```

It's important to point out that Ruby's `true` and `false` are not `Boolean` but `TrueClass` and `FalseClass` respectively. Additionally, `nil`'s type is `NilClass` in Ruby.
To simplify the way these validations work for `true` or `false`, type validations expect the symbol `:boolean` as the `:type`. `nil` is validated simply with the `:nil` `:type`.

As we saw with attribute validations, if an attribute's value does not conform to the type expected, `ActionLogic` will raise an `ActionLogic::AttributeTypeError`
with a detailed description about which attribute's value failed the validation:

```ruby
class ActionTaskExample
  include ActionLogic::ActionTask

  validates_after :integer_test => { :type => :integer }

  def call
    context.integer_test = 1.0
  end
end

ActionTaskExample.execute # ~> ["Attribute: integer_test with value: 1.0 was expected to be of type integer but is float"] (ActionLogic::AttributeTypeError)
```

In addition to the above default types it is possible to also validate against user defined types.

### Custom Type Validations
If you would like to validate the type of attributes on a given `context` with your applications custom classes, `ActionLogic` is happy to provide that functionality.

Let's consider the following example:

```ruby
class ExampleClass
end

class ActionTaskExample
  include ActionLogic::ActionTask

  validates_after :example_attribute => { :type => :exampleclass }

  def call
    context.example_attribute = ExampleClass.new
  end
end

result = ActionTaskExample.execute

result # => #<ActionLogic::ActionContext status=:success, example_attribute=#<ExampleClass:0x007f95d1922bd8>>
```

In the above example, a custom class `ExampleClass` is defined. In order to type validate against this class, the required format for the name of the class is simply
the lowercase version of the class as a symbol. `ExampleClass` becomes `:exampleclass`, `UserAttributes` becomes `:userattributes`, and so on.

If a custom type validation is fails, `ActionLogic` provides the same `ActionLogic::AttributeTypeError` with a detailed explanation about what attribute is in violation
of the type validation:

```ruby
class ExampleClass
end

class OtherClass
end

class ActionTaskExample
  include ActionLogic::ActionTask

  validates_after :example_attribute => { :type => :exampleclass }

  def call
    context.example_attribute = OtherClass.new
  end
end

ActionTaskExample.execute # ~> ["Attribute: example_attribute with value: #<OtherClass:0x007fb5ca04edb8> was expected to be of type exampleclass but is otherclass"] (ActionLogic::AttributeTypeError)
```

Attribute and type validations are very helpful, but in some situations this is not enough. Additionally, `ActionLogic` provides presence validation so you can also verify that
a given attribute on a context not only has the correct type, but also has a value that is considered `present`.

### Presence Validations

### Custom Presence Validations

### Before Validations

### After Validations

### Around Validations

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

ExampleActionTask.execute(params) # => #<ActionLogic::ActionContext attribute1=1, attribute2="another example string value", ids=[1, 2, 3, 4], status=:success, attribute3=true, attribute4="an example string value">
```
