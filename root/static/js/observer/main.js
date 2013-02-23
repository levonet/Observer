//define(["dojo/dom"], function(dom) {
define(["dojo/dom",
	"observer/Controller/Devices",
	"observer/Controller/Login",
], function(dom, Devices, Login) {		//TODO: remove from define modules.

	// the result object
	var observer = {
		login: null,
		device: null,
	};

        observer.start = function(/*Hash controllerName => params*/controllers) {
		for (var c in controllers) {
			if (controllers.hasOwnProperty(c)) {
//				console.log("START: " + c + " => " + controllers[c]);
				connect_controller(c, controllers[c]);
			}
                }
/*		var l = c && c.length || 0;
		if(l && typeof c == "string") c = c.split("");
		for (var i = 0; i < l; ++i) {
			connect_controller(c[i], p[i]);
		} */
        };

        function connect_controller(/*String*/ controllerName, /*Object*/ prop) {
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

	return observer;
});
