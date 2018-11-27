module WhiteListValidator

  def valid_data?
    methods_for_comparison.size == comparative_keys.size
  end

  def host_data
    host = @env["HTTP_HOST"]

    white_list[host] if white_list.keys.include?(host)
  end

  def allowable_values
    path = @env["PATH_INFO"].split("/")
    meth = @env["REQUEST_METHOD"].split

    { 'target' => path,
      'method' => meth
     }
  end

  def comparative_keys
    host_data[0].keys & allowable_values.keys
  end

  def methods_for_comparison
    comparative_keys.map do |method|
      allowable_values[method] & array(method)
    end.delete_if {|el| el.empty? }
  end

  def array(method)
    host_data[0][method].class == Array ? host_data[0][method] : host_data[0][method].split
  end
end
