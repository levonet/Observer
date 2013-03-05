//define(["dojo/dom"], function(dom) {
define(["dojo/dom",
	"dojo/request",
	"dojo/json",
	"observer/Controller/Devices",
	"observer/Controller/Login",
], function(dom, request, JSON, Devices, Login) {		//TODO: remove from define modules.

	// the result object
	var observer = {
		urlSettings: "",
		settings: { store: {} },

		login: null,
		device: null,
	};


	observer.start = function(/*Hash controllerName => params*/controllers) {
		for (var c in controllers) {
			if (controllers.hasOwnProperty(c)) {
				connectController(c, controllers[c]);
			}
		}
	};

	function connectController(/*String*/ controllerName, /*Object*/ prop) {
                console.log("connect_controller(" + controllerName + ")");
                if (controllerName == 'login') {
//                        require(["observer/Controller/Login"], function(Login) { //TODO: dynamic modules
                                observer.login = new Login(prop);
//                        });
                }
                if (controllerName == 'device') {
//                        require(["observer/Controller/Devices", "dojo/domReady!"], function(Devices) {
//                                ready(function(){
//                                        console.log("connect_controller(" + controllerName + ") :require:"+boo);
                                observer.device = new Devices(prop);
//                                });
//                        });
                }
        };

	// Сохранение состояния

	observer.settings.get = function(/*String*/name, /*any*/defaultValue) {
		return (name in observer.settings.store) ? observer.settings.store[name] : defaultValue;
	};

	observer.settings.set = function(/*Hash param => value */list) {
		for (var param in list) {
			if (list.hasOwnProperty(param)) {
				observer.settings.store[param] = list[param];
			}
		}
	}

	observer.setSettings = function(/*Hash param => value */list) {
		//observer.device.statusMsg('Info', loc("Request ..."));
		request.post(observer.urlSettings, {
			handleAs: "json",
			headers: { 'Content-Type': 'application/json' },
			data: JSON.stringify(list),
		}).then(function(data) {
			console.log(data);
			//observer.device.statusMsg('Info', loc("Add device successful"));
		}, function(error) {
			console.log(error);
			//observer.device.statusMsg('Error', error);
		});
	};

	//TODO: return Deferred
	observer.getSettings = function(/*Hash param => defaultValue */list) {
		//observer.device.statusMsg('Info', loc("Request ..."));
		request.get(observer.urlSettings, {
			handleAs: "json",
			headers: { 'Content-Type': 'application/json' },
			data: JSON.stringify(list),
		}).then(function(data) {
			console.log(data);
			//observer.device.statusMsg('Info', loc("Add device successful"));
		}, function(error) {
			console.log(error);
			//observer.device.statusMsg('Error', error);
		});
	};


	return observer;
});
