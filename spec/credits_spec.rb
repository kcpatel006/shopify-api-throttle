
require './spec/boot'

describe "Throttle" do
  it "Can fetch local limits" do
    count = ShopifyAPI.credit_used
    limit = ShopifyAPI.credit_limit
    
    (count < limit).should be_true
    (count > 0).should be_true
    ShopifyAPI.credit_maxed?.should be_false
    (ShopifyAPI.credit_left > 0).should be_true
  end
  
  it "Can execute up to local max" do
    until ShopifyAPI.credit_maxed?
      ShopifyAPI.throttle { ShopifyAPI::Shop.current }
      puts "avail: #{ShopifyAPI.credit_left}, maxed: #{ShopifyAPI.credit_maxed?}"
    end
    ShopifyAPI.credit_maxed?.should be_true
    (ShopifyAPI.credit_left == 0).should be_true

    puts "Response:"
    ShopifyAPI.response.each{|header,value| puts "#{header}: #{value}" }

    puts "Retry after: #{ShopifyAPI.retry_after}"
    (ShopifyAPI.retry_after > 0).should be_true
  end
    
end
