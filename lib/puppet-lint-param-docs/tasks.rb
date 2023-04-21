module PuppetLintParamDocs
  # A helper to define a more specific rake task that runs after the
  # usual 'lint' task, but only with param docs checks.  It disables
  # the param docs checks in the main lint task.
  #
  # Allows users to define a more restrictive pattern for param docs
  # checks.
  def self.define_selective(&task_block)
    RakeTask.new.define_selective(&task_block)
  end

  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined?(::Rake::DSL)

    def define_selective
      PuppetLint::RakeTask.new(:lint_param_docs) do |config|
        config.fail_on_warnings = true
        config.disable_checks = (PuppetLint.configuration.checks - [:parameter_documentation])
        yield config
      end

      # Explicitly enable check as "lint" task will disable it
      task :lint_param_docs_enable do
        PuppetLint.configuration.enable_parameter_documentation
      end
      Rake::Task[:lint_param_docs].enhance [:lint_param_docs_enable]

      # Explicitly disable param doc in general lint task
      task :lint_param_docs_disable do
        PuppetLint.configuration.disable_parameter_documentation
      end
      Rake::Task[:lint].enhance [:lint_param_docs_disable]

      # Run param docs lint after main lint
      Rake::Task[:lint].enhance do
        Rake::Task[:lint_param_docs].invoke
      end
    end
  end
end
