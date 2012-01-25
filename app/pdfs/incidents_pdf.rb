class IncidentsPdf < Prawn::Document
  def initialize
    super
    text "incidents into pdf"
  end
end