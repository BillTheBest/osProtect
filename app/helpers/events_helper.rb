module EventsHelper
  def page_entries_info_with_commas_in_numbers(astring)
    # an ugly hack to override the defaults provided by "will_paginate":
    astring.gsub!('<b>', '')
    astring.gsub!('</b>', '')
    astring.gsub!('&nbsp;-&nbsp;', ' to ')
    astring.split(/\W+/).map{|w| w[/\d+/] ? number_with_delimiter(w) : w}.join(' ')
  end

  def set_range(range)
    if range == 'today'
      date_range = 'Today'
    elsif range == 'last_24'
      date_range = 'Last 24 Hours'
    elsif range == 'week'
      date_range = 'This Week'
    elsif range == 'last_week'
      date_range = 'Last Week'
    elsif range == 'month'
      date_range = 'This Month'
    elsif range == 'past_year'
      date_range = 'Past Year'
    elsif range == 'year'
      date_range = 'Year'
    end
    return date_range
  end
end
