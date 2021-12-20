require_relative '../../../../../../ttk-containers/lib/ttk/containers/rspec/shared_quote_spec'

RSpec.describe TTK::ETrade::Containers::Quotes::Quote do
  let(:product_body) do
    {
      'securityType' => security_type,
      'symbol' => symbol,
      'callPut' => callput,
      'strikePrice' => strike,
      'expiryYear' => year,
      'expiryMonth' => month,
      'expiryDay' => day
    }
  end

  let(:symbol) { 'SPY' }
  let(:strike) { 0 }
  let(:callput) { '' }
  let(:security_type) { 'EQ' }
  let(:year) { 0 }
  let(:month) { 0 }
  let(:day) { 0 }

  let(:quote_timestamp) { Time.now }
  let(:quote_status) { :realtime }
  let(:ask) { 17.15 }
  let(:bid) { 17.11 }
  let(:last) { 17.12 }
  let(:volume) { 12 }

  describe '.choose_type' do
    context 'unknown response' do
      let(:response) do
        Class.new do
          def equity?
            false
          end

          def equity_option?
            false
          end
        end.new
      end

      it 'raises UnknownQuoteResponseType' do
        expect { described_class.choose_type(response) }.to raise_error(described_class::UnknownQuoteResponseType)
      end
    end
  end

  let(:response_instance) { TTK::ETrade::Market::Containers::Response.new(body: body) }

  subject(:container) { described_class.new(body: response_instance) }

  context 'equity' do
    let(:module_extension) do
      Module.new do
        def set(key, value)
          new_body = body.dup
          case key
          when :quote_timestamp then new_body['dateTimeUTC'] = value
          when :quote_status then new_body['quoteStatus'] = value
          when :ask then new_body['Intraday']['ask'] = value
          when :bid then new_body['Intraday']['bid'] = value
          when :last then new_body['Intraday']['lastTrade'] = value
          when :volume then new_body['Intraday']['totalVolume'] = value
          when :dte then nil
          when :open_interest then nil
          when :intrinsic then nil
          when :extrinsic then nil
          when :rho then nil
          when :theta then nil
          when :vega then nil
          when :gamma then nil
          when :delta then nil
          when :iv then nil
          when :multiplier then nil
          else raise "Should never get here: #{key}"
          end

          # return new object
          TTK::ETrade::Market::Containers::Response.new(body: new_body)
        end
      end
    end
    let(:dte) { 1 }
    let(:open_interest) { 1 }
    let(:intrinsic) { 1.0 }
    let(:extrinsic) { 1.0 }
    let(:rho) { 1.0 }
    let(:vega) { 1.0 }
    let(:theta) { 1.0 }
    let(:delta) { 1.0 }
    let(:gamma) { 1.0 }
    let(:iv) { 1.0 }
    let(:multiplier) { 100 }

    let(:body) do
      {
        'dateTimeUTC' => quote_timestamp,
        'quoteStatus' => quote_status,
        'Intraday' =>
          { 'ask' => ask,
            'bid' => bid,
            'lastTrade' => last,
            'totalVolume' => volume
          },
        'Product' =>
          { 'symbol' => symbol,
            'securityType' => security_type,
            'callPut' => callput,
            'expiryYear' => year,
            'expiryMonth' => month,
            'expiryDay' => day,
            'strikePrice' => strike
          }
      }
    end

    describe 'creation' do
      it 'returns a quote instance' do
        expect(container).to be_instance_of(described_class)
      end

      include_examples 'quote interface - required methods', TTK::Containers::Quote
    end

    describe 'basic interface' do
      # quote_timestamp, quote_status, ask, bid, last, and volume must be defined for this to work
      include_examples 'quote interface - methods equity'
    end

    describe '#update_quote' do
      before do
        # add a feature to allow for updates during test
        response_instance.extend(module_extension)
      end

      let(:update_object) do
        response_instance
      end

      include_examples 'quote interface - update equity'
    end
  end

  context 'equity option' do
    let(:module_extension) do
      Module.new do
        def set(key, value)
          new_body = body.dup
          case key
          when :quote_timestamp then new_body['dateTimeUTC'] = value
          when :quote_status then new_body['quoteStatus'] = value
          when :ask then new_body['Option']['ask'] = value
          when :bid then new_body['Option']['bid'] = value
          when :last then new_body['Option']['lastTrade'] = value
          when :volume then new_body['Option']['totalVolume'] = value
          when :dte then new_body['Option']['daysToExpiration'] = value
          when :open_interest then new_body['Option']['openInterest'] = value
          when :intrinsic then new_body['Option']['intrinsicValue'] = value
          when :extrinsic then new_body['Option']['timePremium'] = value
          when :rho then new_body['Option']['OptionGreeks']['rho'] = value
          when :theta then new_body['Option']['OptionGreeks']['theta'] = value
          when :vega then new_body['Option']['OptionGreeks']['vega'] = value
          when :gamma then new_body['Option']['OptionGreeks']['gamma'] = value
          when :delta then new_body['Option']['OptionGreeks']['delta'] = value
          when :iv then new_body['Option']['OptionGreeks']['iv'] = value
          when :multiplier then nil
          else raise "Should never get here: #{key}"
          end

          # return new object
          TTK::ETrade::Market::Containers::Response.new(body: new_body)
        end
      end
    end
    let(:strike) { 50 }
    let(:callput) { 'CALL' }
    let(:security_type) { 'OPTN' }
    let(:year) { 2021 }
    let(:month) { 12 }
    let(:day) { 11 }

    let(:dte) { 14 }
    let(:open_interest) { 4 }
    let(:intrinsic) { 1.23 }
    let(:extrinsic) { 0.45 }
    let(:rho) { 0.0 }
    let(:vega) { 1.2 }
    let(:theta) { -1.4 }
    let(:delta) { 0.5 }
    let(:gamma) { 0.02 }
    let(:iv) { 0.145 }
    let(:multiplier) { 100 }

    let(:body) do
      {
        'dateTimeUTC' => quote_timestamp,
        'quoteStatus' => quote_status,
        'Option' =>
          { 'ask' => ask,
            'bid' => bid,
            'lastTrade' => last,
            'totalVolume' => volume,
            'daysToExpiration' => dte,
            'openInterest' => open_interest,
            'intrinsicValue' => intrinsic,
            'timePremium' => extrinsic,
            'optionMultiplier' => multiplier,
            'OptionGreeks' =>
              { 'rho' => rho,
                'vega' => vega,
                'theta' => theta,
                'delta' => delta,
                'gamma' => gamma,
                'iv' => iv,
                'currentValue' => false
              }
          },
        'Product' =>
          { 'symbol' => symbol,
            'securityType' => security_type,
            'callPut' => callput,
            'expiryYear' => year,
            'expiryMonth' => month,
            'expiryDay' => day,
            'strikePrice' => strike
          }
      }
    end

    describe 'creation' do
      it 'returns a quote instance' do
        expect(container).to be_instance_of(described_class)
      end

      include_examples 'quote interface - required methods', TTK::Containers::Quote
    end

    describe 'basic interface' do
      # quote_timestamp, quote_status, ask, bid, last, and volume must be defined for this to work
      # also needs the various option vars
      include_examples 'quote interface - methods equity_option'
    end

    describe '#update_quote' do
      before do
        # add a feature to allow for updates during test
        response_instance.extend(module_extension)
      end

      let(:update_object) do
        response_instance
      end

      include_examples 'quote interface - update equity_option'
    end
  end
end
