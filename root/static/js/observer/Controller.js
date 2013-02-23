/*
 * Здесь собрать все идентификаторы, элементы, селекторы и ссылки
 * из враппера для упрощения обращения к ним.
 * Этот класс включается как родительски в контроллеры.
 */
define(["dojo/_base/declare",
	"dojo/dom"
], function(declare, dom) {

	var Controller = declare(null, {

		constructor: function(args) {
			declare.safeMixin(this, args);
		},

		//  msgType: "Info", "Warning", "Error"
		statusMsg: function(msgType, msg) {
			dom.byId("status_message").innerHTML = "<span class='status" + msgType + "'>" + msg + "</span>";
			console.log(msgType + ": " + msg);
		}
	});
	return Controller;
	//BUG:	Из функции возвращаем класс только через переменную:
	//	http://dojo-toolkit.33424.n3.nabble.com/How-to-dynamically-do-a-require-tp3731012p3740773.html
});
