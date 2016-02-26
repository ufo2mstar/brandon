require 'yaml'
# require_relative 'debug_mate'

# Namespace for classes and methods that handle +format+ting string outputs and +such+
module FormatMate

# Split and return as ARY ',' separated string values
#   or split_by=/./ separated values
  def parse_to_a(str, split_by=nil)
    str ? str.split(split_by || ',').map(&:strip) : []
  end

  def get_ary_of(str, split_by=nil)
    parse_to_a str, ';'
  end

  # todo update documentation
  def log(str) #todo: remove this method??
    p "#{str}" if verbose_mode
  end

  # == DRAW_PADDED_LINE in a bunch of ways!
  #   draw_padded_line(String [, pattern_to_repeat])
  #   draw_padded_line(String [, pattern_to_repeat [, no_of_repeatition]])
  #   draw_padded_line(String [, pattern_to_repeat [, alignment_side_of_pattern [, no_of_repeatition]])
  #
  # @overload draw_padded_line(String) -> String
  #   @return [String] formatted beautified string for printing
  #   @param text [String] which is the Actual info to print on the screen
  #
  # @overload draw_padded_line(String, Array) -> String
  #   @return [String] formatted beautified string for printing, with more Bells and Whistles!
  #   @param text [String] which is the Actual info to print on the screen
  #   @param args [Array] text which is the Actual info to print on the screen - Order don't matta!
  #     - :Symbol Text orientation - :l = left,- :c = centered,- :r = right
  #     - :String Special print characters (like '-' or '-+' and so on..)
  #     - :Integer number of special characters you want to stitch together
  #   @option arg [Array<String,Symbol,Integer>] :Symbol Text orientation - :l = left,- :c = centered,- :r = right
  #   @option arg [Array<String,Symbol,Integer>] :String Special print characters (like '-' or '-+' and so on..)
  #   @option arg [Array<String,Symbol,Integer>] :Integer number of special characters you want to stitch together
  #
  #   @example Default format >> draw_padded_line(String, ['\-', :c, 50])
  #     bar = 42
  #     print draw_padded_line("foo #{bar}", ['=^', 4 ,:c])
  #     #=> =^=^=^=^ foo 42 =^=^=^=^
  #
  #     print draw_padded_line("foo #{bar}", [15, :r])
  #     #=> foo 42 ===============
  def draw_padded_line(text, args=['-', :c, 50]) #just for example
    style_1     = args.select { |a| a.is_a? String }.first || '-'
    style_2     = args.select { |a| a.is_a? String }.last || style_1
    side        = args.select { |a| a.is_a? Symbol }.first || :c
    repeatition = args.select { |a| a.is_a? Fixnum }.first || 50
    "\n#{style_1*repeatition if side!=:r} #{text} #{style_2*repeatition if side!=:l}\n"
  end

  def yp(obj, color=nil) # yaml print : yp
    p(obj.to_yaml, color ? color.to_sym : color) unless ENV['silent']
  end

  def dp hsh, *args # display print : dp
    hsh       = {'str ' => hsh} if hsh.class == String
    title_str = args.select { |a| a.is_a? String }.first || nil
    color     = args.select { |a| a.is_a? Symbol }.first || :bl
    spacing   = args.select { |a| a.is_a? Fixnum }.first || 45
    p title_str, color if title_str
    hsh.each { |k, v| p "#{"%#{spacing}s" % k} : #{"%-#{spacing}s" % ("'#{v}'")}", color } unless ENV['silent']
  end

  def pr txt="", col=nil, no_new_line = false
    p txt, col, true
  end

  # == Overriding the default Kernel's p
  #   Deciding that we are going to override the default Kernel's {#p}
  #   Aww man.. was thinking of a formal logger method, but just going with this for now..
  # @example:  p(String) -> uncoloured "#\{String\}\\n"
  #   p "asdf"
  #   => asdf
  #   => _ # cursor
  # @example:  p(String,Symbol) -> Symbol coloured "#\{String\}\\n"
  #   p "asdf",:r
  #   => asdf # red in color
  #   => _ # cursor
  # @example:  p(String,Symbol,Boolean) -> Symbol coloured "#{String}"
  #   p "asdf",:rnd,'no_new_line_boolean'
  #   => asdf_ # {Random} color # cursor
  #
  # @return [String] coloured formatted and beautified string for printing.. man this is a lifesaver!
  # @param txt [String] which is the Actual info to print on the screen
  # @param col [Symbol] color symbol!.. see hash for possible supported +ANSI Color+ options
  # @param [Boolean] no_new_line remove the '\\n's from being added by default!

  def p txt="", col=nil, no_new_line = false
    txt=txt.to_s
    html_p txt, col
    unless ENV['silent']
      n                   = no_new_line ? "" : "\n"
      @@format_list       ||= {
          b:     :black,
          r:     :red,
          g:     :green,
          br:    :brown,
          bl:    :cyan,
          m:     :magenta,
          c:     :blue,
          cy:    :blue,
          y:     :brown,
          gy:    :gray,
          bg_b:  :bg_black,
          bg_r:  :bg_red,
          bg_g:  :bg_green,
          bg_br: :bg_brown,
          bg_bl: :bg_blue,
          bg_m:  :bg_magenta,
          bg_cy: :bg_cyan,
          bg_c:  :bg_cyan,
          bg_gy: :bg_gray,
          bg_B:  :bold,
          rev:   :reverse_color,
      }
      @@format_list[:rnd] = @@format_list[[:r, :g, :br, :bl, :m, :c, :cy, :gy].sample]
      if ENV["color"] and col
        cool = @@format_list[col] #|| :r
        cool ? print("#{txt}#{n}".send(cool)) : print("#{txt}#{n}")
      else
        print("#{txt}#{n}")
      end
    end
  end

  def html_p txt="", col=nil
    @@html_format_list ||=
        {
            b:  :black,
            r:  :red,
            g:  :lawngreen,
            br: :yellow,
            bl: :skyblue,
            m:  :magenta,
            c:  :cyan,
            cy: :cyan,
            gy: :GhostWhite,
        }
    $txt               ||= []; $sp_txt ||= []
    $sp_txt << txt
    $txt << "<pre class ='kyute' style='color:#{@@html_format_list[col]||'white'}'>#{txt}</pre>"
  end
end

module StringExt
  col_hsh={black:      "30",
           red:        "31",
           green:      "32",
           brown:      "33",
           blue:       "34",
           magenta:    "35",
           cyan:       "36",
           gray:       "37",
           bg_black:   "40",
           bg_red:     "41",
           bg_green:   "42",
           bg_brown:   "43",
           bg_blue:    "44",
           bg_magenta: "45",
           bg_cyan:    "46",
           bg_gray:    "47"}
  col_hsh.each { |k, v| define_method(k) { |slf=self| "\033[#{v}m#{slf}\033[0m" } }
  [%w{bold 1 22}, %w{reverse_color 7 27}].each { |a, b, c| eval("def #{a} slf=self;\"\\033[#{b}m\#{slf}\\033[#{c}m\"; end") }

  def trim slf=self
    slf.to_s.gsub('_', ' ').strip
  end

  def titilecase slf=self
    slf.to_s.trim.split(' ').map { |w| w.capitalize }.join(' ')
  end

  def camelcase slf=self
    slf.to_s.trim.downcase.titilecase.gsub(/\s+/, '')
  end

  def snakecase slf=self
    slf.to_s.trim.gsub(' ', '_').downcase
  end

  alias_method :downsnakecase, :snakecase

  def upsnakecase slf=self
    slf.to_s.trim.gsub(' ', '_').upcase
  end

  # space separated class name input appreciated..
  # word page is optional.. but beware of gsub!
  def page_class_name slf=self
    slf.to_s.strip.gsub(/page$/i, '').split(' ').map(&:capitalize).join + 'Page'
  end

  # makes :Name_element/'nAME ElemeNt' => "NAME_ELEMENT"
  def keyize slf=self
    slf.to_s.strip.gsub(" ", "_").upcase
  end

  # makes :Name|'nAME'|"nAmE ELemEnt" => "name_element"
  def elementify slf=self
    "#{slf.to_s.strip.downcase.gsub(" ", "_").gsub(/_element$/i, '')}_element"
  end

  # browser page text flatten
  def squash slf=self
    slf.to_s.gsub(/\s+/, " ")
  end

end
include StringExt

class String
  # include StringExt # don't remove... MonkeyPatching!!!
  # Split and return as ARY ',' separated string values
  #   or split_by=/./ separated values
  def parse_to_a(split_by=nil)
    !self.to_s.empty? ? self.split(split_by || ',').map(&:strip) : []
  end
end

class Symbol
  # include StringExt # don't remove... interesting...
end

class Array
  def seeded_sample
    self[$seeded.rand length] rescue self.sample
  end
end

include FormatMate
if __FILE__ == "#{$0} "
  #  http://stackoverflow.com/questions/1489183/colorized-ruby-output
  def colortable
    names   = %w(black red green yellow blue pink cyan white default)
    fgcodes = (30..39).to_a - [38]
    reg     = "\e[%d;%dm%s\e[0m"
    bold    = "\e[1;%d;%dm%s\e[0m"
    puts '                       color table with these background codes:'
    puts '          40       41       42       43       44       45       46       47       49'
    names.zip(fgcodes).each { |name, fg|
      s = "#{fg}"
      puts "%7s "%name + "#{reg}  #{bold}   "*9 % [fg, 40, s, fg, 40, s, fg, 41, s, fg, 41, s, fg, 42, s, fg, 42, s, fg, 43, s, fg, 43, s,
                                                   fg, 44, s, fg, 44, s, fg, 45, s, fg, 45, s, fg, 46, s, fg, 46, s, fg, 47, s, fg, 47, s, fg, 49, s, fg, 49, s]
    }
  end

  colortable

  ENV["color"] = "kod"
  # require '../action_files/_over_rider'
  opts         = [:b, :r, :g, :br, :bl, :m, :c, :gy, :bg_bl, :bg_re, :bg_gr, :bg_br, :bg_bl, :bg_ma, :bg_cy, :bg_gr, :bg_B, :rev]
  opts.each_with_index { |opt, i| p "#{i} kod sar #{opt} ", opt }
  p "100 kod sar bol ".red, :bg_B
  p "101 kod sar rev ", :rev
  p "101 kod sar rev \n"


  text= "_enna Kod sarav _hai__"
  text= :_enna_Kod_sarav_hai__
  p "Actual:\n#{text}\nMods:\n"

  p text.titilecase
  p text.camelcase
  p text.snakecase
  p text.downsnakecase
  p text.upsnakecase
end

if __FILE__ == $0
  # p String.methods.sort
  # p Symbol.methods.sort
  ENV["color"] = "kod"

  p "sdf,sdf,fds".parse_to_a
  p "sdf;erw;gdfcvb;fdg;ter".parse_to_a ';'

  p "kod sar hai ".page_class_name
  p "kod sar hai :".keyize
  p "kod sar element hai element".elementify
  p "  _    kod   sar  hai".squash

  p :kod_sar_hai.squash
  p :kod_sar_hai.page_class_name
  p :kod_sar_hai.keyize
  p :kod_sar_hai.elementify


  p parse_to_a "koduma;sara_anan"
  p page_class_name "koduma;sara_anan"
  p keyize "koduma;sara_anan"
  p elementify "koduma;sara_anan"
  p squash "koduma;sara_anan"

  p trim :hello_world
  p titilecase :hello_world
  p camelcase :hello_world
  p snakecase :hello_world
  p upsnakecase :hello_world
  p page_class_name :hello_world
  p keyize :hello_world
  p elementify :hello_world
  p squash :hello_world

  p trim "koduma;sarava_nan".green
  p titilecase "koduma;sarava_nan".green
  p camelcase "koduma;sarava_nan".green
  p snakecase "koduma;sarava_nan".green
  p upsnakecase "koduma;sarava_nan".green
  p page_class_name "koduma;sarava_nan".green
  p keyize "koduma;sarava_nan".green
  p elementify "koduma;sarava_nan".green
  p squash "koduma;sarava_nan".green

  p "koduma;sarava_nan".trim, :b
  p "koduma;sarava_nan".titilecase, :r
  p "koduma;sarava_nan".camelcase, :g
  p "koduma;sarava_nan".snakecase, :br
  p "koduma;sarava_nan".upsnakecase, :bl
  p "koduma;sarava_nan".page_class_name, :m
  p "koduma;sarava_nan".keyize, :c
  p "koduma;sarava_nan".elementify, :cy
  p "koduma;sarava_nan".squash, :gy

  p :koduma_sarava_nan.trim
  p :koduma_sarava_nan.titilecase
  p :koduma_sarava_nan.camelcase
  p :koduma_sarava_nan.snakecase
  p :koduma_sarava_nan.upsnakecase
  p :koduma_sarava_nan.page_class_name
  p :koduma_sarava_nan.keyize
  p :koduma_sarava_nan.elementify
  p :koduma_sarava_nan.squash

  p parse_to_a('IN_GROUND_POOL; IN_GROUND_POOL_FENCED', ';')

  p get_ary_of('IN_GROUND_POOL; IN_GROUND_POOL_FENCED', ';')

  p "koduma;sarava_nan".green+ "koduma;sarava_nan".gray
  p [1, 2, 3, 4, 5].sample
  p [1, 2, 3, 4, 5].seeded_sample
  $seeded=Random.new (rand*1e11).to_i
  p [1, 2, 3, 4, 5].seeded_sample
  $seeded=Random.new 12345
  p [1, 2, 3, 4, 5].seeded_sample

end
