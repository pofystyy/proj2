class WhiteListValidator
  attr_reader :host, :path, :http_method

  def initialize(host:, path:, http_method:)
    @white_list = Config.new.white_list
    @host = host
    @path = path
    @http_method = http_method
  end

  def host_in_white_list?
    @white_list.keys.include?(host)
  end

  def host_valid?
    host_values.size == coincidence.size
  end

  private

  def host_values
    host_data.values.map { |value| value.is_a?(Array) ? value : value.split }
  end

  def host_data
    @white_list.dig(host, 0)
  end

  def coincidence
    data_for_check.map.with_index { |arr, index| arr & host_values[index]}.reject(&:empty?)
  end

  def data_for_check
    keys_for_check.map{|key| env_data[key]}
  end

  def keys_for_check
    host_data.keys & env_data.keys
  end

  def env_data
    {
      'target' => path,
      'method' => [http_method]
     }
  end
end
