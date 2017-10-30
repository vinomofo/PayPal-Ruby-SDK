require "braintreehttp"

module PayPal
  class PayPalHttpClient < BraintreeHttp::HttpClient

    attr_accessor :refresh_token

    def initialize(environment, refresh_token=nil)
      super(environment)
      @refresh_token = refresh_token

      add_injector(&method(:_sign_request))
      add_injector(&method(:_add_headers))
    end

    def _sign_request(request)
      if (!_is_auth_request(request))
        if (!@access_token || @access_token.isExpired)
          accessTokenRequest = PayPal::AccessTokenRequest.new(@environment, @refresh_token)
          tokenResponse = execute(accessTokenRequest)
          @access_token = PayPal::AccessToken.new(tokenResponse.result)
        end
        request.headers["Authorization"] = @access_token.authorizationString()
      end
    end

    def _add_headers(request)
      request.headers["Accept-Encoding"] = "gzip"
    end

    def _is_auth_request(request)
      request.instance_of?(PayPal::AccessTokenRequest) ||
        request.instance_of?(PayPal::RefreshTokenRequest)
    end
  end
end
