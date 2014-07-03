function f(multiplier) {
	return function(number) {
		return multiplier * number;
	}
}
f(2)(24);