module utils::StringUtils

import String;

public str removeLayout(str source) {
	str trimmed = replaceAll(source, "\n", "");
	trimmed = replaceAll(trimmed, "\t", "");
	trimmed = replaceAll(trimmed, " ", "");
	return trimmed;
}

public str convertToDynamicTarget(str source) {
	if (contains(source, "//Function augmented") || contains(source, "//Call augmented")) {
		return ""; //Definately not a native call target.
	}
	str replaced = escape(source,  ("\'" : "\\\'"));
	return removeNewLines(replaced);
}

public str removeNewLines(str source) {
	return replaceAll(source, "\n", "");
}
