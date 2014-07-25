function multiplyMany() {
    if (arguments.length == 0) return 1;
    var head = arguments[0], tail = getTail(arguments);
    return head * multiplyMany.apply(this, tail);
}