function f() {
	function a() {
		b();
	}
	function b() {
		if (false) {
			f();
		}
	}
}