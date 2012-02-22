jQuery ->
  $('.events_listing #q_sig_priority').attr('disabled',true)
  $('.events_listing #q_sig_id').attr('disabled',true)
  $('.events_listing #q_source_address').attr('disabled',true)
  $('.events_listing #q_source_port').attr('disabled',true)
  $('.events_listing #q_destination_address').attr('disabled',true)
  $('.events_listing #q_destination_port').attr('disabled',true)
  $('.events_listing #q_sensor_id').attr('disabled',true)
  $('.events_listing #q_relative_date_range').attr('disabled',true)
  $('.events_listing #q_timestamp_gte').attr('disabled',true)
  $('.events_listing #q_timestamp_te').attr('disabled',true)

  # if Access Allowed To is 'only me'(m) or 'any group or user'(a) then don't show groups:
  aat = $(".inputs .access_allowed #report_accessible_by option:selected").val()
  if aat == 'g'
    $('.groups').show()
  else
    $('.groups').hide()

  # show/hide groups if Access Allowed To is 'for group(s) selected below'(g):
  $('.inputs .access_allowed #report_accessible_by').change ->
    att = $(".inputs .access_allowed #report_accessible_by option:selected").val()
    if att == 'g'
      $('.groups').show()
    else
      $('.groups').hide()
    return true

  # if Run Automatically is Daily/Weekly/Monthly then don't show date ranges:
  rara = $(".inputs .auto_run #report_auto_run_at option:selected").text()
  if rara == ''
    $('.date_ranges').show()
  else
    $('.date_ranges').hide()

  # show/hide date ranges if Run Automatically is Daily/Weekly/Monthly or not selected(blank):
  $('.inputs .auto_run #report_auto_run_at').change ->
    s = $(".inputs .auto_run #report_auto_run_at option:selected").text()
    if s == ''
      $('.date_ranges').show()
    else
      $('.date_ranges').hide()
    return true
