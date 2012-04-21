module EventsHelper
  def page_entries_info_with_commas_in_numbers(astring)
    # override the defaults provided by "will_paginate":
    astring.gsub!('<b>', '')
    astring.gsub!('</b>', '')
    astring.gsub!('&nbsp;-&nbsp;', ' to ')
    astring.split(/\W+/).map{|w| w[/\d+/] ? number_with_delimiter(w) : w}.join(' ')
  end
end
