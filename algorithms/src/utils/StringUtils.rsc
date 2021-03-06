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
	replaced = replaceAll(replaced, "\n", "");
	replaced = regexReplace(replaced, "\\(.*\\)$", "");
	
	return removeNewLines(replaced);
}

public str removeNewLines(str source) {
	return replaceAll(source, "\n", "");
}

@javaClass{utils.JavaUtils}
@reflect
public java str regexReplace(str source, str pattern, str replacement);
