$('.language li a').live('click', function() {
  var req_locale = $(this).data('lang');
  window.location = '/locale/update?requested_locale=' + req_locale;
  return false;
});
