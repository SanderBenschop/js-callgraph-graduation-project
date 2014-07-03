function generateNumberLogger() {
	return function(number) {
		console.log(number);
	}
}
function falsePositiveLogger() {
	return function() {
		andereConsole.log()
	}
}
var array = [1,2,3,4,5];
array.forEach(generateNumberLogger());