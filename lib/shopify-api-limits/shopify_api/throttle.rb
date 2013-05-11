module ShopifyAPI
  module Limits
    module ClassMethods
      THROTTLE_RETRY_AFTER = 10
      THROTTLE_RETRY_MAX = 30

      def throttle(&block)
        retried = 0
        begin
            if ShopifyAPI.credit_below?(50)
              puts "Credit Maxed: #{ShopifyAPI.credit_left}/#{ShopifyAPI.credit_limit}, sleeping for #{THROTTLE_RETRY_AFTER} (#{ShopifyAPI.retry_after}) seconds"
              sleep THROTTLE_RETRY_AFTER
            end

            yield
        rescue ActiveResource::ResourceNotFound, ActiveResource::BadRequest, ActiveResource::UnauthorizedAccess,
            ActiveResource::ForbiddenAccess, ActiveResource::MethodNotAllowed, ActiveResource::ResourceGone,
            ActiveResource::ResourceConflict, ActiveResource::ResourceInvalid => ex
          raise ex
        rescue ActiveResource::ConnectionError, ActiveResource::ServerError,
            ActiveResource::ClientError, Timeout::Error => ex
          unless retried > THROTTLE_RETRY_MAX
            retry_after = ((ex.respond_to?(:response) && ex.response && ex.response['Retry-After']) || THROTTLE_RETRY_AFTER).to_i
            puts "Throttle Retry: #{ShopifyAPI.credit_left}/#{ShopifyAPI.credit_limit}, sleeping for #{retry_after} seconds"
            sleep retry_after
            retried += 1
            retry
          else
            raise ex
          end
        end
      end
    end
  end
end