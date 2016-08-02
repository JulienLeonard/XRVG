# Rakefile
require "rake/testtask"
require "rake/clean"
require "rdoc/task"
#---
# The name of your project
PROJECT = "XRVG"

# Directory on RubyForge where your website's files should be uploaded.
WEBSITE_DIR = "www"

# Output directory for the rdoc html files.
# If you don't have a custom homepage, and want to use the RDoc
# index.html as homepage, just set it to WEBSITE_DIR.
RDOC_HTML_DIR = "#{WEBSITE_DIR}/rdoc"
#---
REQUIRE_PATHS = ["lib"]

CLEAN.include("test/**/*.svg", "*.svg")
#---
# Options common to RDocTask AND Gem::Specification.
#   The --main argument specifies which file appears on the index.html page
GENERAL_RDOC_OPTS = {
  "--title" => "#{PROJECT} API documentation",
  "--main" => "README"
}

# Additional RDoc formatted files, besides the Ruby source files.
RDOC_FILES = FileList["README"]

# Ruby library code.
LIB_FILES = FileList["lib/*.rb"]

# Filelist with Test::Unit test cases.
TEST_FILES = FileList["test/test_*.rb"]

#---
# Run the tests if rake is invoked without arguments.
task "default" => ["test"]

test_task_name = "test"
Rake::TestTask.new(test_task_name) do |t|
  t.test_files = TEST_FILES
  t.libs = REQUIRE_PATHS
end
#---
# The "rdoc" task generates API documentation.
Rake::RDocTask.new("rdoc") do |t|
  t.rdoc_files = RDOC_FILES + LIB_FILES
  t.title = GENERAL_RDOC_OPTS["--title"]
  t.main = GENERAL_RDOC_OPTS["--main"]
  t.rdoc_dir = RDOC_HTML_DIR
end


#---
# The "prepare-release" task makes sure your tests run, and then generates
# files for a new release.
desc "Run tests, generate RDoc and create packages."
task "prepare-release" => ["clobber"] do
  puts "Preparing release of #{PROJECT} version #{XRVG_VERSION}"
  Rake::Task["test"].invoke
  Rake::Task["rdoc"].invoke
  Rake::Task["package"].invoke
end

#---
# $ rake -T
# rake clean            # Remove any temporary products.
# rake clobber          # Remove any generated file.
# rake clobber_rdoc     # Remove rdoc products
# rake prepare-release  # Run tests, generate RDoc and create packages.
# rake rdoc             # Build the rdoc HTML Files
# rake rerdoc           # Force a rebuild of the RDOC files
# rake test             # Run tests for test
#---
