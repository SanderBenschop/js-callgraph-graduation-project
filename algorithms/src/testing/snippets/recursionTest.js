var counter = 0;
function f() {
	counter++;
	console.log("F was called!")
	if (counter < 5) f();
}