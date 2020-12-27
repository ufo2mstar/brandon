require 'ap'
require 'yaml'

module BrandonSupport
  OverwriteError = Class.new Interrupt

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
    #todo: will improve hack which might potentially overwrite a sub-matching pattern ie: PATTERN overwrites PATTERN_NEW
    sub_names_hash.each { |from, to| res = res.gsub(from, to) }
    res
  end

  def sub_contents file_content, sub_contents_hash
    ERB.new(file_content).result_with_hash sub_contents_hash
  end
end

class BrandonBuilder
  attr_accessor :template_map, :dir_map
  include BrandonSupport
  include BrandonSubs

  BRANDON_TEMPLATE_MAPS = 'brandon_maps.yml'
  NAMES = 'names'
  CONTENTS = 'contents'

  def initialize(template_source_path, template_maps_file = BRANDON_TEMPLATE_MAPS)
    @template_source = template_source_path
    @template_map = read_brandon_map(template_source_path, template_maps_file)
    @dir_map = Dir["#{template_source_path}/**/*"].reject { |f| f =~ /#{BRANDON_TEMPLATE_MAPS}/ }
  end

  def create(dest_path)
    source_dir = File.dirname(@template_source)

    # create base dest path
    dest_unsubbed = @template_source.gsub(source_dir, '')
    subbed_source = sub_names dest_unsubbed, @template_map[NAMES]
    dest = File.join(dest_path, subbed_source)
    make_dir dest

    @dir_map.each do |source|
      dest_unsubbed = source.gsub(source_dir, '')
      subbed_source = sub_names dest_unsubbed, @template_map[NAMES]
      dest = File.join(dest_path, subbed_source)
      if File.directory? source
        # ap "make_dir #{dest}"
        check_if_overwriting(dest)
        make_dir dest
      else # File.file? path
        # ap "fill_file #{dest}, #{source}"
        fill_file dest, source
      end
    end
    ap "done writing to #{dest_path}"
  end

  private
  def read_brandon_map(template_root_path, template_maps_file)
    yaml_map = File.read(File.join(template_root_path, template_maps_file))
    YAML.load(yaml_map)
  end

  def fill_file dest, source
    ext = File.extname(source)
    dest = ext =~ /.erb$/ ? dest.gsub(/\.erb$/, '') : dest
    make_file dest
    file_content = File.read(source)
    new_contents = ext == '.erb' ? sub_contents(file_content, @template_map[CONTENTS]) : file_content
    # ap new_contents
    File.open(dest, 'w') { |f| f.puts new_contents }
  end

  def get_page_structure
    erb = ERB.new(File.read(BRANDON_TEMPLATE_MAPS)).result binding
    yp erb
    hsh = YAML.load erb.gsub('=>', ': ')
    # yp hsh
  end
end
