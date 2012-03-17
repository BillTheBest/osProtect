jQuery ->
  $('#pulseTimePeriod').change ->
    optionSelectedValue = $('#pulseTimePeriod option:selected').val()
    top.location.href = optionSelectedValue;
