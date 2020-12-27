require 'ap'
require 'yaml'

module BrandonSupport
  # Just checks to see if root directory already has a *bran* trace
  # @return [Nil]
  def check_if_overwriting loc
    raise OverwriteError, "#{loc} already exists! really want to overwrite it?", caller if File.exist? loc
  end

  def make_dir(path_name)
    FileUtils::mkdir_p(path_name) # takes care of creating parents too, as needed
  end

  def make_file(path_name)
    FileUtils::touch(path_name) # file create hack, multi-platform support
    # fill_file(path_name)
  end
end

class BrandonBuilder
  attr_accessor :template_map, :dir_map
  include BrandonSupport

  BRANDON_TEMPLATE_MAPS = 'brandon_maps.yml'

  def initialize(template_source_path, template_maps_file = BRANDON_TEMPLATE_MAPS)
    @template_source = template_source_path
    @template_map = read_brandon_map(template_source_path, template_maps_file)
    @dir_map = Dir["#{template_source_path}/**/*"]
  end

  def create(dest_path)
    ap dest_path
    @dir_map.each do |source|
      dest = source.gsub(@template_source, dest_path)
      if File.directory? source
        ap dest
        # make_dir dest
      else # File.file? path
        ap "fill_file #{dest}, #{source}"
        fill_file dest, source
      end
    end
    ap 'done'
  end

  private
  def read_brandon_map(template_root_path, template_maps_file)
    yaml_map = File.read(File.join(template_root_path, template_maps_file))
    YAML.load(yaml_map)
  end

  def fill_file dest, source

  end

  def get_page_structure
    erb = ERB.new(File.read(BRANDON_TEMPLATE_MAPS)).result binding
    yp erb
    hsh = YAML.load erb.gsub("=>", ": ")
    # yp hsh
  end
end
