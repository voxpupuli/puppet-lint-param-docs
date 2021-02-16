require 'spec_helper'

describe 'parameter_documentation' do
  let(:class_msg) { 'missing documentation for class parameter example::%s' }
  let(:define_msg) { 'missing documentation for defined type parameter example::%s' }

  context 'class missing any documentation' do
    let(:code) { 'class example($foo) { }' }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(class_msg % :foo).on_line(1).in_column(15)
    end
  end

  context 'define missing any documentation' do
    let(:code) { 'define example($foo) { }' }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(define_msg% :foo).on_line(1).in_column(16)
    end
  end

  context 'class with param defaults' do
    let(:code) { 'class example($foo = $example::params::foo) { }' }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(class_msg % :foo).on_line(1).in_column(15)
    end
  end

  context 'define with param defaults' do
    let(:code) { 'define example($foo = $example::params::foo) { }' }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(define_msg % :foo).on_line(1).in_column(16)
    end
  end

  context 'define with param defaults using a function' do
    let(:code) { 'define example($foo = min(8, $facts["processors"]["count"])) { }' }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(define_msg % :foo).on_line(1).in_column(16)
    end
  end

  context 'class with many param defaults' do
    let(:code) do
      <<-EOS
class foreman (
  $foreman_url            = $foreman::params::foreman_url,
  $unattended             = $foreman::params::unattended,
  $authentication         = $foreman::params::authentication,
  $passenger              = $foreman::params::passenger,
) {}
      EOS
    end

    it 'should detect four problems' do
      expect(problems).to have(4).problems
    end
  end

  context 'define with many param defaults' do
    let(:code) do
      <<-EOS
define foreman (
  $foreman_url            = $foreman::params::foreman_url,
  $unattended             = $foreman::params::unattended,
  $authentication         = $foreman::params::authentication,
  $passenger              = $foreman::params::passenger,
) {}
      EOS
    end

    it 'should detect four problems' do
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

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
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

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
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

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
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

    context 'check private api disabled (default)' do
      it 'should detect no single problems' do
        expect(problems).to have(0).problems
      end

      it 'should not create a warning' do
        expect(problems).not_to contain_info(class_msg % :foo)
      end
    end

    context 'check private api enabled' do
      before do
        PuppetLint.configuration.docs_check_private_params = true
      end

      after do
        PuppetLint.configuration.docs_check_private_params = false
      end

      it 'should detect a single problems' do
        expect(problems).to have(1).problem
      end

      it 'should create a warning' do
        expect(problems).to contain_warning(class_msg % :foo).on_line(6).in_column(15)
      end
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

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
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

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
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

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
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

    it 'should detect two problem' do
      expect(problems).to have(2).problems
    end

    it 'should create two warnings' do
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

    it 'should detect two problem' do
      expect(problems).to have(2).problems
    end

    it 'should create two warnings' do
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

    it 'should detect two problem' do
      expect(problems).to have(2).problems
    end

    it 'should create two warnings' do
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

    it 'should detect two problem' do
      expect(problems).to have(2).problems
    end

    it 'should create two warnings' do
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

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
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

    it 'should not detect any problems' do
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

    it 'should not detect any problems' do
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

    it 'should not detect any problems' do
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

    it 'should not detect any problems' do
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

    it 'should not detect any problems' do
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

    it 'should not detect any problems' do
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

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class without parameters' do
    let(:code) { 'class example { }' }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'define without parameters' do
    let(:code) { 'define example { }' }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'class without parameters and a function call' do
    let(:code) { 'class example { a($foo::bar) }' }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'define without parameters and a function call' do
    let(:code) { 'define example { a($foo::bar) }' }

    it 'should not detect any problems' do
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

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
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

      it 'should detect two problems' do
        expect(problems).to have(2).problem
      end

      it 'should create a warning on line 3' do
        expect(problems).to contain_warning(class_msg % :bar).on_line(3).in_column(10)
      end

      it 'should create a warning on line 6' do
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

      it 'should detect two problems' do
        expect(problems).to have(2).problem
      end

      it 'should create a warning on line 3' do
        expect(problems).to contain_warning(define_msg % :bar).on_line(3).in_column(10)
      end

      it 'should create a warning on line 6' do
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

      it 'should detect three problems' do
        expect(problems).to have(3).problem
      end

      it 'should create a warning on line 3' do
        expect(problems).to contain_warning(class_msg % :bar).on_line(3).in_column(10)
      end

      it 'should create a warning on line 6' do
        expect(problems).to contain_warning(class_msg % :bar).on_line(6).in_column(10)
      end

      it 'should create a warning on line 8' do
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

      it 'should detect two problems' do
        expect(problems).to have(2).problem
      end

      it 'should create a warning on line 3' do
        expect(problems).to contain_warning(class_msg % :bar).on_line(3).in_column(10)
      end

      it 'should create a warning on line 4' do
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

      it 'should detect two problems' do
        expect(problems).to have(2).problem
      end

      it 'should create a warning on line 3' do
        expect(problems).to contain_warning(class_msg % :bar).on_line(3).in_column(10)
      end

      it 'should create a warning on line 6' do
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

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning on line 3' do
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

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning on line 3' do
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

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning on line 4' do
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

    it 'should not detect any problems' do
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

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning on line 3' do
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

    it 'should not detect any problems' do
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

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning on line 3' do
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

    it 'should detect two problems' do
      expect(problems).to have(2).problems
    end

    it 'should create a warning on line 3' do
      expect(problems).to contain_warning('Duplicate defined type parameter documentation for example::name/title').on_line(3).in_column(10)
    end

    it 'should create a warning on line 5' do
      expect(problems).to contain_warning('Duplicate defined type parameter documentation for example::name/title').on_line(5).in_column(10)
    end
  end
end
