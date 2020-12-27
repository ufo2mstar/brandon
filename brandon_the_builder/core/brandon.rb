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

module BrandonSubs
  def sub_names content_path, sub_names_hash
    res = content_path
    sub_names_hash.each { |from, to| res = res.gsub(from, to) }
    res
  end

  def sub_contents content_file_path, sub_contents_hash
    ERB.new(File.read(content_file_path)).result_with_hash sub_contents_hash
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
      subbed_source = sub_names @template_source, @template_map.names
      dest = source.gsub(subbed_source, dest_path)
      if File.directory? source
        ap "make_dir #{dest}"
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
    ap "make_file #{dest}"
    # make_file dest
    new_contents = sub_contents source, @template_map.contents
    ap new_contents
    # File.open(dest, 'w') { |f| f.puts new_contents }
  end

  def get_page_structure
    erb = ERB.new(File.read(BRANDON_TEMPLATE_MAPS)).result binding
    yp erb
    hsh = YAML.load erb.gsub("=>", ": ")
    # yp hsh
  end
end
