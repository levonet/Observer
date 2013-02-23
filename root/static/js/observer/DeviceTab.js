define(["dojo/_base/declare",
	"dijit/layout/ContentPane",
], function(declare, ContentPane) {

	var DeviceTab = declare([ContentPane], {
		baseClass: "DeviceTab",

		devId:	-1,	// we'll set this from the widget def
		status:	"unreachable",
		host:	"",

	});
	return DeviceTab;
});
