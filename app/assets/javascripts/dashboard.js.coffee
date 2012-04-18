# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $("#topAttackers").click ->
    $('li#topAttackers').attr('class','current')
    $('li#topTargets').removeAttr('class')
    $('li#topEvents').removeAttr('class')
    $('#top_attackers').show()
    $('#top_targets').hide()
    $('#top_events').hide()

  $("#topTargets").click ->
    $('li#topAttackers').removeAttr('class')
    $('li#topTargets').attr('class','current')
    $('li#topEvents').removeAttr('class')
    $('#top_attackers').hide()
    $('#top_targets').show()
    $('#top_events').hide()

  $("#topEvents").click ->
    $('li#topAttackers').removeAttr('class')
    $('li#topTargets').removeAttr('class')
    $('li#topEvents').attr('class','current')
    $('#top_attackers').hide()
    $('#top_targets').hide()
    $('#top_events').show()

  $('.no_menu_link').toggle(
    ->
      $('#frequencybox').show()
    ->
      $('#frequencybox').hide()
  )

#  $('#pulseTimePeriod').change ->
#    optionSelectedValue = $('#pulseTimePeriod option:selected').val()
#    top.location.href = optionSelectedValue;
