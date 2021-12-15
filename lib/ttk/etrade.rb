require 'async'
require "async/limiter/window/sliding"

module TTK
  module ETrade

    class Config
    end

    module Containers
    end

    module Core
    end

    module Errors
    end

    module Options
    end

    module Orders
      module Containers
        module Generators
        end
      end
    end

    module Portfolio
      module Containers
        module Response
        end
      end
    end

    module Session
      module Orders
      end
      module Portfolio
      end
    end

  end
end

#gems
#
require 'tzinfo'
Eastern_TZ = TZInfo::Timezone.get('US/Eastern')
Central_TZ = TZInfo::Timezone.get('US/Central')

# local files
require_relative 'etrade/config/config'
require_relative 'etrade/config/accounts'
require_relative 'etrade/config/balances'
require_relative 'etrade/config/login'
require_relative 'etrade/config/positions'
require_relative 'etrade/config/orders'

require_relative 'etrade/errors/session'
require_relative 'etrade/errors/errors'

require_relative 'etrade/core/session'
require_relative 'etrade/core/session/result'
require_relative 'etrade/core/quotes'
require_relative 'etrade/core/quote'
require_relative 'etrade/core/subscriber' # define before order & position
require_relative 'etrade/core/login'
require_relative 'etrade/core/balances'
require_relative 'etrade/core/accounts'
require_relative 'etrade/core/account'
# require_relative 'etrade/core/product'
require_relative 'etrade/containers/product/product'

require_relative 'etrade/session/base'
require_relative 'etrade/session/result'
require_relative 'etrade/session/option_chains'
require_relative 'etrade/session/option_expirations'
require_relative 'etrade/session/orders/base'
require_relative 'etrade/session/orders/cancel'
require_relative 'etrade/session/orders/preview'
require_relative 'etrade/session/orders/preview_change'
require_relative 'etrade/session/orders/place'
require_relative 'etrade/session/orders/place_change'
require_relative 'etrade/session/orders/list'
require_relative 'etrade/session/orders/load'
require_relative 'etrade/session/portfolio/list'

require_relative 'etrade/market/chain'
require_relative 'etrade/market/option_expirations'
require_relative 'etrade/market/chains'

require_relative 'etrade/orders/containers/shared'
require_relative 'etrade/orders/containers/generators'
require_relative 'etrade/orders/containers/new_order'
require_relative 'etrade/orders/containers/existing'
require_relative 'etrade/orders/containers/response'

require_relative 'etrade/portfolio/containers/response'

require_relative 'etrade/orders/interface'
require_relative 'etrade/portfolio/interface'
