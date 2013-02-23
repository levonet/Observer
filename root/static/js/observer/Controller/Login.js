define(["dojo/_base/declare",
	"observer/Controller",
	"dijit/registry",
], function(declare, Controller, registry) {
	var Login = declare([Controller], {

		urlAuth: "",

		constructor: function(args) {
			declare.safeMixin(this, args);
			console.log("Controller/Login constructor");
			this.initSubmit();
		},

		initSubmit: function() {
			require(["dojo/request"], function(request) {
				var form = registry.byId("login");
				form.on('submit', function(e) {
					var form = registry.byId("login");
					if (this.validate()) {
						observer.login.statusMsg('Info', loc("Login..."));
						request.post(observer.login.urlAuth, {
							preventCache: true,
							handleAs: "json",
							data: form.getValues(),
						}).then(function(data) {
							if ( data && !data.error ) {
								observer.login.statusMsg('Info', loc("Login successful"));
								window.location = data.redirect;
							} else {
								observer.login.statusMsg('Error', data.error);
							}
						}, function(error) {
							observer.login.statusMsg('Error', error);
						});
					}
					return false;
				});
			});
		},
	});

	return Login;
});
