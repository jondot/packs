	/*
	*  PackJS - an open source BoxJS clone. Derived from BoxJS.
	*  Dotan Nahum, @jondot.
	*	
	*  BoxJS - A simple package management service
	*	http://boxjs.com
	*
	*	Author: Simon - @blinkdesign
	* 	Version: 1.0.1
	*/

	!function( window ) {
		
		var globalRoot,
			oString = Object.prototype.toString,
			defaults = {
				dev : false, 
				minify : true, 
				version : 1, 
				cache : true,
				append : true,
				defer : false,
				host: 'http://localhost:4567'
			};
		
		/**
		* Implements native indexOf if browser does not support
		* https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Array/indexOf
		*/
		if ( !Array.prototype.indexOf ) {

			Array.prototype.indexOf = function( searchElement ) {

				'use strict';

				if (this === void 0 || this === null)
					throw new TypeError();

				var t = Object(this);
				var len = t.length >>> 0;
				if (len === 0)
				 	return -1;

				var n = 0;
				if (arguments.length > 0) {
					n = Number(arguments[1]);
				if (n !== n)
				   	n = 0;
				else if (n !== 0 && n !== (1 / 0) && n !== -(1 / 0))
				   	n = (n > 0 || -1) * Math.floor(Math.abs(n));
				}

				if (n >= len)
					return -1;

				var k = n >= 0
				     ? n
				     : Math.max(len - Math.abs(n), 0);

				for (; k < len; k++) {
				 	if (k in t && t[k] === searchElement)
				   	return k;
				}

				return -1;

			};

		}

		/** 
		* Check to see if Box defined as global config object
		*/
		if ( !isFunction( window.Box ) ) {
			
			// Extract the globalRoot
			if ( window.Box && typeof window.Box.root == 'string' ) {

				globalRoot = window.Box.root;
				delete window.Box.root;
				defaults = extend( window.Box, defaults );

			}
			
		}		
		
		/**
		* Constructs a Box object
		*/
		var Box = function( root, files, options ) {			

			var defaultsCopy, url, loOptions, loFiles, loRoot;
						
			// Box can be called without 'new' prefix
			if ( !(this instanceof Box) ) return new Box( root, files, options );			

			// Make globalRoot a static property
			if ( globalRoot ) Box.globalRoot = globalRoot;

			// No args? Exit
			if ( !arguments[0] && !arguments[1] && !arguments[2] ) return this;

			// Allows array to be passed as first argument
			if ( isArray( root ) ) {
				
				options = files;
			    files = root;
                root = undefined;

            }
			
			// Merge options - Take a copy of defaults first
			defaultsCopy = extend( this.defaults );
			loOptions = this.options = extend( options, defaultsCopy );
			
			loRoot = this.root = setRoot( root );
			loFiles = this.files = checkLoadedFiles( files );
			
			if ( typeof loRoot == 'string' && loFiles.length > 0 ) {

				url = this.defaults.host+'?host=' + loRoot + '&include=' + loFiles.join(',') + '&minify=' + loOptions.minify + '&version=' + loOptions.version + '&cache=' + loOptions.cache;
			
			// No globalRoot or just set to false, so assume files have full urls	
			} else if ( !loRoot && loFiles.length > 0 ) {
				
				url = this.defaults.host+'?include=' + loFiles.join(',') + '&minify=' + loOptions.minify + '&version=' + loOptions.version + '&cache=' + loOptions.cache;

			}

			this.url = url;
			
			if ( !loOptions.defer ) this.get();	
				
		};

		Box.prototype = {

			defaults : defaults,

			/**
			* Fetch scripts, add to DOM and allow for dev mode.
			*/
			get : function() {

				var options = this.options, 
					files = this.files;

				if ( !options.dev ) {

					addScript( this.url, options.append );
				
				} else {
					
					for ( script in files ) {
						
						addScript( this.root + files[script], options.append );
						
					}
					
				}

			}

		}
		
		Box.prototype.constructor = Box;
		Box.loadedFiles = [];
		Box.version = '1.0.1';	
		
		/**
		* Determines different outcomes for the URL root
		*/
		function setRoot( root ) {
			
			// Setting root to false allows overriding of globalRoot 
			// and using full URLs in files array
			if ( root == false && Box.globalRoot ) {
				
				root = false;
			
			// No root passed but have a global, so use that 	
			} else if ( root == undefined && Box.globalRoot ) {

				root = Box.globalRoot;
				
			
			} // If neither condition evaluates to true, assume root was a URL string and return it
			
			return root;
			
		}

		/**
		* Compare what has been requested with what has been loaded already. Remove duplicates
		*/
		function checkLoadedFiles( files ) {

			var loadedFiles = Box.loadedFiles,
				checkedFiles = [];

			// Prevent error if no files are passed
			if ( !files ) files = [];
			
			for ( var i = 0, len = files.length; i < len; i++ ) {

				// Check if file is loaded already, if not add it to checkedFiles array
				if ( loadedFiles.indexOf( files[i] ) === -1 ) checkedFiles.push( files[i] );

			}		
			
			// Keep track of what user has loaded
			loadedFiles = combineArray( loadedFiles, files );

			return checkedFiles;
			
		}
		
		/**
		* Add script element to DOM
		*/
		function addScript( url, append ) {
			
			if ( append ) { 
				
				var script = document.createElement('script'); 
				script.src = url;
				
				document.body.appendChild( script );
			
			} else {
			
				document.write( unescape('%3Cscript src="' + url +'"%3E%3C/script%3E') );
				
			}

		}
		
		/** 
		* Type helpers 
		*/
		function isArray( item ) {
			return oString.call( item ) === '[object Array]'; 
		}

		function isFunction( item ) {
	        return oString.call( item ) === '[object Function]';
	    }
		
	
		/**
		* Merges two objects using a deep copy
		*/
		function extend( source, target ) {

			target = target || {}; 

			for ( var i in source ) {

				if ( typeof source[i] === 'object' ) { 

					target[i] = ( source[i].constructor === Array ) ? [] : {}; 
					
					extend( source[i], target[i] );

				} else { 

					target[i] = source[i];

				} 

			} 

			return target;

		}	
		
		/**
		* Combine two arrays, but don't merge duplicates
		*/
		function combineArray( target, source ) {

			for ( var i = 0, len = source.length; i < len; i++ ) {

				if ( target.indexOf( source[i] ) == -1 ) target.push( source[i] );

			}

			return target;

		}
		
		window.Box = Box;

	}( window );
	
