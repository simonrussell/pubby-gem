Gem::Specification.new do |s|

  s.name = 'pubby'
  s.version = '0.0.3'
  s.summary = 'Wrappers for various channel publishing APIs'
  s.description = <<-EOS
                    Wrappers for various channel publishing APIs; trying to keep the API simple and consistent.
                  EOS

  s.author = 'Simon Russell'
  s.email = 'spam+pubby@bellyphant.com'
  s.homepage = 'http://github.com/simonrussell/pubby-gem'
  
  s.required_ruby_version = '>= 1.9.2'

  s.files = Dir['lib/**/*.rb'] + ['LICENSE', 'README.md']
  
  s.add_dependency 'eventmachine', '> 0.12.10'
  s.add_dependency 'em-http-request', '> 0.3.0'
  s.add_dependency 'json', '> 1.5.0'
  s.add_dependency 'escape_utils', '> 0.2.3'
  
end
