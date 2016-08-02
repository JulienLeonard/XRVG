# Rakefile
require "rake/testtask"
require "rake/clean"
require 'bundler/gem_tasks'
require "rdoc/task"

CLEAN.include("test/**/*.svg", "*.svg")

# Run the tests if rake is invoked without arguments.
task "default" => ["test"]

test_task_name = "test"
Rake::TestTask.new(test_task_name) do |t|
  t.test_files = FileList["test/test_*.rb"]
  t.libs = ['lib']
end

# The "rdoc" task generates API documentation.
Rake::RDocTask.new("rdoc") do |t|
  t.rdoc_files = FileList["README", "lib/*.rb"]
  t.title = "XRVG API documentation"
  t.main = "README"
end


# The "prepare-release" task makes sure your tests run, and then generates
# files for a new release.
desc "Run tests, generate RDoc and create packages."
task "prepare-release" => ["clobber"] do
  Rake::Task["test"].invoke
  Rake::Task["rdoc"].invoke
  Rake::Task["build"].invoke
end
