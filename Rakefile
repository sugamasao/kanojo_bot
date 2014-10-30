begin
  # only development or test
  require 'rspec/core/rake_task'
  require 'yard'

  task default: :spec

  RSpec::Core::RakeTask.new
  YARD::Rake::YardocTask.new
rescue => e
end
