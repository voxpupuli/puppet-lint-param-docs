require 'spec_helper'

describe 'parameter_documentation' do
  let(:msg) { 'missing documentation for class parameter example::%s' }

  context 'class missing any documentation' do
    let(:code) { 'class example($foo) { }' }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg % :foo).on_line(1).in_column(15)
    end
  end

  context 'class with param defaults' do
    let(:code) { 'class example($foo = $example::params::foo) { }' }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg % :foo).on_line(1).in_column(15)
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
      expect(problems).to contain_warning(msg % :foo).on_line(7).in_column(15)
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
      expect(problems).to contain_warning(msg % :foo).on_line(7).in_column(15)
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
      expect(problems).to contain_warning(msg % :foo).on_line(7).in_column(15)
      expect(problems).to contain_warning(msg % :baz).on_line(7).in_column(27)
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
      expect(problems).to contain_warning(msg % :foo).on_line(7).in_column(15)
      expect(problems).to contain_warning(msg % :baz).on_line(7).in_column(27)
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

  context 'class without parameters' do
    let(:code) { 'class example { }' }

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
end
