# require_relative "utils/output_helper"

class Brandon
  # include OutputHelper
  attr_accessor :paths
  attr_accessor :root_dir, :tree_hash

  def initialize root_dir, tree_hash
    @root_dir = root_dir || "."
    @paths = []
    build_dir_structure tree_hash
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
  def build_dir_structure struct
    cycle_hsh struct, "#{root_dir}#{"/" if root_dir[-1] != "/" }"
    paths.map {|k| k.gsub(" ", "_")} # snake_caseize_all_names!
  end

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


module High
  # LVL 1
  class Reader
    # to get the yml location and read it
    # init parser and send it path_to_the_root_dir, tree_hash read from the yml
  end

  class Parser
    # to get the root dir and yml and build the queue of paths (dirs and file paths)
  end

  class Builder
    # get the paths queue and builds it all out
  end

  # LVL 2
  class Templater
    # opens the files and applies the appropriate templates

    # understands the meta tree structure
    # binds the appropriate variables
    # erbs the sht out of the templates :)
  end
end