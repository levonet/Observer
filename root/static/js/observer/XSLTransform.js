// Client-Side XSLT Transformations
// http://ivanz.com/2011/05/12/client-side-xslt-transformations-with-javascript/
// By Ivan Zlatev (MIT/X11 license)
//
// TODO: addParameter for IE from http://msdn.microsoft.com/en-us/library/windows/desktop/ms762312%28v=vs.85%29.aspx
//
define(["dojo/_base/declare",
	"dojo/request/xhr",
	"dojo/has",
	"dojo/_base/sniff"
], function(declare, xhr, has) {

	var XSLTransform = declare(null, {

		_xslDoc : null,
		_xslPath : null,
		_xslParams : null,

		constructor : function(xslPath, xslParams) {
			this._xslPath = xslPath;
			this._xslParams = xslParams;
		},

		transform : function(xmlPath) {
			if (this._xslDoc === null)
				this._xslDoc = this._loadXML(this._xslPath);

			var result = null;
			var xmlDoc = this._loadXML(xmlPath);

			if (has("ie")) {
				result = xmlDoc.transformNode(this._xslDoc);
			} else if(typeof XSLTProcessor !== undefined) {
				xsltProcessor = new XSLTProcessor();
				xsltProcessor.importStylesheet(this._xslDoc);

				for (var param in this._xslParams) {
					if (this._xslParams.hasOwnProperty(param)) {
						xsltProcessor.setParameter(null, param, this._xslParams[param]);
					}
				}

				var ownerDocument = document.implementation.createDocument("", "", null);
				result = xsltProcessor.transformToFragment(xmlDoc, ownerDocument);
			} else {
				alert("Your browser doesn't support XSLT!");
			}

			return result;
		},

		_createXMLDocument : function(xmlText) {
			var xmlDoc = null;

			if (has("ie")) {
				xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
				xmlDoc.async = false;
				xmlDoc.loadXML(xmlText);
			} else if (window.DOMParser) {
				parser = new DOMParser();
				xmlDoc = parser.parseFromString(xmlText, "text/xml");
			} else {
				alert("Your browser doesn't suppoprt XML parsing!");
			}

			return xmlDoc;
		},

		// Synchronously loads a remote xml file
		_loadXML : function(xmlPath) {
			var xml = null;
			xhr(xmlPath, {
				handleAs : "xml",
				sync: true
			}).then(function (response) {
				// Returns immediately, because the GET is synchronous.
				xml = response;
			});
			return xml; 
		}
	});

	return XSLTransform;
});
