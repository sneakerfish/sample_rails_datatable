# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery -> 
  oTable = $('#contacts').dataTable
    sPaginationType: "full_numbers"
    bJQueryUI: true
    bServerSide: true
    pProcessing: true
    sAjaxSource: $('#contacts').data('source')

  $('#contacts tbody').delegate('tr', 'click', (e) ->                        
	# TODO: Add ability to edit in place with a form. OR delete with a button.
    $(this).addClass('row_selected').siblings().removeClass('row_selected')
    window.location = "/contacts/#{ $(this)[0].id }/edit" )
