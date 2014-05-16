var THISREFERENCE = this;
var LAST_CALL_LOC = undefined;
var CALL_MAP = {};
var ALL_FUNCTIONS = [$$allFunctionsJoined$$];
var COVERED_FUNCTIONS = [];
var ALL_CALLS = [$$allCallsJoined$$];
var COVERED_CALLS = [];
var CALL_STACK = [];

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

function MERGE_COVERED_FUNCTIONS(NEW_COVERED_FUNCTIONS) {
    COVERED_FUNCTIONS = COVERED_FUNCTIONS.concat(NEW_COVERED_FUNCTIONS);
}

function MERGE_COVERED_CALLS(NEW_COVERED_CALLS) {
    COVERED_CALLS = COVERED_CALLS.concat(NEW_COVERED_CALLS);
}

function MERGE_CALL_MAP(NEW_CALL_MAP) {
    for (var PROPERTY in NEW_CALL_MAP) {
        if (CALL_MAP[PROPERTY]) {
            //Merge arrays
            CALL_MAP[PROPERTY] = CALL_MAP[PROPERTY].concat(NEW_CALL_MAP[PROPERTY]);
        } else {
            CALL_MAP[PROPERTY] = NEW_CALL_MAP[PROPERTY];
        }
    }
}

function STRINGIFY(obj) {
    var t = typeof (obj);
    if (t != "object" || obj === null) {
// simple data type
        if (t == "string") obj = '"' + obj + '"';
        return String(obj);
    } else {
// recurse array or object
        var n, v, json = [], arr = (obj && obj.constructor == Array);

        for (n in obj) {
            v = obj[n];
            t = typeof(v);
            if (obj.hasOwnProperty(n)) {
                if (t == "string") v = '"' + v + '"'; else if (t == "object" && v !== null) v = STRINGIFY(v);
                json.push((arr ? "" : '"' + n + '":') + String(v));
            }
        }
        return (arr ? "[" : "{") + String(json) + (arr ? "]" : "}");
    }
}