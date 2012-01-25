module ApplicationHelper
  def main_menu
    menu_tabs.each do |page|
      link = link_to(page.camelcase, send("#{page}_path"))
      if page == params[:controller].downcase
        concat(content_tag(:li, link, class: "current", id: "#{page}"))
      else
        concat(content_tag(:li, link, id: "#{page}"))
      end
    end
    ''
  end

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
