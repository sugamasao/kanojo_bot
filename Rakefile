begin
  Bundler.require(:default, :development, :test)

  task default: :spec

  RSpec::Core::RakeTask.new
  YARD::Rake::YardocTask.new
rescue LoadError
end
