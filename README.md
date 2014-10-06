# puppet-lint parameter documentation check

Adds a new puppet-lint check to verify all class parameters have been
documented.

Particularly useful with [kafo](https://github.com/theforeman/kafo), as its
default behaviour is to throw an error when a parameter is undocumented.

## Installation

To use this plugin, add the following line to the Gemfile in your Puppet code
base and run `bundle install`.

```ruby
gem 'puppet-lint-param-docs'
```

## Usage

This plugin provides a new check to `puppet-lint`.

### parameter_documentation

**--fix support: No**

This check will raise a warning for any class parameters that don't have an
RDoc description.

```
WARNING: missing documentation for class parameter foo::bar
```
