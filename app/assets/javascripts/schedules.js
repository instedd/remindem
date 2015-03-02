String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
}

function MessageFields(row) {
	this._row = $(row);
	this._offset = $('input.offset', this._row);
	this._offsetText = $('span.offset', this._row);
	this._text = $('input.text', this._row);
	this._textText = $('pre.text', this._row);
  this._externalActions = eaFormToObject($('.externalActionForm .action'), this._row);
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
  this._externalActions = eaFormToObject($('.externalActionForm .action'), this._row);
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

function showUnsavedChangesAlert(){
	$.status.showError(unsaved_changes)
}

function toggleOffset(){
	if ($('#fixed_schedule_option').is(':checked'))
		$('div.offset').css('visibility', 'visible');
	else
		$('div.offset').css('visibility', 'hidden');
}

var timescale;

$(function() {
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

  $('.causesPendingSaveNoticeOnChange').change(function(){
    showUnsavedChangesAlert();
  });

  $('.causesPendingSaveNoticeOnClick').click(function(){
    showUnsavedChangesAlert();
  });

  toggleOffset();
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
}

function edit_fields(link, content) {
  var fieldsRow = getRow(link);
  fieldsRow.after(content);
	var controlsRow = getRow(link).next();
	fieldsRow.hide();

	assignMessageValues(new MessageControls(controlsRow), new MessageFields(fieldsRow));

	$.instedd.init_components(controlsRow);

  //Hide offset control if user is editing a random schedule
  toggleOffset();
	timescale.change();
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

  	showUnsavedChangesAlert();
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
    return hubApi.reflect(path).then(function(reflect_result) {
      if(reflect_result.args().length > 0) {
        renderForm(reflect_result.args()[0]);
      }
    });
  });
};

function renderForm(result) {
  model = $('.externalActionForm .action.model');
  list = result.visit(function(field){
    new_el = model.clone();
    new_el.children('label').text(field.label());
    new_el.children('select').attr('data-name', field.name());
    $('.externalActionForm .action').last().after(new_el);
    new_el.removeClass('hidden model');
    model.remove();
  });
};

function eaFormToObject(src) {
  externalActions = {}
  src.each(function(i, el) {
    field = $(el).children('select');
    externalActions[field.data('name')] = field.val();
  });
  return externalActions;
}

function setExternalActionsToHiddenField(row, actions) {
  $('.external_actions', row).val(JSON.stringify(actions));
}
