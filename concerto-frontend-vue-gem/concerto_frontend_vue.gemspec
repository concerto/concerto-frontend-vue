$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "concerto_frontend_vue/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "concerto_frontend_vue"
  s.version     = ConcertoFrontendVue::VERSION
  s.license     = "Apache-2.0"
  s.authors     = ["Marvin Frederickson"] # based on work by Gabriel Perez
  s.email       = ["marvin.frederickson@gmail.com"]  # perez283@gmail.com
  s.homepage    = "https://concerto-signage.org"
  s.summary     = "Concerto Frontend using Vue.js"
  s.description = "A Ruby Gem that contains the Concerto Digital Signage Vue.js frontend."

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails" #, '~>4.2'

  s.add_development_dependency "sqlite3"
end
