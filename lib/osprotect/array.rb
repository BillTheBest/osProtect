# use:
# require "osprotect/array"
# where this new method is needed
# see: app/pdf_generators/events_pdf.rb for an example
class Array
  def columnize args = { :columns => 1, :offset => 0 }
    column = []
    self.each_index do |i|
      column << self[i] if i % args[:columns] == args[:offset]
    end
    column
  end
end
