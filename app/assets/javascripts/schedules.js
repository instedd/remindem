String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
}

function MessageFields(row) {
	this._row = $(row);
	this._offset = $('input.offset', this._row);
	this._offsetText = $('span.offset', this._row);
	this._text = $('input.text', this._row);
	this._textText = $('pre.text', this._row);
  this._externalActions = eaFormToObject($('.externalActionForm'), this._row);
}

MessageFields.prototype.setOffset = function(value) {
	this._offset.val(value);
	this._offsetText.text(value);
}
MessageFields.prototype.getOffset = function() {
	return this._offset.val();
}
MessageFields.prototype.setText = function(value) {
	this._text.val(value);
	this._textText.text(value);
}
MessageFields.prototype.getText = function() {
	return this._text.val();
}

MessageFields.prototype.setExternalActions = function(value) {
  this._externalActions = value;
}

MessageFields.prototype.getExternalActions = function() {
  this._externalActions;
}

function MessageControls(row) {
	this._row = $(row);
	this._offset = $('input[name="edit_offset"]', this._row);
	this._text = $('textarea[name="edit_text"]', this._row);
  this._externalActions = eaFormToObject($('.externalActionForm'), this._row);
}

MessageControls.prototype.setOffset = function(value) {
	this._offset.val(value);
}

MessageControls.prototype.getOffset = function() {
	return this._offset.val();
}

MessageControls.prototype.setText = function(value) {
	this._text.val(value);
}

MessageControls.prototype.getText = function() {
	return this._text.val();
}

MessageControls.prototype.setExternalActions = function(value) {
  this._externalActions = value;
}

MessageControls.prototype.getExternalActions = function() {
  return this._externalActions;
}

MessageControls.prototype.isText = function() {
  return this._externalActions == null;
}

MessageControls.prototype.show_errors = function() {
  this.show_offset_errors_if_must();
  this.show_text_errors_if_must();
}

MessageControls.prototype.is_valid = function(){
  offsetValid = this.is_offset_valid();
  textValid = true;
  if(this.isText()) {
    textValid = this.is_text_valid();
  }
  return offsetValid && textValid;
}

MessageControls.prototype.is_offset_valid = function(){
  return !this.must_check_offset() || (this.is_offset_present() && this.is_offset_possitive() && this.offset_fits_inside_an_integer());
}

MessageControls.prototype.is_text_valid = function(){
  return !this.isText() || this.is_text_present();
}

MessageControls.prototype.show_text_errors_if_must = function(){
  this.show_text_error_if(cant_be_blank, this.is_text_valid());
}

MessageControls.prototype.show_offset_errors_if_must = function(){
  if (this.must_check_offset()) {
    this.show_offset_error_if(cant_be_blank, !this.is_offset_present());
    if (this.is_offset_present()) {
      if (this.is_offset_possitive()){
        this.show_offset_error_if(cant_be_greater_than_max, !this.offset_fits_inside_an_integer());
      } else {
        this.show_offset_error_if(cant_be_negative, !this.is_offset_possitive());
      }
    }
  }
}

MessageControls.prototype.is_offset_present = function(){
  return !(this.getOffset().trim() == "");
}

MessageControls.prototype.is_offset_possitive = function(){
  return (this.getOffset() >= 0 );
}

MessageControls.prototype.offset_fits_inside_an_integer = function(){
  return (this.getOffset() <= 2147483647 );
}

MessageControls.prototype.must_check_offset = function(){
  return $('input[name="schedule[type]"]:radio:checked').val() == 'FixedSchedule';
}

MessageControls.prototype.is_text_present = function(){
  return !(this.getText().trim() == "");
}

MessageControls.prototype.show_offset_error_if = function(message, condition){
  add_error_message_if_must(this._offset, message, condition, this._offset.parent().next());
}

MessageControls.prototype.show_text_error_if = function(message, condition){
  add_error_message_if_must(this._text, message, condition, this._text);
}

function assignMessageValues(dest, source) {
	dest.setOffset(source.getOffset());
	dest.setText(source.getText());
  dest.setExternalActions(source.getExternalActions());
}

function toggleOffset(){
	if ($('#fixed_schedule_option').is(':checked'))
		$('div.offset').css('visibility', 'visible');
	else
		$('div.offset').css('visibility', 'hidden');
}

var timescale;

$(function() {
  var form = $('form.edit_schedule, form.new_schedule');
  if (form.length > 0) {
    $('#fixed_schedule_option').change(function(){
      toggleOffset();
    });

    $('#random_schedule_option').change(function(){
      toggleOffset();
    });

    timescale = $('#schedule_timescale');

    timescale.change(function(){
      updateTimescaleLabels($(this).val());
    });
  	timescale.change();

    form.areYouSure({message: unsaved_changes, addRemoveFieldsMarksDirty: true});

    toggleOffset();
  };
});

function updateTimescaleLabels(new_value){
  var message = $('#random_schedule_option').attr('data-message');
	$('#random_schedule_option').next().text(message + ' ' + timescaleToOneString(new_value));
	$('.timescale').text(capitalizedSingular(new_value));
}

function caseTimescale(value, minute, hour, day, week, month, year, defaultCase){
	switch (value){
    case "minutes":
    case "minute":
      return minute
		case "hours":
		case "hour":
			return hour;
		case "days":
		case "day":
			return day;
		case "weeks":
		case "week":
			return week;
		case "months":
		case "month":
			return month;
		case "years":
		case "year":
			return year;
		default:
			return defaultCase;
	}
}

function remove_fields(link) {
  $(link).prev("input[type=hidden]").attr("value", '1');
  getRow(link).hide();
  $('form').trigger('rescan.areYouSure');
}

function edit_fields(link, content) {
  var fieldsRow = getRow(link);
  fieldsRow.after(content);
	var controlsRow = getRow(link).next();
	fieldsRow.hide();

  if(isExternalAction(controlsRow)) {
    renderExternalActionForm(fieldsRow, controlsRow);
  }
	assignMessageValues(new MessageControls(controlsRow), new MessageFields(fieldsRow));

	$.instedd.init_components(controlsRow);

  //Hide offset control if user is editing a random schedule
  toggleOffset();
	timescale.change();
}

function isExternalAction(controlsRow) {
  return $('.externalActionForm',controlsRow).length > 0;
}

function add_fields(link, association, content) {
  //Replace association placeholder id with a timestamp
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  var newRowContent = content.replace(regexp, new_id);

  //Add the new instance to the list
  getRow(link).before(newRowContent);
	var fieldsRow = getRow(link).prev().prev();
	var controlsRow = getRow(link).prev();

	fieldsRow.hide();
	$.instedd.init_components(fieldsRow);
	$.instedd.init_components(controlsRow);

  //Hide offset control if user is editing a random schedule
  toggleOffset();
	timescale.change();
}

function confirm_changes(buttonOk) {
  if (validate_fields(buttonOk)) {
  	var currentRow = getRow(buttonOk);
    var hiddenRow = $(currentRow).prev();
    var currentRowControls = new MessageControls(currentRow);
  	assignMessageValues(new MessageFields(hiddenRow), currentRowControls);
    setExternalActionsToHiddenField(hiddenRow, currentRowControls.getExternalActions());

  	hiddenRow.show();
  	currentRow.remove();

		return true;
	}
	return false;
}

function confirm_add(buttonOk) {
		confirm_changes(buttonOk);
}

function revert_changes(buttonCancel) {
	var currentRow = getRow(buttonCancel);
	var hiddenRow = $(currentRow).prev();
	hiddenRow.show();
	currentRow.remove();
}

function revert_add(buttonCancel) {
	var currentRow = getRow(buttonCancel);
	var hiddenRow = $(currentRow).prev();
	hiddenRow.remove();
	currentRow.remove();
}

function getRow(link){
  return $(link).closest(".fields");
}

function add_error_message_if_must(element, message, condition, element_before_error_message) {
  if (condition) {
      var errorElement = $('<label class="error">'+ message + '</label>');
    if (element.hasClass('error')) {
      element_before_error_message.next().remove();
    } else {
      element.addClass('error');
    }
    element_before_error_message.after(errorElement);
  } else {
    if (element.hasClass('error')) {
      element.removeClass('error');
      element_before_error_message.next().remove();
    }
  }
}

function validate_fields(butonOk) {
  var currentRow = getRow(butonOk);
  var controls = new MessageControls(currentRow);
  controls.show_errors();
  return controls.is_valid();
}

function validate_onblur (element) {
  var currentRow = getRow(element);
  var controls = new MessageControls(currentRow);
  controls.show_errors();
}

function chooseHubAction() {
  hubApi = new HubApi(window.hub_url, '/hub');
  hubApi.openPicker('action').then(function(path, selection) {
    var externalActionsLink = $('#externalActionsPicker');
    add_fields(externalActionsLink.get(0), 'external_actions', externalActionsLink.data('fields'));
    return hubApi.reflect(path).then(function(reflect_result) {
      if(reflect_result.args().length > 0) {
        var row = getRow($('.externalActionForm .action.model').last());
        renderForm(reflect_result, path, selection, row);
        $('.loading', row).addClass('hidden');
      }
    });
  });
};

function renderForm(reflect_result, path, selection, row) {
  model = $('.action.model', row);
  var container = $('.externalActionForm', row);
  renderSelectionPath(selection, container);
  $.each(reflect_result.args(), function(i, value) {
    buildForm(value, container, model);
  });
  model.remove();
  container.data('meta', {path: path, result: reflect_result.toJson(), selection: selection});
};

function buildForm(struct_or_value, row, model, path) {
  if(struct_or_value.isStruct()) {
    renderStruct(struct_or_value, row, model, path);
  }
  else {
    renderValue(struct_or_value, row, model, path);
  }
}

function renderStruct(struct, row, model, path) {
  var new_el = model.clone();
  if(path == undefined){
    var new_path = struct.name();
  } else {
    var new_path = path+"_"+struct.name();
  }
  $('label',new_el).text(struct.label() + ":");
  $('label',new_el).addClass('title');
  $('select', new_el).remove();
  row.append(new_el);
  var new_list = $('<ul></ul>');
  new_el.append(new_list);
  new_el.removeClass('hidden model');
  $.each(struct.fields(), function(index, value){
    buildForm(value, new_list, model, new_path);
  })
}

function renderValue(value, row, model, path) {
  new_el = model.clone();
  $('label', new_el).text(value.label());
  if(value.isEnum()){
    select = $('select', new_el);
    select.empty();
    $.each(value.enumOptions(), function(i,e) {
      var opt = new Option(e.label);
      opt.value = e.value;
      select.get(0).options.add(opt);
    });
  }
  if(path == undefined){
    var new_path = value.name();
  } else {
    var new_path = path+"_"+value.name();
  }
  $('select', new_el).attr('data-name', new_path);
  row.append(new_el);
  new_el.removeClass('hidden model');
}

function renderMapping(row, mappings, path) {
  for(mapping in mappings) {
    if(path == undefined){
      var new_path = mapping;
    } else {
      var new_path = path+"_"+mapping;
    }
    if(typeof(mappings[mapping]) != "string") {
      renderMapping(row, mappings[mapping], new_path);
    }
    else {
      $(".action select[data-name="+new_path+"]", row).val(mappings[mapping]);
    }
  }
}

function renderExternalActionForm(fieldsRow, controlsRow) {
  var hubApi = new HubApi(window.hub_url, '/hub');
  var data = $('.externalActionForm', controlsRow).data('meta');
  if(data == undefined){ data = JSON.parse($('.external_actions', fieldsRow)[0].value); }
  var result = hubApi.reflectResult(data.result);
  $('.loading', controlsRow).addClass('hidden');
  renderForm(result, data.path, data.selection, controlsRow);
  renderMapping(controlsRow, data.mapping);
}

function renderSelectionPath(selection, container) {
  var array = [];
  $.each(selection.parents, function(i,e) {
    array.push(e.label);
  })
  var selectionText = array.join(' → ');
  container.append($('<span class="selection">' + selectionText + '</span>'));
}

function eaFormToObject(src) {
  if(src.length == 0) { return null; }
  var hubApi = new HubApi(window.hub_url, '/hub');
  var data = src.data('meta');
  var result = hubApi.reflectResult(data.result);
  externalActions = {};
  struct = result.visitArgs(function(arg){
    if (!arg.isStruct()) {
      return $('.action select[data-name=' + arg.path().join("_") + ']', src).val();
    }
  });
  return $.extend(data, {mapping: struct});
}

function setExternalActionsToHiddenField(row, actions) {
  $('.external_actions', row).val(JSON.stringify(actions));
}
