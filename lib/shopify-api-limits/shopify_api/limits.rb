module ShopifyAPI
  module Limits    
    module ClassMethods

      RETRY_AFTER_HEADER = 'retry-after'

      RETRY_AFTER = 10

      ##
      # Have I reached my API call limit?
      # @return {Boolean}
      #
      def credit_below?(required = 1)
        credit_left < required
      end

      ##
      # @return {HTTPResponse}
      #
      def response
        begin
          Shop.current unless Base.connection.response
        rescue ActiveResource::ClientError
          return { CREDIT_LIMIT_HEADER_PARAM => '0/500', RETRY_AFTER_HEADER => RETRY_AFTER }
        end
        Base.connection.response
      end

      ##
      # How many seconds until we can retry
      # @return {Integer}
      #
      def retry_after
        @retry_after = response[RETRY_AFTER_HEADER].to_i
        @retry_after = @retry_after == 0 ? RETRY_AFTER : @retry_after
      end
    end
  end
end
