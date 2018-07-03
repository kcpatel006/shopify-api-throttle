module ShopifyAPI
  module Throttle
    module ClassMethods
      THROTTLE_RETRY_AFTER = 10
      THROTTLE_RETRY_MAX = 5
      THROTTLE_MIN_CREDIT = 10

      def throttle(&block)
        retried = 0
        begin
          if ShopifyAPI.credit_below?(THROTTLE_MIN_CREDIT)
            sleep_for = [[THROTTLE_MIN_CREDIT - ShopifyAPI.credit_left, THROTTLE_RETRY_AFTER].min, 1].max
            puts "Credit Maxed: #{ShopifyAPI.credit_left}/#{ShopifyAPI.credit_limit}, sleeping for #{sleep_for} seconds"
            sleep sleep_for

            if $shopify_store and $shopify_store.respond_to? :on_throttled # Use this to call back into your application to update something
              $shopify_store.on_throttled
            end
          end

          yield
        rescue ActiveResource::ResourceNotFound, ActiveResource::BadRequest, ActiveResource::UnauthorizedAccess,
               ActiveResource::ForbiddenAccess, ActiveResource::MethodNotAllowed, ActiveResource::ResourceGone,
               ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid => ex
          raise ex
        rescue ActiveResource::ConnectionError, ActiveResource::ServerError,
               ActiveResource::ClientError, Timeout::Error, OpenSSL::SSL::SSLError => ex
          if retried <= THROTTLE_RETRY_MAX
            retry_after = ((ex.respond_to?(:response) && ex.response && ex.response['Retry-After']) || THROTTLE_RETRY_AFTER).to_i
            puts "Throttle Retry: #{ShopifyAPI.credit_left}/#{ShopifyAPI.credit_limit}, sleeping for #{retry_after} seconds"
            sleep retry_after
            retried += 1
            retry
          else
            raise ex
          end
        rescue => ex
          if ex.message =~ /Connection timed out/
            sleep THROTTLE_RETRY_AFTER
            retried += 1
            retry
          else
            puts "Exception Raised: #{ex.class}"
            raise ex
          end
        end
      end
    end
  end
end