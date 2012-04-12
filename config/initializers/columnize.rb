class Array
  def columnize args = { :columns => 1, :offset => 0 }
    column = []
    self.each_index do |i|
      column << self[i] if i % args[:columns] == args[:offset]
    end
    column
  end
end
