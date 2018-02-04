# require_relative "utils/output_helper"

class Brandon
  # include OutputHelper
  attr_accessor :paths
  attr_accessor :root_dir, :tree_hash

  def initialize root_dir, tree_hash
    @root_dir = root_dir
    @paths = []
    build_dir_structure tree_hash
  end

  def build
    # yp @paths
    dirs =[]; files=[]
    @paths.each {|itm| (itm[-1] == "/" ? dirs : files) << itm}
    # yp @dirs; yp @files
    dirs.each {|itm| make_dir itm}
    files.each {|itm| make_file itm}
    # @paths
  end

  private
  def build_dir_structure struct
    cycle_hsh struct, "#{root_dir}/"
    @paths.map {|k| k.gsub(" ", "_")} # snake_caseize_all_names!
  end

  def cycle_hsh hsh, location
    hsh.each {|k, v|
      loc = "#{location}#{k}/"
      @paths << loc
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
          @paths << loc+itm
      end
    }
  end

  def cycle_other itm, loc
    if itm.class == String and itm.size > 0
      @paths << loc+itm
    else
      # skip if Nil or blank string!
    end
  end


end