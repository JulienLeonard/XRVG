require "rubygems"

spec = Gem::Specification.new do |gem|
   gem.name        = "xrvg"
   gem.version     = "0.0.1"
   gem.author      = "J. Leonard"
   gem.email       = "julien.leonard@ensta.org"
   gem.homepage    = "http://xrvg.rubyforge.org"
   gem.platform    = Gem::Platform::RUBY
   gem.summary     = "X Ruby Vector Graphics"
   gem.description = "High level graphic programming library"
   # gem.test_file   = "test/tc_xrvg.rb"
   gem.has_rdoc    = true
   gem.files       = Dir["lib/xrvg/*.rb"] + Dir["lib/*.rb"] + Dir["test/*"] + Dir["examples/*"] + Dir["[A-Z]*"]
   gem.files.reject! { |fn| fn.include? "CVS" }
   gem.require_path = "lib"
   gem.extra_rdoc_files = ["README", "MIT-LICENCE"]
   # gem.add_dependency("package-name", ">= 0.5.1")
end

if $0 == __FILE__
   Gem.manage_gems
   Gem::Builder.new(spec).build
end
