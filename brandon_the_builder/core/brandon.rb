require 'ap'
require 'yaml'

class BrandonBuilder
  attr_accessor :template_map

  BRANDON_TEMPLATE_MAPS = 'brandon_maps.yml'

  def initialize(template_root_path, template_maps_file = BRANDON_TEMPLATE_MAPS)
    @template_root = template_root_path
    @template_map = read_brandon_map(template_root_path, template_maps_file)
  end

  def create
    ap @template_root
    ap @template_map
  end

  private
  def read_brandon_map(template_root_path, template_maps_file)
    yaml_map = File.read(File.join(template_root_path, template_maps_file))
    YAML.load(yaml_map)
  end

  def get_page_structure
    erb = ERB.new(File.read(BRANDON_TEMPLATE_MAPS)).result binding
    yp erb
    hsh = YAML.load erb.gsub("=>", ": ")
    # yp hsh
  end
end
