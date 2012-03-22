# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $("#topAttackers").click ->
    $('#top_attackers').show()
    $('#top_targets').hide()
    $('#top_events').hide()

  $("#topTargets").click ->
    $('#top_attackers').hide()
    $('#top_targets').show()
    $('#top_events').hide()

  $("#topEvents").click ->
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
