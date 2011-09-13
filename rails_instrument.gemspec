# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rails_instrument/version"

Gem::Specification.new do |s|
  s.name        = "rails_instrument"
  s.version     = RailsInstrument::VERSION
  s.authors     = ["Selva"]
  s.email       = ["k.n.selvakumar@gmail.com"]
  s.homepage    = "https://github.com/selvakn/rails_instrument"
  s.summary     = %q{Middleware to show instrumentation information in http headers}
  s.description = %q{Middleware to show instrumentation information in http headers}

  s.rubyforge_project = "rails_instrument"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
