module Configuration


//If set to true, edges in named functions will be from Function --> Parameter if the function
//is declared in the global scope. If not, an edge from Function --> Variable will be created as
//is described in the paper;
public bool globalFunctionAsProperties = true;

//If set to true, only call targets are taken into account when measuring performance and recall
//In the paper it seems that this is what they've done.
//It does repress information however, which helps to increase the precision.
public bool compareCallTargetsOnly = true;

//If set to true, native functions are not counted when comparing call graphs.
public bool filterNativeFunctions = false;

//Settings used for analysis: globalFunctionAsProperties = true, compareCallTargetsOnly = true/false in two runs, filterNativeFunctions = false