jQuery ->
  $(".datepicker").datepicker({dateFormat: 'yy-mm-dd'})
  # $(".datepicker").datepicker()

  # $(".datepicker").each ->
  #   console.log(@)

  # $(".clear_filters_btn").click ->
  #   window.location.search = ""
  #   return false

  $('#events-check').toggle(
    ->
      $('input:checkbox').attr('checked','checked')
      # $(this).val('uncheck')
      $(this).val('')
    ,
    ->
      $('input:checkbox').removeAttr('checked')
      # $(this).val('check')
      $(this).val('')
  )

  $('#search-sidebar').toggle(
    ->
      $('div#osprotect_content').attr('class','with_sidebar')
      $('#sidebar').show()
    ->
      $('div#osprotect_content').attr('class','without_sidebar')
      $('#sidebar').hide()
  )

  $('#search-sidebar-no-events').toggle(
    ->
      $('div#osprotect_content').attr('class','without_sidebar')
      $('#sidebar').hide()
    ->
      $('div#osprotect_content').attr('class','with_sidebar')
      $('#sidebar').show()
  )

  # note: the following double submitted the form:
  # $("#add-selected-events").click ->
  #   $('#add-selected-events').hide()
  #   $('#adding-events-spinner').show()

  # see: https://github.com/rails/jquery-ujs/wiki/ajax for details:
  $('form.event_select_form').live 'ajax:beforeSend', () ->
    $('#add-selected-events').hide()
    $('#adding-events-spinner').show()
    $('#submit-selected-events').attr('disabled',true)
