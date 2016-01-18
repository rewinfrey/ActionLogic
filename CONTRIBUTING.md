Contributing to ActionLogic
===========================

Thank you for your interest in contributing! You're encouraged to submit [pull requests](https://github.com/rewinfrey/actionlogic/pulls),
[propose features and discuss issues](https://github.com/rewinfrey/actionlogic/issues). When in doubt, ask a question in the form of an
[issue](https://github.com/rewinfrey/actionlogic/issues).

#### Fork the Project

Fork the [project on Github](https://github.com/rewinfrey/actionlogic) and check out your copy.

```
git clone https://github.com/contributor/actionlogic.git
cd actionlogic
git remote add upstream https://github.com/rewinfrey/actionlogic.git
```

#### Create a Feature Branch

Make sure your fork is up-to-date and create a feature branch for your feature or bug fix.

```
git checkout master
git pull upstream master
git checkout -b my-feature-branch
```

#### Bundle Install and Test

Ensure that you can build the project and run tests.

```
bundle
bundle exec rspec spec
```

#### Write Tests

Try to write a test that reproduces the problem you're trying to fix or describes a feature that you want to build. Add to [specs](https://github.com/rewinfrey/ActionLogic/tree/master/spec).

Pull requests with specs that highlight or reproduce a problem, even without a fix, are very much appreciated and welcomed!

#### Write Code

Implement your feature or bug fix.

Make sure that `bundle exec rspec spec` completes without errors.

#### Write Documentation

Document any external behavior in the [README](README.md).

#### Commit Changes

Make sure git knows your name and email address:

```
git config --global user.name "Your Name"
git config --global user.email "contributor@example.com"
```

Writing good commit logs is important. A commit log should describe what changed and why.

```
git add ...
git commit
```

#### Push

```
git push origin my-feature-branch
```

#### Make a Pull Request

Go to https://github.com/contributor/ActionLogic and select your feature branch. Click the 'Pull Request' button and fill out the form. Pull requests are usually reviewed within a few days.

#### Check on Your Pull Request

Go back to your pull request after a few minutes and see whether the Travis-CI builds are all passing. Everything should look green, otherwise fix issues and add your fix as new commits (no need
to rebase or squash commits).

#### Thank You

Any and all contributions are very appreciated!
