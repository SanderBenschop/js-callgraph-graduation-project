function f() {
}
function g() {
}

var firstFunc = true ? f : g;
var secondFunc = true ? g : f;
firstFunc();
secondFunc();	