# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "shopify-api-throttle/version"

Gem::Specification.new do |s|
  s.name        = "shopify-api-throttle"
  s.version     = ShopifyAPI::Throttle::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brad Rees"]
  s.email       = ["brad@shopifypowertools.com"]
  s.homepage    = ""
  s.summary     = %q{This gem throttles API calls to keep within the limits of the ShopifyAPI gem}
  s.description = %q{This gem throttles API calls to keep within the limits of the ShopifyAPI gem}

  #s.rubyforge_project = "shopify-api-throttle"
  
  s.add_dependency "shopify_api", '>= 1.2.2'
  s.add_development_dependency "rspec", '>=2.6.0'
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
