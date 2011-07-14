Gem::Specification.new do |s|

  s.name = 'pubby'
  s.version = '0.0.2'
  s.summary = 'Wrappers for various channel publishing APIs'
  s.description = <<-EOS
                    Wrappers for various channel publishing APIs; trying to keep the API simple and consistent.
                  EOS

  s.author = 'Simon Russell'
  s.email = 'spam+pubby@bellyphant.com'
  s.homepage = 'http://github.com/simonrussell/pubby-gem'
  
  s.required_ruby_version = '>= 1.9.2'

  s.files = Dir['lib/**/*.rb'] + ['LICENSE', 'README.md']
  
end
