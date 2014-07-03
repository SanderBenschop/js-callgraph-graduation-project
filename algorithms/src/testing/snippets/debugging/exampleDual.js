function f(multiplier) {
	return function(number) {
		return multiplier * number;
	}
}
f(2)(24);

function g(divisor) {
	return function(number) {
		return number / divisor;
	}
}
g(2)(84);