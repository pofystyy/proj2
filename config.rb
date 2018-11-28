require 'yaml'

module Config
  def white_list
    YAML.load_file('white_list.yml')
  end
end
