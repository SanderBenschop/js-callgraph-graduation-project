(function add(args) {
    jQuery.each(args, function (_, arg) {
        var type = jQuery.type(arg);
        if (type === "function") {
            if (!options.unique || !self.has(arg)) {
                list.push(arg);
            }
        } else if (arg && arg.length && type !== "string") {
            add(arg);
        }
    });
})(arguments);