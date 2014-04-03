function f() {
    var FUNCTION_LOC = "functionCall.js@1:0-23";
    if (CALL_MAP[LAST_CALL_LOC] === undefined) CALL_MAP[LAST_CALL_LOC] = [];
    CALL_MAP[LAST_CALL_LOC].push(FUNCTION_LOC);

    var OLD_LAST_CALL_LOC = LAST_CALL_LOC;
    LAST_CALL_LOC = "functionCall.js@2:16-19";
    g()
    LAST_CALL_LOC = OLD_LAST_CALL_LOC;
}