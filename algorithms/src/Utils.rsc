module Utils

import List;
import ParseTree;

list[tuple[&T first, &U second]] unbalancedZip(list[&T] a, list[&U] b) {
	int sizeA = size(a), sizeB = size(b);
	if (sizeA > sizeB) {
		return zip(a[0..sizeB], b);
	} else if (sizeA < sizeB) {
		return zip(a, b[0..sizeA]);
	}
	return zip(a, b);
}

public list[Tree] iterableToTreeList(elements) = [element | element <- elements];

public str formatLoc(loc location) {
	try file = location.file; catch : file = "mockup.nojs";	
	int lineNumber = location.begin.line;
	int columnStart = location.offset;
	//The tool used by the original authors doesn't show multiple lines but just puts it one one big line like this.
	int columnEnd = columnStart + location.length;
	return "<file>@<lineNumber>:<columnStart>-<columnEnd>";
}