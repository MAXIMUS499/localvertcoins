module ExchangeRateService extend self

  CURRENCY_DATA = YAML.load_file(
    Rails.root.join('config', 'currencies.yml')
  ).with_indifferent_access.freeze
  CURRENCIES = CURRENCY_DATA.keys.freeze
  CACHE_TIMEOUT = 15.minutes.freeze

  def current_price(currency='usd')
    external_data[currency]
  end

  def fetch_external_data
    data = {}

    currencies = CURRENCIES.map { |currency| currency.upcase }.join(',')
    external_data = JSON.parse connection.get("/data/price?fsym=VTC&tsyms=#{currencies}").body

    CURRENCIES.each do |currency|
      data[currency] = external_data[currency.upcase].to_f.round(4)
    end

    data['updated_at'] = Time.now
    set_cache(data)
    data
  end

  private

  def external_data
    cache = get_cache
    return cache if cache.present?
    fetch_external_data
  end

  def cache_valid?(cache)
    cache.present? and cache['updated_at'] > Time.now - CACHE_TIMEOUT
  end

  def get_cache
    cache = $redis.get(:exchange_rate)
    cache = JSON.parse(cache) if cache.present?
    cache
  end

  def set_cache(data)
    $redis.set(:exchange_rate, data.to_json)
  end

  def connection
    Faraday.new(url: 'https://min-api.cryptocompare.com')
  end
end
