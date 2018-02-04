
class Try
  attr_accessor :one
  def initialize
    @one = "hmm"
    puts "in init"
  end

  def inst_mtd
    puts "  init mtd"
  end

  def self.static_mtd
    puts "static mtd"
    static_mtd_2
  end

  def self.static_mtd_2
    puts "static mtd 2"
  end
end

Try.static_mtd
t = Try.new
t.inst_mtd
Try.static_mtd