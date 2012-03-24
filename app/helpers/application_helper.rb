module ApplicationHelper
  def presenting(object, presenter)
    klass = presenter.constantize
    presenter = klass.new(object, self, params)
    yield presenter if block_given?
    presenter
  end

  # def using_page_presenter(klass)
  #   (klass.singularize.camelcase + "PagePresenter").constantize
  # end
end
