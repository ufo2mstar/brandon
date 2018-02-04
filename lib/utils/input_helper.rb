require 'yaml'
require 'erb'

module YamlHelper
  def yaml_load io
    YAML.load(io.gsub("=>", ": "))
  end

  def read input_file, specific_binding = binding
    erb = ERB.new(File.read(input_file)).result specific_binding
    # yp erb
    hsh = YAML.load erb.gsub("=>", ": ")
    # yp hsh
  end

  def kod path_name
    File.open(path_name, 'w') {|f| f.puts ERB.new(File.read(Dir.glob("./**/#{matches.first}.erb")[0])).result(binding)}
  end
end