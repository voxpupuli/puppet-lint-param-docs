require 'spec_helper'

describe 'parameter_documentation' do
  let(:msg) { 'missing documentation for class parameter example::foo' }

  context 'class missing any documentation' do
    let(:code) { 'class example($foo) { }' }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(15)
    end
  end

  context 'class with param defaults' do
    let(:code) { 'class example($foo = $example::params::foo) { }' }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(1).in_column(15)
    end
  end

  context 'class missing documentation for a parameter' do
    let(:code) do
      <<-EOS
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
      # column looks wrong, maybe the parser's out
      expect(problems).to contain_warning(msg).on_line(7).in_column(21)
    end
  end

  context 'class with all parameters documented' do
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

  context 'class without parameters' do
    let(:code) { 'class example { }' }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end
end
