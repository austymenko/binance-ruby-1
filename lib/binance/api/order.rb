module Binance
  module Api
    class Order
      class << self

        def position_risk(recvWindow: 5000, symbol: nil, api_key: nil, api_secret_key: nil)
          # puts "\n positionRisk"

          timestamp = Configuration.timestamp
          params = { recvWindow: recvWindow, symbol: symbol, timestamp: timestamp }
          Request.send_fapi!(api_key_type: :read_info, path: "/fapi/v2/positionRisk",
                        params: params, security_type: :user_data, tld: Configuration.tld, api_key: api_key,
                        api_secret_key: api_secret_key)

        end

        def new_limit_order(symbol: nil, price: nil, stop_price: nil, type: nil, side: nil, position_side: nil, quantity: nil, recvWindow: 5000, api_key: nil, api_secret_key: nil, path: "/fapi/v1/order")
          Rails.logger.info "Binance::Api::Order #new_order #{DateTime.now.to_s}"

          timestamp = Configuration.timestamp
          params = {
            recvWindow: recvWindow,
            symbol: symbol,
            side: side,
            type: type,
            quantity: quantity,
            positionSide: position_side,
            price: price,
            stopPrice: stop_price,
            timestamp: timestamp,
          }
          Request.send_fapi!(api_key_type: :read_info, path: path,
                             method: :post,
                             params: params, security_type: :user_data, tld: Configuration.tld, api_key: api_key,
                             api_secret_key: api_secret_key)

        end

        # symbol: nil, price: nil, stop_price: nil, type: nil, side: nil, position_side: nil,
        #   quantity: nil,  api_key: nil, api_secret_key: nil
        def new_limit_order_hash_param(hash_param:, recvWindow: 5000, path: "/fapi/v1/order")
          Rails.logger.info "Binance::Api::Order #new_limit_order_hash_param #{DateTime.now.to_s}"

          timestamp = Configuration.timestamp
          params = {
            recvWindow: recvWindow,
            symbol: hash_param[:symbol],
            side: hash_param[:side],
            type: hash_param[:type],
            quantity: hash_param[:quantity],
            positionSide: hash_param[:position_side],
            price: hash_param[:price],
            stopPrice: hash_param[:stop_price],
            timestamp: timestamp,
            timeInForce: 'GTC',
          }
          Request.send_fapi!(api_key_type: :read_info, path: path,
                             method: :post,
                             params: params, security_type: :user_data, tld: Configuration.tld,
                             api_key: hash_param[:api_key],
                             api_secret_key: hash_param[:api_secret_key])

        end

        def new_order(symbol: nil, type: nil, side: nil, position_side: nil, quantity: nil, recvWindow: 5000, api_key: nil, api_secret_key: nil)
          #puts "\n new_order"

          timestamp = Configuration.timestamp
          params = {
            recvWindow: recvWindow,
            symbol: symbol,
            side: side,
            type: type,
            quantity: quantity,
            positionSide: position_side,
            timestamp: timestamp
          }
          Request.send_fapi!(api_key_type: :read_info, path: "/fapi/v1/order",
                             method: :post,
                             params: params, security_type: :user_data, tld: Configuration.tld, api_key: api_key,
                             api_secret_key: api_secret_key)

        end

        def all!(limit: 500, orderId: nil, recvWindow: 5000, symbol: nil, api_key: nil, api_secret_key: nil)
          raise Error.new(message: "max limit is 500") unless limit <= 500
          raise Error.new(message: "symbol is required") if symbol.nil?
          timestamp = Configuration.timestamp
          params = { limit: limit, orderId: orderId, recvWindow: recvWindow, symbol: symbol, timestamp: timestamp }
          Request.send!(api_key_type: :read_info, path: "/api/v3/allOrders",
                        params: params.delete_if { |key, value| value.nil? },
                        security_type: :user_data, tld: Configuration.tld, api_key: api_key,
                        api_secret_key: api_secret_key)
        end

        # Be careful when accessing without a symbol!
        def all_open!(recvWindow: 5000, symbol: nil, api_key: nil, api_secret_key: nil)
          timestamp = Configuration.timestamp
          params = { recvWindow: recvWindow, symbol: symbol, timestamp: timestamp }
          Request.send!(api_key_type: :read_info, path: "/api/v3/openOrders",
                        params: params, security_type: :user_data, tld: Configuration.tld, api_key: api_key,
                        api_secret_key: api_secret_key)
        end

        def all_open_fapi!(recvWindow: 5000, symbol: nil, api_key: nil, api_secret_key: nil)
          timestamp = Configuration.timestamp
          params = { recvWindow: recvWindow, symbol: symbol, timestamp: timestamp }
          Request.send_fapi!(api_key_type: :read_info, path: "/fapi/v1/openOrders",
                        params: params, security_type: :user_data, tld: Configuration.tld, api_key: api_key,
                        api_secret_key: api_secret_key)
        end

        def all_fapi!(recvWindow: 5000, symbol: nil, api_key: nil, api_secret_key: nil)
          timestamp = Configuration.timestamp
          params = { recvWindow: recvWindow, symbol: symbol, timestamp: timestamp }
          Request.send_fapi!(api_key_type: :read_info, path: "/fapi/v1/allOrders",
                             params: params, security_type: :user_data, tld: Configuration.tld, api_key: api_key,
                             api_secret_key: api_secret_key)
        end

        def cancel_order_fapi!(recvWindow: 5000, order_id: nil, symbol: nil, api_key: nil, api_secret_key: nil)
          timestamp = Configuration.timestamp
          params = { recvWindow: recvWindow, symbol: symbol, orderId: order_id, timestamp: timestamp }
          Request.send_fapi!(api_key_type: :read_info, path: "/fapi/v1/order",
                             method: :delete,
                             params: params, security_type: :user_data, tld: Configuration.tld, api_key: api_key,
                             api_secret_key: api_secret_key)
        end

        def cancel!(orderId: nil, originalClientOrderId: nil, newClientOrderId: nil, recvWindow: nil, symbol: nil,
                    api_key: nil, api_secret_key: nil)
          raise Error.new(message: "symbol is required") if symbol.nil?
          raise Error.new(message: "either orderid or originalclientorderid " \
                          "is required") if orderId.nil? && originalClientOrderId.nil?
          timestamp = Configuration.timestamp
          params = { orderId: orderId, origClientOrderId: originalClientOrderId,
                     newClientOrderId: newClientOrderId, recvWindow: recvWindow,
                     symbol: symbol, timestamp: timestamp }.delete_if { |key, value| value.nil? }
          Request.send!(api_key_type: :trading, method: :delete, path: "/api/v3/order",
                        params: params, security_type: :trade, tld: Configuration.tld, api_key: api_key,
                        api_secret_key: api_secret_key)
        end

        def create!(icebergQuantity: nil, newClientOrderId: nil, newOrderResponseType: nil,
                    price: nil, quantity: nil, quoteOrderQty: nil, recvWindow: nil, stopPrice: nil, symbol: nil,
                    side: nil, type: nil, timeInForce: nil, test: false, api_key: nil, api_secret_key: nil)
          timestamp = Configuration.timestamp
          params = {
            icebergQty: icebergQuantity, newClientOrderId: newClientOrderId,
            newOrderRespType: newOrderResponseType, price: price, quantity: quantity, quoteOrderQty: quoteOrderQty,
            recvWindow: recvWindow, stopPrice: stopPrice, symbol: symbol, side: side,
            type: type, timeInForce: timeInForce, timestamp: timestamp,
          }.delete_if { |key, value| value.nil? }
          ensure_required_create_keys!(params: params)
          path = "/api/v3/order#{"/test" if test}"
          Request.send!(api_key_type: :trading, method: :post, path: path,
                        params: params, security_type: :trade, tld: Configuration.tld, api_key: api_key,
                        api_secret_key: api_secret_key)
        end

        def status!(orderId: nil, originalClientOrderId: nil, recvWindow: nil, symbol: nil,
                    api_key: nil, api_secret_key: nil)
          raise Error.new(message: "symbol is required") if symbol.nil?
          raise Error.new(message: "either orderid or originalclientorderid " \
                          "is required") if orderId.nil? && originalClientOrderId.nil?
          timestamp = Configuration.timestamp
          params = {
            orderId: orderId, origClientOrderId: originalClientOrderId, recvWindow: recvWindow,
            symbol: symbol, timestamp: timestamp,
          }.delete_if { |key, value| value.nil? }
          Request.send!(api_key_type: :trading, path: "/api/v3/order",
                        params: params, security_type: :user_data, tld: Configuration.tld, api_key: api_key,
                        api_secret_key: api_secret_key)
        end

        private

        def additional_required_create_keys(type:)
          case type
          when :limit
            [:price, :timeInForce].freeze
          when :stop_loss, :take_profit
            [:stopPrice].freeze
          when :stop_loss_limit, :take_profit_limit
            [:price, :stopPrice, :timeInForce].freeze
          when :limit_maker
            [:price].freeze
          else
            [].freeze
          end
        end

        def ensure_required_create_keys!(params:)
          keys = required_create_keys.dup.concat(additional_required_create_keys(type: params[:type]))
          missing_keys = keys.select { |key| params[key].nil? }
          raise Error.new(message: "required keys are missing: #{missing_keys.join(", ")}") unless missing_keys.empty?
        end

        def required_create_keys
          [:symbol, :side, :type, :timestamp].freeze
        end
      end
    end
  end
end
