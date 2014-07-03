function Promise(message) {
    this.message = message;
}

Promise.prototype = {
    set data(value) {
    	console.log("Old: " + this.message);
        this.message = value;
    },
    get data() {
    	console.log("Returning :" + this.message);
    	return this.message;
    }
};