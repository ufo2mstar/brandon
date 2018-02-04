# require_relative "utils/output_helper"
# require_relative "utils/err_helper"
require 'fileutils'

module Brandon
  NoPathsWarning = Class.new IOError
  OverwriteError = Class.new Interrupt


  # build procedure
  # @param [Object] tree_file the yml input that you want to build
  def self.build tree_file = nil
    foundation unless tree_file
    root_dir, file_name, file_ext = file_parse tree_file
    tree_hash = Reader.new tree_file
    paths = Parser.new root_dir, tree_hash
    bran = Builder.new paths
    bran.build
  end

  def self.foundation
    template_file = ""
    raise OverwriteError, "#{template_file} already exists! lets not overwrite it..", caller if File.exist? template_file
    # FileUtils.copy template_file, target_dir
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
    def initialize tree_file

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

    # Just checks to see if root directory already has a *bran* trace
    # @return [Nil]
    def check_if_overwriting loc
      raise OverwriteError, "#{loc} already exists! really want to overwrite it?", caller if File.exist? loc
    end

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
      raise(NoPathsWarning, "No parsed paths to build!") if paths.empty?
      check_if_overwriting paths[0]
      @paths = paths
      # build paths
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

    def make_dir(path_name)
      FileUtils::mkdir_p(path_name) # takes care of creating parents too, as needed
    end

    def make_file(path_name)
      FileUtils::touch(path_name) # file create hack, multi-platform support
      # fill_file(path_name)
    end
  end

  # LVL 2
  class Templater
    # opens the files and applies the appropriate templates

    # understands the meta tree structure
    # binds the appropriate variables
    # erbs the sht out of the templates :)
  end
end

# puts Brandon.file_parse "simple_test.yml"