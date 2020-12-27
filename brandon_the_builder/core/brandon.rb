require 'ap'
require 'yaml'

class BrandonBuilder

  BRANDON_TEMPLATE_MAPS = 'brandon_maps.yml'
  def initialize(template_root_path)
    @template_root = template_root_path
    @template_map = read_brandon_map(template_root_path)
  end

  def create
    ap @template_root
    ap @template_map
  end

  private
  def read_brandon_map(template_root_path)
    yaml_map = File.read(File.join(template_root_path,BRANDON_TEMPLATE_MAPS))
    YAML.load(yaml_map)
  end

  def get_page_structure
    erb = ERB.new(File.read(BRANDON_TEMPLATE_MAPS)).result binding
    yp erb
    hsh = YAML.load erb.gsub("=>", ": ")
    # yp hsh
  end
end
