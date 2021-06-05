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

### parameter\_documentation

**--fix support: No**

This check will raise a warning for any class or defined type parameters that
don't have a description.

```
WARNING: missing documentation for class parameter foo::bar
WARNING: missing documentation for defined type parameter foo::baz
```

It will also raise warnings for parameters documented more than once.

```
WARNING Duplicate class parameter documentation for foo::bar on line 5
WARNING Duplicate class parameter documentation for foo::bar on line 6
```

A warning will also be raised if you document a parameter that doesn't exist in the class or defined type.

```
WARNING No matching class parameter for documentation of foo::bar
```

### Documentation styles

By default, the check will allow all known documentation styles.
You can, however, specify a list of accepted formats:

```ruby
# Limit to a single style
PuppetLint.configuration.docs_allowed_styles = 'strings'
# Limit to multiple styles
PuppetLint.configuration.docs_allowed_styles = ['strings', 'doc']
```

It will raise a warning if the documentation style does not match.

```
WARNING: invalid documentation style for class parameter foo::bar (doc) on line 4
```

The check will accept any of the following styles:

#### Puppet Strings: `strings`

Used by [Puppet Strings](https://github.com/puppetlabs/puppetlabs-strings).

```puppet
# @summary Example class
#
# @param foo example
define example($foo) { }
```

#### Puppet Doc style: `doc`

Used by the [puppet-doc](https://puppet.com/docs/puppet/6.18/man/doc.html)
command, deprecated in favour of Puppet Strings.

```puppet
# Example class
#
# === Parameters:
#
# [*foo*] example
#
class example($foo) { }
```

#### Kafo rdoc style: `kafo`

Used in [kafo](https://github.com/theforeman/kafo#documentation) following an
rdoc style.

```puppet
# Example class
#
# === Parameters:
#
# $foo:: example
#
class example($foo) { }
```

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

This would disable the parameter\_documentation check by default, but then
defines a new rake task (which runs after `lint`) specifically for the files
given in `config.pattern`.

The [Puppet Strings](#puppet_strings) `@api private` directive can also be used
to disable checks on that file.
