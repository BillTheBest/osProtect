module ApplicationHelper
  def main_menu
    menu_tabs.each do |page|
      if page == 'resque_server'
        link_text = 'Background jobs'
        link = link_to(link_text, send("#{page}_path"), target: "_blank")
      else
        link_text = page.camelcase
        link = link_to(link_text, send("#{page}_path"))
      end
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
