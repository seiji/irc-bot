task :default => [:spec]

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = 'spec/**/*_spec.rb'
    spec.rspec_opts = ['-c']
    spec.ruby_opts = ['-I app']
    #    spec.rspec_opts = ['-cfs']
  end
rescue LoadError => e
end

namespace "spec" do
  desc "Run individual spec. Can also pass in a line number."
  task :run, :spec_file, :line_number do |_, args|
    puts args.spec_file
    run_spec_cmd =  if args.line_number.nil?
                      "bundle exec ruby -S rspec -cfs -I app #{args.spec_file}"
                    else
                      "bundle exec ruby -S rspec --color -l #{args.line_number} #{args.spec_file}"
                    end
    sh run_spec_cmd
  end

  desc "Show Test Coverage"
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task["spec"].execute
  end
end
