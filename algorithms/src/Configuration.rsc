module Configuration


//If set to true, edges in named functions will be from Function --> Parameter if the function
//is declared in the global scope. If not, an edge from Function --> Variable will be created as
//is described in the paper;
public bool globalFunctionAsProperties = true;