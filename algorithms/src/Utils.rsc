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