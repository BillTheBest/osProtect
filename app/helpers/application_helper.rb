module ApplicationHelper
  def main_menu
    menu_tabs.each do |page|
      if page == 'resque_server'
        link_text = 'Background jobs'
        link = link_to(link_text, send("#{page}_path"), target: "_blank")
      elsif page == 'reports'
        link_text = page.camelcase
        link = link_to(link_text, send("pdfs_path"))
      elsif page == 'pdfs'
        link_text = 'PDFs'
        link = link_to(link_text, send("#{page}_path"))
      else
        link_text = page.camelcase
        link = link_to(link_text, send("#{page}_path"))
      end
      current = false
      if page == params[:controller].downcase
        current = true
      elsif page == 'pulse' && params[:controller].downcase == 'dashboard'
        current = true
      end
      if current
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
