class BasePresenter
  # extend ActiveSupport::Memoizable # deprecated in rails 3.2.0

  def initialize(object, template, params)
    @object = object
    @template = template
    @params = params
  end

  def self.presents(name)
    define_method(name) do
      @object
    end
  end

  def h
    @template
  end

  def params
    @params
  end
end