chooseHubAction = function() {
  hubApi = new HubApi(window.hub_url, '/hub');
  hubApi.openPicker('action').then((function(_this) {
    console.log(_this);
  })(this));
}
