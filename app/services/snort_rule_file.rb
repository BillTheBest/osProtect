class SnortRuleFile
  attr_accessor :path, :filename

  def initialize(p, f)
    @path = p
    @filename = f
  end
end