require 'spec_helper'

describe 'parameter_documentation' do
  let(:class_msg) { 'missing documentation for class parameter example::%s' }
  let(:define_msg) { 'missing documentation for defined type parameter example::%s' }
  let(:class_style_msg) { 'invalid documentation style for class parameter example::%s (%s)' }
  let(:define_style_msg) { 'invalid documentation style for defined type parameter example::%s (%s)' }

  context 'class missing any documentation' do
    let(:code) { 'class example($foo) { }' }

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(class_msg % :foo).on_line(1).in_column(15)
    end
  end

  context 'define missing any documentation' do
    let(:code) { 'define example($foo) { }' }

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(define_msg % :foo).on_line(1).in_column(16)
    end
  end

  context 'class with param defaults' do
    let(:code) { 'class example($foo = $example::params::foo) { }' }

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(class_msg % :foo).on_line(1).in_column(15)
    end
  end

  context 'define with param defaults' do
    let(:code) { 'define example($foo = $example::params::foo) { }' }

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(define_msg % :foo).on_line(1).in_column(16)
    end
  end

  context 'define with param defaults using a function' do
    let(:code) { 'define example($foo = min(8, $facts["processors"]["count"])) { }' }

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(define_msg % :foo).on_line(1).in_column(16)
    end
  end

  context 'class with many param defaults' do
    let(:code) do
      <<~EOS
        class foreman (
          $foreman_url            = $foreman::params::foreman_url,
          $unattended             = $foreman::params::unattended,
          $authentication         = $foreman::params::authentication,
          $passenger              = $foreman::params::passenger,
        ) {}
      EOS
    end

    it 'detects four problems' do
      expect(problems).to have(4).problems
    end
  end

  context 'define with many param defaults' do
    let(:code) do
      <<~EOS
        define foreman (
          $foreman_url            = $foreman::params::foreman_url,
          $unattended             = $foreman::params::unattended,
          $authentication         = $foreman::params::authentication,
          $passenger              = $foreman::params::passenger,
        ) {}
      EOS
    end

    it 'detects four problems' do
      expect(problems).to have(4).problems
    end
  end

  context 'class missing documentation ($bar::) for a parameter' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # Example class
      #
      # === Parameters:
      #
      # $bar:: example
      #
      class example($foo, $bar) { }
      EOS
    end

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(class_msg % :foo).on_line(7).in_column(15)
    end
  end

  context 'define missing documentation ($bar::) for a parameter' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # Example define
      #
      # === Parameters:
      #
      # $bar:: example
      #
      define example($foo, $bar) { }
      EOS
    end

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(define_msg % :foo).on_line(7).in_column(16)
    end
  end

  context 'class missing documentation (@param bar) for a parameter' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # Example class
      #
      # @param bar example
      class example($foo, $bar) { }
      EOS
    end

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(class_msg % :foo).on_line(4).in_column(15)
    end
  end

  context 'private class missing documentation (@param bar) for a parameter' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # Example class
      #
      # @api private
      #
      # @param bar example
      class example($foo, $bar) { }
      EOS
    end

    it 'detects no single problems' do
      expect(problems).to have(0).problems
    end

    it 'does not create a warning' do
      expect(problems).not_to contain_info(class_msg % :foo)
    end
  end

  context 'define missing documentation (@param bar) for a parameter' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # Example class
      #
      # @param bar example
      define example($foo, $bar) { }
      EOS
    end

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(define_msg % :foo).on_line(4).in_column(16)
    end
  end

  context 'class missing documentation ([*bar*]) for a parameter' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # Example class
      #
      # === Parameters:
      #
      # [*bar*] example
      #
      class example($foo, $bar) { }
      EOS
    end

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(class_msg % :foo).on_line(7).in_column(15)
    end
  end

  context 'define missing documentation ([*bar*]) for a parameter' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # Example define
      #
      # === Parameters:
      #
      # [*bar*] example
      #
      define example($foo, $bar) { }
      EOS
    end

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(define_msg % :foo).on_line(7).in_column(16)
    end
  end

  context 'class missing documentation ($bar::) for a second parameter' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # Example class
      #
      # === Parameters:
      #
      # $bar:: example
      #
      class example($foo, $bar, $baz) { }
      EOS
    end

    it 'detects two problem' do
      expect(problems).to have(2).problems
    end

    it 'creates two warnings' do
      expect(problems).to contain_warning(class_msg % :foo).on_line(7).in_column(15)
      expect(problems).to contain_warning(class_msg % :baz).on_line(7).in_column(27)
    end
  end

  context 'define missing documentation ($bar::) for a second parameter' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # Example define
      #
      # === Parameters:
      #
      # $bar:: example
      #
      define example($foo, $bar, $baz) { }
      EOS
    end

    it 'detects two problem' do
      expect(problems).to have(2).problems
    end

    it 'creates two warnings' do
      expect(problems).to contain_warning(define_msg % :foo).on_line(7).in_column(16)
      expect(problems).to contain_warning(define_msg % :baz).on_line(7).in_column(28)
    end
  end

  context 'class missing documentation ([*bar*]) for a second parameter' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # Example class
      #
      # === Parameters:
      #
      # [*bar*] example
      #
      class example($foo, $bar, $baz) { }
      EOS
    end

    it 'detects two problem' do
      expect(problems).to have(2).problems
    end

    it 'creates two warnings' do
      expect(problems).to contain_warning(class_msg % :foo).on_line(7).in_column(15)
      expect(problems).to contain_warning(class_msg % :baz).on_line(7).in_column(27)
    end
  end

  context 'define missing documentation ([*bar*]) for a second parameter' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # Example define
      #
      # === Parameters:
      #
      # [*bar*] example
      #
      define example($foo, $bar, $baz) { }
      EOS
    end

    it 'detects two problem' do
      expect(problems).to have(2).problems
    end

    it 'creates two warnings' do
      expect(problems).to contain_warning(define_msg % :foo).on_line(7).in_column(16)
      expect(problems).to contain_warning(define_msg % :baz).on_line(7).in_column(28)
    end
  end

  context 'class with all parameters documented ($foo::)' do
    let(:code) do
      <<-EOS
      # Example class
      #
      # === Parameters:
      #
      # $foo:: example
      #
      class example($foo) { }
      EOS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'check style' do
    let(:code) do
      <<-EOS
      # Example mixed style class
      #
      # Parameters:
      #
      # $foo:: example
      #
      # [*bar*] example
      #
      # @param foobar example
      #
      class example($foo, $bar, $foobar) { }
      EOS
    end

    context 'detect all styles' do
      before do
        PuppetLint.configuration.docs_allowed_styles = ['noexist']
      end

      after do
        PuppetLint.configuration.docs_allowed_styles = false
      end

      it 'detects three problems' do
        expect(problems).to have(3).problems
      end

      it 'creates three problems' do
        expect(problems).to contain_warning(format(class_style_msg, :foo, 'kafo')).on_line(11).in_column(21)
        expect(problems).to contain_warning(format(class_style_msg, :bar, 'doc')).on_line(11).in_column(27)
        expect(problems).to contain_warning(format(class_style_msg, :foobar, 'strings')).on_line(11).in_column(33)
      end
    end

    context 'use configured style' do
      before do
        PuppetLint.configuration.docs_allowed_styles = 'strings'
      end

      after do
        PuppetLint.configuration.docs_allowed_styles = nil
      end

      it 'detects two problems' do
        expect(problems).to have(2).problems
      end

      it 'creates three problems' do
        expect(problems).to contain_warning(format(class_style_msg, :foo, 'kafo')).on_line(11).in_column(21)
        expect(problems).to contain_warning(format(class_style_msg, :bar, 'doc')).on_line(11).in_column(27)
      end
    end
  end

  context 'define with all parameters documented ($foo::)' do
    let(:code) do
      <<-EOS
      # Example define
      #
      # === Parameters:
      #
      # $foo:: example
      #
      define example($foo) { }
      EOS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with all parameters documented ([*foo*])' do
    let(:code) do
      <<-EOS
      # Example class
      #
      # === Parameters:
      #
      # [*foo*] example
      #
      class example($foo) { }
      EOS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'define with all parameters documented ([*foo*])' do
    let(:code) do
      <<-EOS
      # Example define
      #
      # === Parameters:
      #
      # [*foo*] example
      #
      define example($foo) { }
      EOS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with all parameters documented (@param)' do
    let(:code) do
      <<-EOS
      # Example class
      #
      # === Parameters:
      #
      # @param foo example
      # @param [Integer] bar example
      # @param baz
      #   example
      # @param [Integer] qux
      #   example
      #
      class example($foo, $bar, $baz, $qux) { }
      EOS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'define with all parameters documented (@param)' do
    let(:code) do
      <<-EOS
      # Example define
      #
      # === Parameters:
      #
      # @param foo example
      # @param [Integer] bar example
      # @param baz
      #   example
      # @param [Integer] qux
      #   example
      #
      define example($foo, $bar, $baz, $qux) { }
      EOS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'define with all parameters documented with defaults (@param)' do
    let(:code) do
      <<-EOS
      # Example define
      #
      # @param foo example
      #
      define example($foo = $facts['networking']['fqdn']) { }
      EOS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'define with all parameters documented with defaults using functions (@param)' do
    let(:code) do
      <<-EOS
      # Example define
      #
      # @param foo example
      # @param multiple test nested function calls
      #
      define example(
        $foo = min(8, $facts['processors']['count']),
        $multiple = min(8, max(2, $facts['processors']['count'])),
      ) { }
      EOS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class without parameters' do
    let(:code) { 'class example { }' }

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'define without parameters' do
    let(:code) { 'define example { }' }

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class without parameters and a function call' do
    let(:code) { 'class example { a($foo::bar) }' }

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'define without parameters and a function call' do
    let(:code) { 'define example { a($foo::bar) }' }

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with hard tab indentation and rdoc parsing ($bar::)' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # Example class
      #
      # === Parameters:
      #
      # $foo::	example
      #
      class example($foo) { }
      EOS
    end

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning' do
      expect(problems).to contain_warning(class_msg % :foo).on_line(7).in_column(15)
    end
  end

  describe 'Duplicated documentation' do
    let(:class_msg) { 'Duplicate class parameter documentation for example::%s' }
    let(:define_msg) { 'Duplicate defined type parameter documentation for example::%s' }

    context 'class with parameters documented twice (@param)' do
      let(:code) do
        <<-EOS.gsub(/^\s+/, '')
      # @summary Example class
      #
      # @param bar
      #   example
      # @param foo example
      # @param bar Duplicate/conflicting docs
      #
      class example($foo, $bar) { }
        EOS
      end

      it 'detects two problems' do
        expect(problems).to have(2).problem
      end

      it 'creates a warning on line 3' do
        expect(problems).to contain_warning(class_msg % :bar).on_line(3).in_column(10)
      end

      it 'creates a warning on line 6' do
        expect(problems).to contain_warning(class_msg % :bar).on_line(6).in_column(10)
      end
    end

    context 'define with parameters documented twice (@param)' do
      let(:code) do
        <<-EOS.gsub(/^\s+/, '')
      # @summary Example define
      #
      # @param bar
      #   example
      # @param foo example
      # @param bar Duplicate/conflicting docs
      #
      define example($foo, $bar) { }
        EOS
      end

      it 'detects two problems' do
        expect(problems).to have(2).problem
      end

      it 'creates a warning on line 3' do
        expect(problems).to contain_warning(define_msg % :bar).on_line(3).in_column(10)
      end

      it 'creates a warning on line 6' do
        expect(problems).to contain_warning(define_msg % :bar).on_line(6).in_column(10)
      end
    end

    context 'class with parameters documented 3 times (@param)' do
      let(:code) do
        <<-EOS.gsub(/^\s+/, '')
      # @summary Example class
      #
      # @param bar
      #   example
      # @param foo example
      # @param bar Duplicate/conflicting docs
      #
      # @param bar
      #   example
      #
      class example($foo, $bar) { }
        EOS
      end

      it 'detects three problems' do
        expect(problems).to have(3).problem
      end

      it 'creates a warning on line 3' do
        expect(problems).to contain_warning(class_msg % :bar).on_line(3).in_column(10)
      end

      it 'creates a warning on line 6' do
        expect(problems).to contain_warning(class_msg % :bar).on_line(6).in_column(10)
      end

      it 'creates a warning on line 8' do
        expect(problems).to contain_warning(class_msg % :bar).on_line(8).in_column(10)
      end
    end

    context 'private class with parameters documented twice (@param)' do
      let(:code) do
        <<-EOS.gsub(/^\s+/, '')
      # @summary Example class
      #
      # @param bar docs
      # @param bar Duplicate/conflicting docs
      #
      # @api private
      class example($bar) { }
        EOS
      end

      it 'detects two problems' do
        expect(problems).to have(2).problem
      end

      it 'creates a warning on line 3' do
        expect(problems).to contain_warning(class_msg % :bar).on_line(3).in_column(10)
      end

      it 'creates a warning on line 4' do
        expect(problems).to contain_warning(class_msg % :bar).on_line(4).in_column(10)
      end
    end

    context 'class with parameters documented twice ([*bar*])' do
      let(:code) do
        <<-EOS.gsub(/^\s+/, '')
      # @summary Example class
      #
      # @param bar
      #   example
      # @param foo example
      # [*bar*] Duplicate/conflicting docs
      #
      class example($foo, $bar) { }
        EOS
      end

      it 'detects two problems' do
        expect(problems).to have(2).problem
      end

      it 'creates a warning on line 3' do
        expect(problems).to contain_warning(class_msg % :bar).on_line(3).in_column(10)
      end

      it 'creates a warning on line 6' do
        expect(problems).to contain_warning(class_msg % :bar).on_line(6).in_column(3)
      end
    end
  end

  context 'class with documentation for parameters that don\'t exist' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # @summary Example class
      #
      # @param foo
      class example { }
      EOS
    end

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning on line 3' do
      expect(problems).to contain_warning('No matching class parameter for documentation of example::foo').on_line(3).in_column(10)
    end
  end

  context 'private class with documentation for parameters that don\'t exist' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # @summary Example class
      #
      # @param foo
      #   Example docs
      #
      # @api private
      class example { }
      EOS
    end

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning on line 3' do
      expect(problems).to contain_warning('No matching class parameter for documentation of example::foo').on_line(3).in_column(10)
    end
  end

  context 'define with documentation for parameters that don\'t exist' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # @summary Example define
      #
      # @param bar Docs for bar
      # @param foo
      #   Docs for foo
      #
      # @api private
      define example::example(String[1] $bar) { }
      EOS
    end

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning on line 4' do
      expect(problems).to contain_warning('No matching defined type parameter for documentation of example::example::foo').on_line(4).in_column(10)
    end
  end

  context 'define with documentation for parameter `name`' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # @summary Example define
      #
      # @param name
      #   Docs for the $name
      # @param bar Docs for bar
      define example::example(String[1] $bar) { }
      EOS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with documentation for parameter `name`' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # @summary Example class
      #
      # @param name
      #   Invalid docs
      class example { }
      EOS
    end

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning on line 3' do
      expect(problems).to contain_warning('No matching class parameter for documentation of example::name').on_line(3).in_column(10)
    end
  end

  context 'define with documentation for parameter `title`' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # @summary Example define
      #
      # @param title
      #   Docs for the $title
      # @param bar Docs for bar
      define example::example(String[1] $bar) { }
      EOS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with documentation for parameter `title`' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # @summary Example class
      #
      # @param title
      #   Invalid docs
      class example { }
      EOS
    end

    it 'detects a single problem' do
      expect(problems).to have(1).problem
    end

    it 'creates a warning on line 3' do
      expect(problems).to contain_warning('No matching class parameter for documentation of example::title').on_line(3).in_column(10)
    end
  end

  context 'define with documentation for both `title` and `name`' do
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # @summary Example define
      #
      # @param title
      #   Docs for the $title
      # @param name
      #   Docs for the $name
      # @param bar Docs for bar
      define example(String[1] $bar) { }
      EOS
    end

    it 'detects two problems' do
      expect(problems).to have(2).problems
    end

    it 'creates a warning on line 3' do
      expect(problems).to contain_warning('Duplicate defined type parameter documentation for example::name/title').on_line(3).in_column(10)
    end

    it 'creates a warning on line 5' do
      expect(problems).to contain_warning('Duplicate defined type parameter documentation for example::name/title').on_line(5).in_column(10)
    end
  end

  context 'class with array defaults containing variables' do
    # Example taken from https://github.com/voxpupuli/puppet-lint-param-docs/issues/30
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # @summary example class
      #
      # @param parameter_1
      # @param parameter_2
      # @param parameter_3
      # @param parameter_4
      # @param parameter_5
      # @param parameter_6
      # @param parameter_7
      # @param parameter_8
      #
      class example (
        Array $parameter_1 = $variable1,
        Array $parameter_2 = [ $variable2, ],
        Array $parameter_3 = [ $variable3, 'string1', ],
        Array $parameter_4 = [
          $variable4,
          'string1',
        ],
        Array $parameter_5 = [ $variable5, $variable6, 'string1', ],
        Array $parameter_6 = [ $variable7, 'string1', $variable8, ],
        Array $parameter_7 = [ 'string1', $variable9, ],
        Array $parameter_8 = [
          'string1',
          $variable10,
          'string2',
        ],
      ) {
        # foo
      }
      EOS
    end

    it 'does not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class with hash defaults containing variables' do
    # Example taken from https://github.com/voxpupuli/puppet-lint-param-docs/issues/49
    let(:code) do
      <<-EOS.gsub(/^\s+/, '')
      # @summary example class
      #
      # @param parameter_1
      # @param parameter_2
      # @param parameter_3
      # @param parameter_4
      # @param parameter_5
      # @param parameter_6
      # @param parameter_7
      # @param parameter_8
      # @param parameter_9
      # @param parameter_10
      # @param parameter_11
      # @param parameter_12
      #
      class example (
        Hash $parameter_1 = $variable1,
        Hash $parameter_2 = { $variable2, },
        Hash $parameter_3 = { $variable3, 'string1', },
        Hash $parameter_4 = {
          $variable4,
          'string1',
        },
        Hash $parameter_5 = { $variable5, $variable6, 'string1', },
        Hash $parameter_6 = { $variable7, 'string1', $variable8, },
        Hash $parameter_7 = { 'string1', $variable9, },
        Hash $parameter_8 = {
          'string1',
          $variable10,
          'string2',
        },
        Hash $parameter_9 = [ { 'string1', $variable11, } ],
        Hash $parameter_10 = [ { 'string1', $variable12, }, { 'string1', $variable13, } ],
        Hash $parameter_11 = { [ 'string1', $variable14, ] },
        Hash $parameter_12 = [ 'string1' => $variable15, 'string2' => $variable16, ],
      ) {
        # foo
      }
      EOS
    end

    it 'does not detect any problems' do
      puts problems
      expect(problems).to have(0).problems
    end
  end
end
