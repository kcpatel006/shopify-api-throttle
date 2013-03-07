module ShopifyAPI
  module Limits    
    module ClassMethods

      # Takes form num_requests_executed/max_requests
      # Eg: 101/3000
      SHOPIFY_CREDIT_LIMIT_HEADER_PARAM = 'http_x_shopify_shop_api_call_limit'

      RETRY_AFTER_HEADER = 'retry-after'

      RETRY_AFTER = 60

      ##
      # How many more API calls can I make?
      # @return {Integer}
      #
      def credit_left
        credit_limit - credit_used
      end
      alias_method :available_calls, :credit_left
      
      ##
      # Have I reached my API call limit?
      # @return {Boolean}
      #
      def credit_maxed?(required = 1)
        credit_left < required
      end
      alias_method :maxed?, :credit_maxed?
      
      ##
      # How many total API calls can I make?
      # NOTE: subtracting 1 from credit_limit because I think ShopifyAPI cuts off at 299/2999 or shop/global limits.
      # @param {Symbol} scope [:shop|:global]
      # @return {Integer}
      #
      def credit_limit
        @api_credit_limit ||= api_credit_limit_param.pop.to_i - 1
      end
      alias_method :call_limit, :credit_limit

      ##
      # How many API calls have I made?
      # @param {Symbol} scope [:shop|:global]
      # @return {Integer}
      #
      def credit_used
        api_credit_limit_param.shift.to_i
      end
      alias_method :call_count, :credit_used
      
      ##
      # @return {HTTPResponse}
      #
      def response
        begin
          Shop.current unless Base.connection.response
        rescue ActiveResource::ClientError
          return { SHOPIFY_CREDIT_LIMIT_HEADER_PARAM => '0/500', RETRY_AFTER_HEADER => RETRY_AFTER }
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

      private

      ##
      # @return {Array}
      #
      def api_credit_limit_param
        response[SHOPIFY_CREDIT_LIMIT_HEADER_PARAM].split('/')
      end
    end
  end
end
