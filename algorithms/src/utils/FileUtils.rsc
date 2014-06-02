module utils::FileUtils

import String;

//TODO: rename IOUtils

@javaClass{utils.JavaUtils}
@reflect
public java void copyFile(loc sourceLoc, loc targetLoc);

@javaClass{utils.JavaUtils}
@reflect
public java str executeSloc(str path);

public int countSloc(list[loc] paths) {
	return (0 | it + countSloc(path)| loc path <- paths);
}

public int countSloc(loc path) {
	str uri = path.uri;
	if (/file:\/\/<path:.*>/ := uri) {
		return countSloc(replaceAll(path, "%20", " "));
	}
	throw "Not a file:// authority";
}

public int countSloc(str path) {
	str slocReturn = executeSloc(path);
	if (/.*lines of source code : \s<sloc:\d+>.*/ := slocReturn) {
		return toInt(sloc);
	}
	throw "No valid sloc returned. Is the SLOC command tool installed? <|http://www.tinyurl.com/sloctool|>";
}