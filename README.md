Efficient Approximate JavaScript Call Graph Construction - replication study
===============================
In this Github repository the sources of the algorithms created by Sander Benschop for his master research project can be found. This master research project is a replication of a study performed by [Feldthaus et al](http://dl.acm.org/citation.cfm?id=2486887 "").

Installation
------------
This Github repository contains two folders at the root level: algorithms and grammar. The first contains the algorithms created for this study by me, the second contains the JavaScript 

Usage
-----

### Static call graph
To create a static call graph, load the staticanalysis/Main module in the Rascal console and either call the function createPessimisticCallGraph or createOptimisticCall graph. These functions take a (list of) Rascal locations as input. Pass the JavaScript files that need to be analyzed in here. The main module also contains some other functions for creating flow graphs if desired. The static call graphs can be persisted by using Rascal's writeBinaryValueFile function.

### Dynamic call graph
To create a dynamic call graph, load the dynamicanalysis/DynamicCallGraphRewriter module in the Rascal console. Call the function rewrite with a Rascal location as an argument. This can either be a file or a folder. In the last case, all JavaScript files that are recursively found are rewritten and all other files are copied normally. If desired, the overloaded method with two extra parameters can be called to specify files that need to be completely ignored by the rewriter and framework files for which the functions should be annotated but the call sites should not. Some frameworks don't work after rewriting the call sites, like Mootools and Prototype. 

When the rewriter is done, the results can be retrieved from the dynamicanalysis/filedump folder. The newly created file instrumentationCode.js needs to be included into the HTML file before all other JavaScript files.

To only measure the coverage of non-framework functions, it is necessary to adapt the SOME_PATTERN_MATCHES_LOCATION function in the instrumentationCode.js file. Add some regex patterns to match the framework files here.

After manually executing the program, the coverage can be measured by calling the GET_FUNCTION_COVERAGE_PERCENTAGE and GET_CALL_COVERAGE_PERCENTAGE from the developer console of the browser. If the coverage is sufficient, the call graph can be copied as JSON into the clipboard by using copy(CALL_MAP).

