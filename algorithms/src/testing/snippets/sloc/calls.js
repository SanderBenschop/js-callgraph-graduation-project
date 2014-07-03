function f() {
	function g() {
		h = function() {
			i = function j() {
				console.log("Hoi");
			}
		}
	}
}

f();
f(1);
new f();
new f(1);
new f;
i();
i()();