module ShopifyAPI
  module Limits
    module ClassMethods
      RETRY_AFTER = 60
      RETRY_MAX = 5

      def throttle(&block)
        retried = 0
        begin
            if ShopifyAPI.credit_maxed?
              sleep ShopifyAPI.retry_after
            end

            yield
        rescue ActiveResource::ConnectionError, ActiveResource::ServerError,
            ActiveResource::ClientError => ex
          unless retried > RETRY_MAX
            sleep(((ex.respond_to?(:response) && ex.response['Retry-After']) || RETRY_AFTER).to_i)
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