var x = {    
    setupfield: function () {
		new Element('DIV', {
		    'id': tileid,
		    'class': 'outer',
		    'styles': {
		        'position': 'absolute',
		        'width': THISREFERENCE.options.tilewidth + 'px',
		        'height': THISREFERENCE.options.tileheight + 'px',
		        'top': (y * THISREFERENCE.options.tileheight) + 'px',
		        'left': (x * THISREFERENCE.options.tilewidth) + 'px',
		        'z-index': 0
		    }
		});
	}
}