# puppet-lint parameter documentation check

Adds a new puppet-lint check to verify all class and defined type parameters
have been documented.

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

This check will raise a warning for any class or defined type parameters that
don't have an RDoc description.

```
WARNING: missing documentation for class parameter foo::bar
WARNING: missing documentation for defined type parameter foo::baz
```

### Documentation styles

The check will accept any of the following styles:

#### Puppet Strings

Used by [Puppet Strings](https://github.com/puppetlabs/puppetlabs-strings).

    # Example class
    #
    # @param foo example
    define example($foo) { }

#### Puppet Doc style

Used by the [puppet-doc](https://docs.puppetlabs.com/puppet/latest/reference/man/doc.html)
command, generally deprecated in favour of Puppet Strings.

    # Example class
    #
    # === Parameters:
    #
    # [*foo*] example
    #
    class example($foo) { }

#### Kafo rdoc style

Used in [kafo](https://github.com/theforeman/kafo#documentation) following an
rdoc style.

    # Example class
    #
    # === Parameters:
    #
    # $foo:: example
    #
    class example($foo) { }

### Selective rake task

The usual puppet-lint rake task checks all manifests, which isn't always
desirable with this particular check.  If your module contains many classes,
some of which you don't wish to document, then you can exclude them using
[control comments](http://puppet-lint.com/controlcomments/) or by using this
helper to customise the lint rake task:

    require 'puppet-lint-param-docs/tasks'
    PuppetLintParamDocs.define_selective do |config|
      config.pattern = ['manifests/init.pp', 'manifests/other/**/*.pp']
    end

This would disable the parameter_documentation check by default, but then
defines a new rake task (which runs after `lint`) specifically for the files
given in `config.pattern`.

The [Puppet Strings](#puppet_strings) `@api private` directive can also be used
to disable checks on that file.
