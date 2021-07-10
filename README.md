# puppet-lint parameter documentation check

[![License](https://img.shields.io/github/license/voxpupuli/puppet-lint-trailing_comma-check.svg)](https://github.com/voxpupuli/puppet-lint-trailing_comma-check/blob/master/LICENSE)
[![Test](https://github.com/voxpupuli/puppet-lint-param-docs/actions/workflows/test.yml/badge.svg)](https://github.com/voxpupuli/puppet-lint-param-docs/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/voxpupuli/puppet-lint-param-docs/branch/master/graph/badge.svg?token=Mypkl78hvK)](https://codecov.io/gh/voxpupuli/puppet-lint-param-docs)
[![Release](https://github.com/voxpupuli/puppet-lint-param-docs/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-lint-param-docs/actions/workflows/release.yml)
[![RubyGem Version](https://img.shields.io/gem/v/puppet-lint-param-docs.svg)](https://rubygems.org/gems/puppet-lint-param-docs)
[![RubyGem Downloads](https://img.shields.io/gem/dt/puppet-lint-param-docs.svg)](https://rubygems.org/gems/puppet-lint-param-docs)
[![Donated by Dominic Cleal](https://img.shields.io/badge/donated%20by-Dominic%20Cleal-fb7047.svg)](#transfer-notice)

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

This gem is not only available on rubygems, but also as [GitHub Package](https://github.com/voxpupuli/puppet-lint-param-docs/packages/)
You can install it from GitHub like this:

```
$ gem install puppet-lint-param-docs --source "https://rubygems.pkg.github.com/voxpupuli"
```

Or in a Gemfile:

```
source "https://rubygems.pkg.github.com/voxpupuli" do
  gem "puppet-lint-param-docs", "1.7.4"
end
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

## Transfer Notice

This plugin was originally authored by [Dominic Cleal](https://github.com/domcleal).
The maintainer preferred that Puppet Community take ownership of the module for future improvement and maintenance.
Existing pull requests and issues were transferred over, please fork and continue to contribute here.

Previously: https://github.com/domcleal/puppet-lint-absolute_classname-check

## License

This gem is licensed under the MIT license.

## Release information

To make a new release, please do:
* update the version in the gemspec file
* Install gems with `bundle install --with release --path .vendor`
* generate the changelog with `bundle exec rake changelog`
* Check if the new version matches the closed issues/PRs in the changelog
* Create a PR with it
* After it got merged, push a tag. GitHub actions will do the actual release to rubygems and GitHub Packages
