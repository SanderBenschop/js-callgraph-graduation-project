

var iframe,
    elemdisplay = {};



function actualDisplay( name, doc ) {
    var elem = jQuery( doc.createElement( name ) ).appendTo( doc.body ),

        
        display = window.getDefaultComputedStyle ?

            
            
            window.getDefaultComputedStyle( elem[ 0 ] ).display : jQuery.css( elem[ 0 ], "display" );

    
    
    elem.detach();

    return display;
}


function defaultDisplay( nodeName ) {
    var doc = document,
        display = elemdisplay[ nodeName ];

    if ( !display ) {
        display = actualDisplay( nodeName, doc );

        
        if ( display === "none" || !display ) {

            
            iframe = (iframe || jQuery( "<iframe frameborder='0' width='0' height='0'/>" )).appendTo( doc.documentElement );

            
            doc = ( iframe[ 0 ].contentWindow || iframe[ 0 ].contentDocument ).document;

            
            doc.write();
            doc.close();

            display = actualDisplay( nodeName, doc );
            iframe.detach();
        }

        
        elemdisplay[ nodeName ] = display;
    }

    return display;
}


(function() {
    var a, shrinkWrapBlocksVal,
        div = document.createElement( "div" ),
        divReset =
            "-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box;" +
            "display:block;padding:0;margin:0;border:0";

    
    div.innerHTML = "  <link/><table></table><a href='/a'>a</a><input type='checkbox'/>";
    a = div.getElementsByTagName( "a" )[ 0 ];

    a.style.cssText = "float:left;opacity:.5";

    
    
    
    support.opacity = /^0.5/.test( a.style.opacity );

    
    
    support.cssFloat = !!a.style.cssFloat;

    div.style.backgroundClip = "content-box";
    div.cloneNode( true ).style.backgroundClip = "";
    support.clearCloneStyle = div.style.backgroundClip === "content-box";

    
    a = div = null;

    support.shrinkWrapBlocks = function() {
        var body, container, div, containerStyles;

        if ( shrinkWrapBlocksVal == null ) {
            body = document.getElementsByTagName( "body" )[ 0 ];
            if ( !body ) {
                
                return;
            }

            containerStyles = "border:0;width:0;height:0;position:absolute;top:0;left:-9999px";
            container = document.createElement( "div" );
            div = document.createElement( "div" );

            body.appendChild( container ).appendChild( div );

            
            shrinkWrapBlocksVal = false;

            if ( typeof div.style.zoom !== strundefined ) {
                
                
                div.style.cssText = divReset + ";width:1px;padding:1px;zoom:1";
                div.innerHTML = "<div></div>";
                div.firstChild.style.width = "5px";
                shrinkWrapBlocksVal = div.offsetWidth !== 3;
            }

            body.removeChild( container );

            
            body = container = div = null;
        }

        return shrinkWrapBlocksVal;
    };

})();