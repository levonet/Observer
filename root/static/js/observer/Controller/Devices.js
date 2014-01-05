define(["dojo/_base/declare",
	"observer/Controller",
	"dijit/registry",
	"dojo/topic",
], function(declare, Controller, registry, topic) {
	var Devices = declare([Controller], {

		urlDevView: "",
		urlViewMACs: "",
		urlFindDialog: "",
		urlFind: "",
		urlDevAddTab: "",
		urlDevAdd: "",
		urlDevEdit: "",
		urlDevStatus: "",
		urlHostItem: "",

		role_edit: false,

		// Текущее устройство
		currentDevId: -1,
//		currentArea: null,
		// Выбранные устройства (во вкладках)
		selectedTabs: {}, // hash of tapbar ContentPanes by devId

		_deviceAddTab: false,		/* flag */
		_helpTab: false,
		_helpContent: false,

		_findDialog: null,		/* widget */
		_findStore: null,

		_handlerTrapSelectHost: null,
		_handlerDeviceFindDlg: null,
		_handlerDeviceAddTab: null,
		_handlerViewMACs: null,
		_handlerHelp: null,

		constructor: function(args) {
			declare.safeMixin(this, args);
			console.log("Controller/Device constructor");
			this.initToolbar();
			this.trapSelectHost();
			this.trapChangeTabbar();
		},

		initToolbar: function() {
			require(["dijit/Toolbar",
				"dijit/form/Button",
				"dijit/form/ToggleButton",
				"dijit/form/DropDownButton",
				"dijit/TooltipDialog",
				"dijit/ToolbarSeparator",
			], function(Toolbar, Button, ToggleButton, DropDownButton, TooltipDialog, ToolbarSeparator) {
				var toolbar = new Toolbar({}, "toolbar");
				toolbar.addChild(new Button({
					id:	   "tbRefreshDevices",
					iconClass: "icon16x16 icon16x16Refresh",
					showLabel: false,
					label:	   loc("Refresh devices"),
					onClick: function () {
						console.log("tbRefreshDevices.onClick()");
						registry.byId("cpDevices").refresh();
					},
				}));
				var filter = new TooltipDialog({
					content: '<label for="filterArea">Area:</label> <input data-dojo-type="dijit/form/TextBox" id="filterArea" name="filterArea"><br>'
						+'<label for="filterHost">Host:</label> <input data-dojo-type="dijit/form/TextBox" id="filterHost" name="filterHost"><br>'
						+'<button data-dojo-type="dijit/form/Button" type="submit">Filter</button>',
					onSubmit: function () {
						console.log("tbFilterDevices.onSubmit()");
//						//topic.publish("device/find");
					},
				});
				toolbar.addChild(new DropDownButton({
					id:	   "tbFilterDevices",
					iconClass: "icon16x16 icon16x16Filter",
					showLabel: false,
					label:	   loc("Filter"),
					dropDown:  filter,
					disabled:  true,
				}));
				toolbar.addChild(new ToolbarSeparator({}));
				toolbar.addChild(new Button({
					id:	   "tbFindDevices",
					iconClass: "icon16x16 icon16x16Find",
					showLabel: true,
					label:	   loc("Find"),
					onClick:   function () {
						console.log("tbFindDevices.onClick()");
						if (!observer.device._handlerDeviceFindDlg) {
							observer.device.trapDeviceFindDlg();
						}
						topic.publish("device/find");
					},
				}));
				if (observer.device.role_edit) {
					toolbar.addChild(new Button({
						id:	   "tbAddDevices",
						iconClass: "icon16x16 icon16x16Add",
						showLabel: true,
						label:	   loc("Add"),
						onClick:   function () {
							console.log("tbAddDevices.onClick()");
							if (!observer.device._handlerDeviceAddTab) {
								observer.device.trapDeviceAddTab();
							}
							topic.publish("device/add");
						},
					}));
				}
				toolbar.addChild(new ToolbarSeparator({}));
				toolbar.addChild(new ToggleButton({
					id:	   "tbViewMACs",
					iconClass: "icon16x16 icon16x16View",
					showLabel: true,
					label:	   loc("Show MACs"),
					onChange:  function (val) {
						console.log("tbViewMACs.onClick("+val+")");
						if (!observer.device._handlerViewMACs) {
							observer.device.trapViewMACs();
						}
						topic.publish("device/viewmac", val);
						observer.setSettings({'device/viewmac': val});
					},
					checked: observer.settings.get('device/viewmac', false),
				}));
				toolbar.addChild(new ToolbarSeparator({}));
				toolbar.addChild(new Button({
					id:	   "tbHelp",
					iconClass: "icon16x16 icon16x16Help",
					showLabel: false,
					label:	   loc("Help"),
					onClick:   function () {
						if (!observer.device._handlerHelp) {
							observer.device.trapHelp();
						}
						topic.publish("device/help");
					},
				}));
			});
		},

		/* Tabbar management */

		trapChangeTabbar: function() {
			var tabbar = registry.byId("tabbar");
			tabbar.watch("selectedChildWidget", function(name, oval, nval) {
				observer.device.currentDevId = -1;
				if (oval && oval.baseClass == "DeviceTab") {
console.log("Device.tabbar.watch[oval] = "+oval.get('devId'));
					var item = registry.byId("hostItem" + oval.get('devId'));
					item.setCurrent(false);
				}
				if (nval && nval.baseClass == "DeviceTab") {
console.log("Device.tabbar.watch[nval] = "+nval.get('devId'));
					var item = registry.byId("hostItem" + nval.get('devId'));
					item.setCurrent(true);
					observer.device.currentDevId = nval.get('devId');
				}
			});
		},

		trapSelectHost: function() {
			this._handlerTrapSelectHost = topic.subscribe("navbar/change", function(/*Int*/devId) {
				console.log("Device.trapSelectHost("+devId+", goto: "+observer.device.urlDevView+")");
				// Проверяем, открыта ли такая вкладка
				if ('_'+devId in observer.device.selectedTabs) {	// если да, переходим
					var tabbar = registry.byId("tabbar");
					tabbar.selectChild(observer.device.selectedTabs['_'+devId]);
				} else {	// если нет, создаем новую
console.log("Device.trapSelectHost(new) = "+devId);
					require(["observer/DeviceTab"], function(DeviceTab) {
						var tabbar = registry.byId("tabbar");
						var item = registry.byId("hostItem" + devId);
						var cp = new DeviceTab({
							devId: devId,
							status: item.get('status'),
							host: item.get('host'),
							title: item.get('host'),
							closable: true,
							href: observer.device.urlDevView.replace(/_DEVID_/, devId),
							onClose: function() {
								// Передаются переменные this = cp
								delete observer.device.selectedTabs['_'+this.devId];
								var item = registry.byId("hostItem"+this.devId);
								item.setSelected(false);
								return true;
							}
						});
						tabbar.addChild(cp);
						tabbar.selectChild(cp);
						observer.device.selectedTabs['_'+devId] = cp;
					});
				}
			});
		},

		/* Find Devices */

		findDialog: function() { return this._findDialog; },
		setFindDialog: function(/*Object*/dlg) { this._findDialog = dlg; },

		findDialogSubmit: function() {
			registry.byId("findGrid").setQuery({
				findAreaHost: registry.byId("findAreaHost").get('value'),
				findSrcHost: registry.byId("findSrcHost").get('value'),
				findMAC: registry.byId("findMAC").get('value'),
			}, {});
		},

		trapDeviceFindDlg: function() {
			this._handlerDeviceFindDlg = topic.subscribe("device/find", function() {
				console.log("Device.openFindDialog()");
				if (observer.device.findDialog()) {
					observer.device.findDialog().show();
					return;
				}
				/* init findDialog */
				require(["dijit/Dialog", "dojo/keys"], function(Dialog, keys) {
					var findDialog = new Dialog({
						id:	'deviceFindDialog',
						title:	loc('Search devices'),
						style:	"width:60%;",
						href:	observer.device.urlFindDialog,
						refreshOnShow: true,
						onLoad: function() {
							// Submit
							registry.byId("dlgFindButton").on('click', function() {
								observer.device.findDialogSubmit();
							});
							registry.byId("findSrcHost").on('keypress', function(e) {
								if (e.keyCode == keys.ENTER) {
									observer.device.findDialogSubmit();
								}
							});
							registry.byId("findMAC").on('keypress', function(e) {
								if (e.keyCode == keys.ENTER) {
									observer.device.findDialogSubmit();
								}
							});

							require(["dojox/grid/DataGrid",
								"dojo/store/JsonRest",
								"dojo/data/ObjectStore",
								"dojo/dom-geometry",
								"dojo/dom",
								"dojo/dom-style",
								"dojo/domReady!"
							], function(DataGrid, JsonRest, ObjectStore, domGeom, dom, style) {
								var findStore = new JsonRest({ target: observer.device.urlFind });
								var grid = new DataGrid({
									store: findDataStore = new ObjectStore({ objectStore: findStore }),
									structure: [
										{ field: "SrcHost", name: loc("Host"), width: '12em' },
										{ field: "IfStatus", name: loc("Status"), width: '4em' },
										{ field: "IfName", name: loc("Port"), width: '9em' },
										{ field: "MAC", name: loc("MAC"), width: '8em' },
										{ field: "Service", name: loc("Service"), width: '6em' },
										{ field: "UpdTime", name: loc("Last"), width: '14em',
											formatter: function(updTime) {
												return updTime.replace(/^\'(.*)T(.*)\'$/, "$1 $2"); // '
											}
										},
									],
									onDblClick: function(e) {
										var items = registry.byId("findGrid").selection.getSelected();
										if (items.length) {
											observer.device.findDialog().onCancel();
											topic.publish("navbar/set", items[0].id);
										}
									},
								}, "findGrid");
								grid.startup();

								// Updating grid position
								var findDom = dom.byId("deviceFindDialog"),
								    pos = domGeom.position(findDom, true);
								var y = pos.y - pos.h/2;
								style.set(findDom, { left: pos.x+"px", top: y >= 0 ? y+"px" : 0 });
							});
						},
					});
					observer.device.setFindDialog(findDialog);
					findDialog.show();
				});
			});
		},

		/* Add Devices */

		isDeviceAddTab: function() { return this._deviceAddTab; },
		setDeviceAddTab: function(/*Bool*/state) { this._deviceAddTab = state; },
		
		trapDeviceAddTab: function() {

			this._handlerDeviceAddTab = topic.subscribe("device/add", function() {
				console.log("Device.openDeviceAddTab()");

				// Rules
				if (!observer.device.role_edit) {
					return;
				}

				if (observer.device.isDeviceAddTab()) {
					var cp = registry.byId("deviceAddTab");
					registry.byId("tabbar").selectChild(cp);
					return;
				}

				observer.device.setDeviceAddTab(true);
				console.log("Device.openDeviceAddTab()");
				require(["dijit/layout/ContentPane"], function(ContentPane) {
					var tabbar = registry.byId("tabbar");
					var cp = new ContentPane({
						id:	"deviceAddTab",
						title:	loc("Add hosts"),
						closable: true,
						style:	"overflow:auto;",
						href:	observer.device.urlDevAddTab,
						onLoad: function(data) {
							observer.device.initSubmitDeviceAddTab();
							//TODO: init area select
						},
						onClose: function() {
							observer.device.setDeviceAddTab(false);
							return true;
						},
					});
					tabbar.addChild(cp);
					tabbar.selectChild(cp);
				});

			});
		},

		initSubmitDeviceAddTab: function() {
			require(["dojo/request", "dojo/json", "dojo/domReady!"], function(request, JSON) {
				var form = registry.byId("addtab");
				form.on('submit', function(e) {
					var form = registry.byId("addtab");
					if (this.validate()) {
						observer.device.statusMsg('Info', loc("Request ..."));
						request.post(observer.device.urlDevAdd, {
							handleAs: "json",
							headers: { 'Content-Type': 'application/json' },
							data: JSON.stringify(form.getValues()),
						}).then(function(data) {
							observer.device.statusMsg('Info', loc("Add device successful"));
							registry.byId("tabbar").closeChild(registry.byId("deviceAddTab"));
							registry.byId("cpDevices").refresh();
						}, function(error) {
							observer.device.statusMsg('Error', error);
						});
					}
					return false;
				});
			});
		},

		/* View Ports */

		onLoadViewPorts: function(devId) {
			require(["dojo/domReady!"], function () {
				console.log("onLoadViewPorts("+devId+")");
				if (registry.byId("tbViewMACs").get("checked")) {
					this.showViewMACs(devId);
				}
			}.bind(this));
		},

		trapViewMACs: function() {
			this._handlerViewMACs = topic.subscribe("device/viewmac", function(val) { //TODO: а нужен ли publish?
				if (val && this.currentDevId >= 0) {
					// Если MAC-и уже показаны, просто обновляем информацию
					this.showViewMACs(this.currentDevId);
				}
			}.bind(this));
		},

		formatMAC: function(mac) {
			if (mac.service) {
				return "<span class='service' title='" + mac.mac + "'>" + mac.service + "</span>";
			} else {
				return "<span class='mac" + (mac.online>0?" online":"")
					+ "' title=\"" + mac.updtime + "\">" + mac.mac + "</span>";
			}
		},

		showViewMACs: function(devId) {
console.log("WARM0");
console.log(this);
			require(["dojo/dom", "dojo/dom-attr"], function (dom, domAttr) {
				dom.byId("vpMACsTitle"+devId).innerHTML = domAttr.get("vpMACsTitle"+devId, "title");
				this.statusMsg('Info', loc("Request for MACs ..."));
				require(["dojo/request"], function(request) {
console.log("WARM1");
console.log(this);
					request(this.urlViewMACs.replace(/_DEVID_/, devId), {
						handleAs: "json",
						headers: { 'Content-Type': 'application/json' },
					}).then(function(data) {
console.log(data);
console.log("WARM2");
console.log(this);
						for (var port in data.macs) {
							if (data.macs.hasOwnProperty(port)) {
								var ret = [];
								var services = {};
								for (var i=0; i< data.macs[port].length; i++) {
									ret.push(this.formatMAC(data.macs[port][i]));
								}
								dom.byId("vpMACs"+devId+"_"+port).innerHTML = ret.join(", ");
							}
						}
						this.statusMsg('Info', loc("ok"));
					}.bind(this), function(error) {
						console.log("error:", error);
						this.statusMsg('Error', error);
					}.bind(this));
				}.bind(this));
			}.bind(this));
		},

		/* View Edit */

		onLoadViewEdit: function(devId) {
			require(["dojo/request", "dojo/json", "dojo/domReady!"], function(request, JSON) {
				console.log("onLoadViewEdit("+devId+")");
				var formStatus = registry.byId("formStatus"+devId);
				formStatus.on('submit', function(e) {
					console.log("onLoadViewEdit.submit("+devId+")");
					var form = registry.byId("formStatus"+devId);
					observer.device.statusMsg('Info', loc("Request ..."));
					request.post(observer.device.urlDevStatus.replace(/_DEVID_/, devId), {
						handleAs: "json",
						headers: { 'Content-Type': 'application/json' },
						data: JSON.stringify(form.getValues()),
					}).then(function(data) {
						observer.device.statusMsg('Info', loc("Update status successful"));
						registry.byId("cpDevices").refresh();
					}, function(error) {
						observer.device.statusMsg('Error', error);
					});
					return false;
				});
				var formEdit = registry.byId("formEdit"+devId);
				formEdit.on('submit', function(e) {
					console.log("onLoadViewEdit.submit("+devId+")");
					var form = registry.byId("formEdit"+devId);
					observer.device.statusMsg('Info', loc("Request ..."));
					request.post(observer.device.urlDevEdit.replace(/_DEVID_/, devId), {
						handleAs: "json",
						headers: { 'Content-Type': 'application/json' },
						data: JSON.stringify(form.getValues()),
					}).then(function(data) {
						observer.device.statusMsg('Info', loc("Update device successful"));
						registry.byId("cpDevices").refresh();
					}, function(error) {
						observer.device.statusMsg('Error', error);
					});
					return false;
				});
				var formDelete = registry.byId("formDelete"+devId);
				formDelete.on('submit', function(e) {
					console.log("onLoadViewEdit.submit("+devId+")");
					observer.device.statusMsg('Info', loc("Request ..."));
					request.del(observer.device.urlDevEdit.replace(/_DEVID_/, devId), {
						handleAs: "json",
						headers: { 'Content-Type': 'application/json' },
					}).then(function(data) {
						observer.device.statusMsg('Info', loc("Delete device successful"));
						if (observer.device.selectedTabs['_'+data.devId]) {
							var tabbar = registry.byId("tabbar");
							tabbar.closeChild(observer.device.selectedTabs['_'+data.devId]);
						}
//FIXIT: hostitem обращается по старому devId
						registry.byId("cpDevices").refresh();
					}, function(error) {
						observer.device.statusMsg('Error', error);
					});
					return false;
				});
			});
		},

		/* Help Tab */

		isHelpTab: function() { return this._helpTab; },
		setHelpTab: function(/*Bool*/state) { this._helpTab = state; },
		
		trapHelp: function() {

			this._handlerDeviceAddTab = topic.subscribe("device/help", function() {

				console.log("Device.openHelpTab()");
				if (this.isHelpTab()) {
					var cp = registry.byId("deviceHelpTab");
					registry.byId("tabbar").selectChild(cp);
					return;
				}

				this.setHelpTab(true);
				console.log("Device.newHelpTab()");
				require(["dijit/layout/ContentPane"], function(ContentPane) {
					var tabbar = registry.byId("tabbar");
					var cp = new ContentPane({
						id:	"deviceHelpTab",
						title:	loc("Help"),
						closable: true,
						style:	"overflow:auto;",
						content: "<div id='deviceHelpView'></div>",
						onShow: function() {
							if (this._helpContent) {
								return;
							}
							require(["dojo/_base/kernel",
								"dojo/dom",
								"dojo/html",
								"observer/XSLTransform",
							], function(dojo, dom, html, XSLTransform) {
								var xslTransform = new XSLTransform("/static/xml/help.xsl", { locale: dojo.locale });
								var outputText = xslTransform.transform("/static/xml/help/confsnmp.xml");
								html.set(dom.byId("deviceHelpView"), outputText);
								this._helpContent = true;
							}.bind(this));
						}.bind(this),
						onClose: function() {
							this.setHelpTab(false);
							this._helpContent = false;
							return true;
						}.bind(this),
					});
					tabbar.addChild(cp);
					tabbar.selectChild(cp);
				}.bind(this));

			}.bind(this));
		},

	});
	return Devices;
});
