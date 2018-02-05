# require_relative "utils/output_helper"
# require_relative "utils/err_helper"
require 'fileutils'
require 'find'
require_relative 'utils/input_helper'

module Brandon
  NoPathsWarning = Class.new IOError
  FileNotFoundError = Class.new IOError
  OverwriteError = Class.new Interrupt


  # build procedure
  # @param [Object] tree_file the yml input that you want to build
  def self.build tree_file #= "." # get current executing directory
    # setup
    curr_dir, file_name, file_ext = file_parse tree_file
    foundation(curr_dir) unless tree_file
    root_dir = "#{curr_dir}/#{file_name}/"

    # read in file
    reader = Reader.new tree_file
    tree_hash = reader.hsh

    # parse paths
    parser = Parser.new root_dir, tree_hash
    paths = parser.paths
    paths.unshift root_dir

    # build tree structure
    bran = Builder.new paths
    bran.build
  end

  def self.read root_dir
    raise FileNotFoundError, "Sorry, can't find #{root_dir}", caller unless File.exist? root_dir
    file_name = "#{root_dir}.yml".gsub("//", '')
    raise OverwriteError, "#{file_name} already exists! lets not overwrite it..", caller if File.exist? file_name

    hsh = {}
    strip_dir=-> str {str.gsub(/#{root_dir}\//, '')}

    Find.find("#{root_dir}/").map {|path|
      puts(strip_dir[File.file?(path) ? path : "#{path}/"])
    # todo: hash logic
    }

    # puts directory_hash(root_dir).to_yaml

    hsh = {kod: {hai: [1, "234.txt", :dd]}, "hmm" => "kod.txt"}
    puts hsh.to_yaml
    # File.open(file_name, 'w') {|f| f.puts hsh.to_yaml}
  end
  #
  # def self.directory_hash(path, name=nil)
  #   data = {:data => (name || path)}
  #   hsh ||= {}
  #   hsh[name||path] ||=[]
  #   # children = hsh[path]
  #   Dir.foreach(path) do |entry|
  #     next if (entry == '..' || entry == '.')
  #     full_path = File.join(path, entry)
  #     if File.directory?(full_path)
  #       hsh[name] << directory_hash(full_path, entry)
  #     else
  #       hsh[name] << entry
  #     end
  #   end
  #   # return data
  #   return hsh
  # end

  def self.foundation curr_dir = "."
    template_file = "#{curr_dir}/sample_template.yml"
    raise OverwriteError, "#{template_file} already exists! lets not overwrite it..", caller if File.exist? template_file
    str = <<-eos
one:
  two:
    - :one
    - 'two'
    - "three.txt"
    - 4
    - five.js
    - Object:
      - more
      - 'stuff'
  three:
  four: "kod.rb"
"Two":
    eos
    File.open(template_file, 'w') {|f| f.puts str}
  end

  def self.file_parse(tree_file)
    file_ext = File.extname(tree_file)
    file_name = File.basename(tree_file, ".*")
    # dir_path = File.realdirpath(tree_file)
    # dir_path = File.realpath(tree_file)
    # dir_path = File.dirname(File.realdirpath(tree_file))
    dir_path = File.dirname(tree_file)
    # dir_path = File.absolute_path(tree_file)
    [dir_path, file_name, file_ext]
  end

  # LVL 1
  # to get the yml location and read it
  # init parser and send it path_to_the_root_dir, tree_hash read from the yml
  class Reader
    include YamlHelper
    attr_accessor :hsh

    def initialize tree_file
      raise FileNotFoundError, "Sorry, can't find #{tree_file}", caller unless File.exist? tree_file
      read_yml tree_file
    end

    def read_yml(tree_file)
      @hsh = read tree_file
      @hsh = {} unless hsh
    end

  end

  # to get the root dir and yml and build the queue of paths (dirs and file paths)
  class Parser
    attr_accessor :paths
    attr_accessor :root_dir, :tree_hash

    # Takes in the _root directory_, *understands* the tree structure, and checks if path is about to be overwritten
    # @param [String] root_dir where bran builds
    # @param [Hash] tree_hash expected dir structure
    def initialize root_dir, tree_hash
      @root_dir = root_dir || "."
      @paths = []
      build_dir_structure tree_hash
    end

    private

    # Starts the Breadth-First'ish traversal into the tree
    # @param [Hash] struct the tree hash that you want to build
    # @return [Hash] paths queue ready to be created
    def build_dir_structure struct
      cycle_hsh struct, "#{root_dir}#{"/" if root_dir[-1] != "/" }" # down the stack we go!
      # paths.map {|k| k.gsub(" ", "_")} # snake_caseize_all_names!
      paths
    end

    # @param [Hash] hsh hash from tree to cycle through
    # @param [String] location location wrt root
    # @return [Nil] but adds to paths attribute directly
    def cycle_hsh hsh, location
      hsh.each {|k, v|
        loc = "#{location}#{k}/" #making it a dir
        paths << loc
        cls=v.class.to_s
        if cls == "Hash"
          cycle_hsh v, loc
        elsif cls == "Array"
          cycle_ary v, loc
        else
          cycle_other v, loc
        end
      }
    end

    # @param [Array] ary array from tree to cycle through
    # @param [String] loc location wrt root
    # @return [Nil] but adds to paths attribute directly
    def cycle_ary ary, loc
      ary.each {|itm|
        case itm.class.to_s
          when "Array" then
            cycle_ary itm, loc
          when "Hash" then
            cycle_hsh itm, loc
          else
            cycle_other itm, loc
        end
      }
    end

    # Stringifies any Object and adds non-empty strings to the +paths+ queue
    # @param [Object] itm tree to cycle through
    # @param [String] loc location wrt root
    # @return [Nil] but adds to paths attribute directly
    def cycle_other itm, loc
      # if itm.class == String and !itm.strip.empty?
      # supporting any non-blank types!
      itm = itm.to_s
      if !itm.strip.empty?
        paths << loc+itm # making the file
      else
        # skip if Nil or blank string!
      end
    end

  end
  #
  #

  class Builder
    attr_accessor :paths
    # get the paths queue and builds it all out
    # @param [Array<Paths>] paths dirs and files to be created
    def initialize paths
      raise(NoPathsWarning, "No parsed paths to build!") if paths.nil? or paths.empty?
      check_if_overwriting paths[0]
      @paths = paths
      # build
    end

    def build
      # yp @paths
      dirs =[]; files=[]
      paths.each {|itm| (itm[-1] == "/" ? dirs : files) << itm}
      # yp @dirs; yp @files
      dirs.each {|itm| make_dir itm}
      files.each {|itm| make_file itm}
      paths
    end

    private

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

  # LVL 2
  # TODO: implement this generic yml controlled templater
  class Templater
    # opens the files and applies the appropriate templates

    # understands the meta tree structure
    # binds the appropriate variables
    # erbs the sht out of the templates :)
  end
end

# puts Brandon.file_parse "simple_test.yml"

# Brandon.build "./iqhd.yml"
Brandon.read "./iqh"