define(["dojo/_base/declare",
	"dijit/_WidgetBase",
	"dojo/dom-construct",
	"dojo/dom-class",
	"dijit/registry",
	"dojo/topic",
], function(declare, _WidgetBase, domConstruct, domClass, registry, topic) {

	var HostItem = declare([_WidgetBase], {
		// some properties
		baseClass: "HostItem",
		devId:	-1,	// we'll set this from the widget def
		status:	"unreachable",
		host:	"",

		//TODO: setter
		current: false,
		selected:false,

		_current: false,
		_selected: false,
		_curHandler: null,
		_setHandler: null,

		buildRendering: function() {
			// create the DOM for this widget
			this.domNode = domConstruct.create("li", {innerHTML: this.host, title: this.status});
		},

		_onClick: function() {
			var item = registry.byId(this.id);
console.log("HostItem["+this.id+"]._onClick(" + this.id + ") current=" + item.get("_current") + " selected=" + item.get("_selected"));
			if (!item.isCurrent()) {
				item.setCurrent(true);
			}
			if (!item.isSelected()) {
				item.setSelected(true);
			}
console.log("HostItem["+this.id+"]._onClick(end)");
		},

		isCurrent: function() { return this._current; },
		isSelected: function() { return this._selected; },

		setCurrent: function(/*Bool*/state) {
			if (state == this._current) {
				return;
			}
console.log("HostItem["+this.id+"].setCurrent(" + state + ") = " + registry.byId(this.id).get("devId"));
			if (state) {
				this._current = true;
				domClass.add(this.id, "current");
				var thisDevId = this.devId; //FIXIT
				this._curHandler = topic.subscribe("navbar/change", function(/*Int*/devId) {
console.log("HostItem["+thisDevId+"]._curHandler(" + devId + ")");
					if (thisDevId != devId) {
						var item = registry.byId("hostItem" + thisDevId);
						item.setCurrent(false);
console.log("HostItem["+thisDevId+"]._curHandler(OK)");
					}
console.log("HostItem["+thisDevId+"]._curHandler(end)");
				});
				topic.publish("navbar/change", this.devId);

				if (!this.current) { // игнорируем при обновлении
					require(["dojo/request"], function(request) {
						request.put(observer.device.urlHostItem.replace(/_DEVID_/, thisDevId), {
							handleAs: "json",
							headers: { 'Content-Type': 'application/json' },
						}).then(function(data) {
							console.log("response:", data);
						}, function(error) {
							console.log("error:", error);
							observer.device.statusMsg('Error', error);
						});
					});
				}
			} else {
				this._current = false;
				this.current = false;
				domClass.remove(this.id, "current");
				if (this._curHandler) {
					this._curHandler.remove();
					this._curHandler = null;
				}
			}
console.log("HostItem["+this.id+"].setCurrent(end)");
		},

		setSelected: function(/*Bool*/state) {
			if (state == this._selected) {
				return;
			}
console.log("HostItem["+this.id+"].setSelected(" + state + ") = " + registry.byId(this.id).get("devId"));
			if (state) {
				this._selected = true;
				domClass.add(this.id, "selected");
			} else {
				this._selected = false;
				domClass.remove(this.id, "selected");
				this.setCurrent(false);

				var devId = this.devId;
				require(["dojo/request"], function(request) {
					request.del(observer.device.urlHostItem.replace(/_DEVID_/, devId), {
						handleAs: "json",
						headers: { 'Content-Type': 'application/json' },
					}).then(function(data) {
						console.log("response:", data);
					}, function(error) {
						console.log("error:", error);
						observer.device.statusMsg('Error', error);
					});
				});
			}
console.log("HostItem["+this.id+"].setSelected(end)");
		},

		postCreate: function() {
			this.on("click", this._onClick);

			this.setSelected(this.selected);
			this.setCurrent(this.current);

			var thisDevId = this.devId; //FIXIT
			this._setHandler = topic.subscribe("navbar/set", function(/*Int*/devId) {
				if (thisDevId == devId) {
					var item = registry.byId("hostItem" + thisDevId);
					if (item) {
						item._onClick();
					}
				}
			});


//TODO: если selected и не current открываем на таббаре вкладки но не делаем их активными.
//	будет наблюдаться мерцание вкладок до current. надо придумать как пофиксить или вовсе чистить сессию на сервере при полном обновлении.
		},

		destroy: function(preserveDom) {
console.log("HostItem["+this.id+"].destroy()");
			if (this._curHandler) {
				this._curHandler.remove();
			}
			if (this._setHandler) {
				this._setHandler.remove();
			}
			this.inherited(arguments);
		},
	});
	return HostItem;
});
