require 'xrvg'

Gem::Specification.new do |s|
  s.name = 'xrvg'
  s.version = XRVG_VERSION

  s.summary = 'Ruby vector graphics library'

  s.authors = ['Julien L\u{e9}onard']
  s.email = 'julien.leonard@nospam@ensta.org'
  s.homepage = 'http://xrvg.rubyforge.org/'

  s.files = Dir['lib/*.rb', 'examples/*.rb',
                'Rakefile', 'LICENSE',
                'README']

  s.extra_rdoc_files = ['README']
  s.rdoc_options = ['--title', 'XRVG API documentation', '--main', 'README']
  s.rubyforge_project = 'xrvg'
  s.has_rdoc = true

  s.add_development_dependency('test-unit', ['~> 3.2'])
  s.add_development_dependency('rake', ['~> 11.1'])

  s.require_paths = ['lib']
end
