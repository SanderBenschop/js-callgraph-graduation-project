var obj = {
	onBeforeStart: function (el) {
	    return el.getStyle().toString();
	}.bind(this)
};
obj.onBeforeStart({
	getStyle : function() {
		return 1;
	}
});