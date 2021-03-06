require 'uri'
require 'byebug'

module Phase5
  class Params
    attr_accessor :params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = route_params
      parse_www_encoded_form(req.query_string) unless req.query_string.nil?
      parse_www_encoded_form(req.body) unless req.body.nil?


    end

    def [](key)
      params[key.to_s]
    end

    def to_s
      params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      queries = URI::decode_www_form(www_encoded_form)
      queries.each do |query|
        # byebug
        query[0] = parse_key(query[0])
        query.flatten!
        until query.count == 2
          val = query.pop
          key = query.pop
          hash = { key => val }
          query << hash
        end
        params[query.first] = query.last
      end

    end


    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
