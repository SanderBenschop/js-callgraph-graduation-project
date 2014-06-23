var THISREFERENCE = this;
var LAST_CALL_LOC = undefined;
var CALL_MAP = {};
var ALL_FUNCTIONS = [$$allFunctionsJoined$$];
var COVERED_FUNCTIONS = [];
var ALL_CALLS = [$$allCallsJoined$$];
var COVERED_CALLS = [];
var CALL_STACK_DEPTH = 0;

/** Project metrics **/
function GET_FUNCTION_COVERAGE_PERCENTAGE() {
	return FILTER_NON_FRAMEWORK_FUNCTIONS(COVERED_FUNCTIONS).length / FILTER_NON_FRAMEWORK_FUNCTIONS(ALL_FUNCTIONS).length * 100;
}

function GET_CALL_COVERAGE_PERCENTAGE() {
	return FILTER_NON_FRAMEWORK_FUNCTIONS(COVERED_CALLS).length / FILTER_NON_FRAMEWORK_FUNCTIONS(ALL_CALLS).length * 100;
}

/** Framework metrics **/
function GET_FRAMEWORK_FUNCTION_COVERAGE_PERCENTAGE() {
	return FILTER_FRAMEWORK_FUNCTIONS(COVERED_FUNCTIONS).length / FILTER_FRAMEWORK_FUNCTIONS(ALL_FUNCTIONS).length * 100;
}

function GET_FRAMEWORK_CALL_COVERAGE_PERCENTAGE() {
	return FILTER_FRAMEWORK_FUNCTIONS(COVERED_CALLS).length / FILTER_FRAMEWORK_FUNCTIONS(ALL_CALLS).length * 100;
}

/** Uncovered functions and calls **/
function GET_UNCOVERED_FUNCTIONS() {
    return ALL_FUNCTIONS.filter(function(func) {
        return COVERED_FUNCTIONS.indexOf(func) === -1;
    });
}

function GET_UNCOVERED_CALLS() {
    return ALL_CALLS.filter(function(call) {
        return COVERED_CALLS.indexOf(call) === -1;
    });
}

/** Utility functions **/
function FILTER_FRAMEWORK_FUNCTIONS(locations) {
	return locations.filter(function(location) {
		return SOME_PATTERN_MATCHES_LOCATION(location);
	});
}

function FILTER_NON_FRAMEWORK_FUNCTIONS(locations) {
	return locations.filter(function(location) {
		return !SOME_PATTERN_MATCHES_LOCATION(location);
	});
}

function SOME_PATTERN_MATCHES_LOCATION(location) {
	//For example /jquery-1.6.2.js@\d+:\d+-\d+/
	var frameworkPatterns = [];
	return frameworkPatterns.some(function(frameworkPattern) {
		return frameworkPattern.test(location);
	});
}

function ADD_DYNAMIC_CALL_GRAPH_EDGE(base, target) {
    if (CALL_MAP[base] === undefined) CALL_MAP[base] = [];
    if (CALL_MAP[base].indexOf(target) === -1) {
    	CALL_MAP[base].push(target);
    }
}