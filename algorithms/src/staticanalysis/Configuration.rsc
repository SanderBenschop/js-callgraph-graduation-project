module staticanalysis::Configuration


//If set to true, edges in named functions will be from Function --> Parameter if the function
//is declared in the global scope. If not, an edge from Function --> Variable will be created as
//is described in the paper.
public bool globalFunctionAsProperties = true;

//If set to true, call graphs are analysed by averaging the precision and recall over the call sites.
public bool callSiteAnalysis = true;
	
//If set to true, the intersection of the static and dynamic call graph is used as a divisor rather than the size of the dynamic call graph.
public bool averageOverIntersection = false;

//If set to true, in the edge comparison the static call graph is filtered to remove all call sites not present in the
//dynamic analysis, so only for covered code the precision and recall is calculated.
public bool compareCoveredCodeOnly = true;

//If set to true, native functions are not counted when comparing call graphs.
public bool filterNativeFunctions = false;