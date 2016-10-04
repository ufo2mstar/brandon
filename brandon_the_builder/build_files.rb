# TIMING (to help Profiling)
# Thanks MatLab! :)
def tic
  $tic=Time.now
  print "TIC initiated -->\n"
end

def toc
  $toc=Time.now
  print "Elapsed time : #{$toc-$tic}\n"
  p $toc-$tic #watch out
end

def yp(obj)
  print obj.to_yaml
end

def yaml_load io
  YAML.load(io.gsub("=>", ": "))
end

class String
  def squash
    self.gsub(/\s+/, " ")
  end

  def trim
    self.gsub('_', ' ').strip
  end

  def titilecase
    self.trim.split(' ').map { |w| w.capitalize }.join(' ')
  end

  def camelcase
    self.trim.downcase.titilecase.gsub(/\s+/, '')
  end

  def snakecase
    self.trim.gsub(' ', '_').downcase
  end

  alias_method :downsnakecase, :snakecase

  def upsnakecase
    self.trim.gsub(' ', '_').upcase
  end
end
# ----------------------------------------------------------------------------

require 'fileutils'
require 'yaml'
require 'erb'
$plates = YAML.load_file 'temp_lordFrey.yml'

class BuildStruct
  # todo.. get the friggin template name!
  # todo.. also, hashize input so that it reads well!!
  def initialize(app_root_path, page_stuff, states = ['oh'])
    @app_root       = app_root_path
    # accept page name array ["pni","prop_info"]
    @page_names     = page_stuff.class.to_s == "Array" ? page_stuff : page_stuff.keys

    # create states ymls from states = ["oh","IL"]
    # todo : take this kinda hardcoded things and make them just a block that can be passed to the class.new call!
    @inp_state_list = []; @exp_state_list=['exp_common']; @states_list=['_common'] # for common stuff
    @inp_state_list = []; @exp_state_list=[]; @states_list=[] # for common stuff
    (states).each { |st|
      # st.upcase!
    @states_list << st
    @inp_state_list << "#{st}.yml"
    @exp_state_list << "exp_#{st}.yml"
    # @exp_state_list << "_#{st}_claims_east.yml"
    }

    @camel_file_name = @snake_file_name = "" #assigned on the #fill_file

    @page_names.each_with_index { |page_name, idx|
      @struct        = {}
      # @app_name      = app_root_path[/\/(.*)?$/, 1].capitalize
      @app_name      = "Property"
      noed_page_name = "#{'%02d_' % (idx+1) if @page_names.size>1}#{page_name}" # make ["pni"] => "00_pni"
      # page_name_abbr = "#{'%02d_' % idx if @page_names.size>1}#{page_name}" # make ["pni"] => "00_pni"
      @exp_base = page_stuff[page_name]["exp"] rescue nil
      @inp_base = page_stuff[page_name]["inp"] rescue nil
      @short_page_name        = (page_stuff[page_name] || page_name) rescue page_name
      @page_name              = page_name
      @bin                    = binding
      # @struct.merge(get_page_structure) todo figure this hell out! is it the pointers thing messing up?
      @struct[noed_page_name] = get_page_structure.values.first
      @paths                  =[] # assigning below
      build_dir_structure @struct
    }
  end

  def make_dir(path_name)
    FileUtils::mkdir_p(path_name) #unless File.exists?(path_name) i hope mkdir takes care??
  end

  def make_file(path_name)
    FileUtils::touch(path_name) #unless File.exists?(path_name) coz touch takes care of this
    fill_file(path_name)
  end

  # templater
  def fill_file(path_name)
    just_page_name = path_name[/\\|\/(\w+)\.\w+/, 1]; matches = []
    page_name = path_name; matches = []
    @snake_file_name = just_page_name.snakecase
    @camel_file_name = just_page_name.camelcase
    $plates.each { |k, v| matches << k if page_name =~ /#{v}/i }
    unless matches.empty?
      # raise "Multiple Matches!\n#{matches.to_yaml}" if matches.size > 1
      p "Multiple Matches!\n#{matches.to_yaml}\n using (#{matches = [matches.first]})" if matches.size > 1
      File.open(path_name, 'w') { |f| f.puts ERB.new(File.read(Dir.glob("./**/#{matches.first}.erb")[0])).result(binding) }
    end
  end

  def get_page_structure
    erb = ERB.new(File.read('structure_template.yml')).result @bin
    # yp erb
    hsh = YAML.load erb.gsub("=>", ": ")
    # yp hsh
  end

  def build_dir_structure struct
    cycle_hsh struct, "#{@app_root}/"
    @paths.map { |k| k.gsub(" ", "_") } # snake_caseize_all_names!
    # yp @paths
    dirs =[]; files=[]
    @paths.each { |itm| (itm[-1] == "/" ? dirs : files) << itm }
    # yp @dirs; yp @files
    dirs.each { |itm| make_dir itm }; files.each { |itm| make_file itm }
  end

  private
  def cycle_hsh hsh, location
    hsh.each { |k, v|
      loc = "#{location}#{k}/"
      @paths << loc
      cls=v.class.to_s
      if cls == "Array"
        cycle_ary v, loc
        # warn very interesting.. my code coverage check thinks this is not impt!
        # elsif cls == "Hash"
        #   cycle_hsh v, loc
      end
    }
  end

  def cycle_ary ary, loc
    ary.each { |itm|
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

end

tic
# # p app_path = File.dirname(__FILE__) #+"/.."
# # app_name = "property/homeowners_east"
# # app_path = File.dirname(__FILE__) +"/../features/pages/property/#{app_name}"
#
# app_name = "homeowners_east"
# # app_struct= yaml_load ERB.new(File.read("#{app_name}.yml")).result binding
# app_path = "./#{app_name}"
# # yp a

# a = BuildStruct.new app_path, %w(pni prop_info) , %w{oh il ny}
# a = BuildStruct.new app_path, %w(pni prop_info gen_info verify_info quote softfall hardfall), %w{TX TN PA NY VA AL CT GA IL MD OH KY MS NC SC WV DE AR DC ME NH RI VT}
# a = BuildStruct.new app_path, %w(gen_info verify_info quote softfall hardfall), %w{TX TN PA NY VA AL CT GA IL MD OH KY MS NC SC WV DE AR DC ME NH RI VT}
# a = BuildStruct.new app_path, app_struct, %w{TX TN PA NY VA AL CT GA IL MD OH KY MS NC SC WV DE AR DC ME NH RI VT}

# test = BuildStruct.new app_path, {pni: nil, prop_info: nil}, %w{TX TN PA NY OH}
# test = BuildStruct.new app_path, %w(pni prop_info), %w{TX TN PA NY OH}
# test = BuildStruct.new app_path, %w(regression)

# regr = BuildStruct.new '.', %w(Regression_RQB), %w[AL CT DC DE IL IN KY MD ME MI NC NH NY OH PA RI SC TN TX VA VT WV] # GA MS
# regr = BuildStruct.new '.', %w(reg), %w[AR GA MS CA IN OH] # GA MS
# regr = BuildStruct.new '.', %w(reg), %w[OH CT TN ME IL AL DC NH RI PA NY WV DE VT SC TX NC KY MD MI VA] # GA MS
# regr = BuildStruct.new '.', %w(MortgageInformationPage), %w[common renters homeowners condo]
# regr = BuildStruct.new '.', %w(PaymentMethodPage), %w[common renters homeowners condo]

regr = BuildStruct.new '.', %w(pipelines_app)
# todo : maybe even templatize the $#!T out of all the classes.. once its standardized enough!
# app_name  = "auto"
# app_struct= yaml_load ERB.new(File.read("#{app_name}_try.yml")).result binding
# app_path  = "./#{app_name}"
# test      = BuildStruct.new app_path, app_struct, %w{OH CO OR MO}
toc

# app_name  = "renters_east"
# app_struct= yaml_load ERB.new(File.read("#{app_name}.yml")).result binding
# app_path  = "./#{app_name}"
# a         = BuildStruct.new app_path, app_struct, %w{IN GA MS AR}