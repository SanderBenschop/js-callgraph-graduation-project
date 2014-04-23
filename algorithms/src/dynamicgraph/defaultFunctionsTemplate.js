var THISREFERENCE = this;
var LAST_CALL_LOC = undefined;
var CALL_MAP = {};
var ALL_FUNCTIONS = [$$allFunctionsJoined$$];
var COVERED_FUNCTIONS = [];
var ALL_CALLS = [$$allCallsJoined$$];
var COVERED_CALLS = [];
var ALL_FUNCTION_EXPRESSIONS = {$$allFunctionExpressions$$};

function GET_UNCOVERED_FUNCTIONS() {
    return ALL_FUNCTIONS.filter(function(func) {
        return COVERED_FUNCTIONS.indexOf(func) === -1;
    });
}
function GET_FUNCTION_COVERAGE_PERCENTAGE() {
	return COVERED_FUNCTIONS.length / ALL_FUNCTIONS.length * 100;
}

function GET_UNCOVERED_CALLS() {
    return ALL_CALLS.filter(function(call) {
        return COVERED_CALLS.indexOf(call) === -1;
    });
}
function GET_CALL_COVERAGE_PERCENTAGE() {
	return COVERED_CALLS.length / ALL_CALLS.length * 100;
}

function ADD_DYNAMIC_CALL_GRAPH_EDGE(base, target) {
    if (CALL_MAP[base] === undefined) CALL_MAP[base] = [];
    if (CALL_MAP[base].indexOf(target) === -1) {
    	CALL_MAP[base].push(target);
    }
}

//Source: StackOverflow
//http://stackoverflow.com/questions/6598945/detect-if-function-is-native-to-browser
function IS_NATIVE_FUNCTION(f) {
   return !!f && (typeof f).toLowerCase() == 'function' 
   && (f === Function.prototype 
   || /^\s*function\s*(\b[a-z$_][a-z0-9$_]*\b)*\s*\((|([a-z$_][a-z0-9$_]*)(\s*,[a-z$_][a-z0-9$_]*)*)\)\s*{\s*\[native code\]\s*}\s*$/i.test(String(f)));
}