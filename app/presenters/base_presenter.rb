class BasePresenter
  extend ActiveSupport::Memoizable

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