$:.unshift File.dirname(__FILE__)

module ShopifyAPI
  module Throttle
    # Connection hack
    require 'shopify_api'
    #require 'shopify-api-limits/shopify_api/base'
    
    require 'shopify-api-throttle/shopify_api/limits'
    require 'shopify-api-throttle/shopify_api/throttle'
    
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end
    
    class Error < StandardError; end
    class GlobalError < Error; end
    class ShopError < Error; end
    
  end
end

ShopifyAPI.send(:include, ShopifyAPI::Throttle)
