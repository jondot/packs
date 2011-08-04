packs
=====
A open source [BoxJS](http://boxjs.com/)/[CSS](http://boxcss.com/)/[Etc](http://boxresizer.com/) implementation compatible with existing Box* interface. You can mount each of those as rack app inside Rails, or separately as a stand-alone application.  
It is fully compatible with Heroku.

Usage
-----

    $ cp config.css.ru config.ru
    $ rackup



or

    $ cp config.js.ru config.ru
    $ rackup

or

    $ cp config.img.ru config.ru
    $ rackup



Update: now deployed at heroku, see examples:

packjs: [http://packjs.heroku.com/?host=http://blog.paracode.com/&include=js/jquery.js,js/jquery.noisy.js](http://packjs.heroku.com/?host=http://blog.paracode.com/&include=js/jquery.js,js/jquery.noisy.js)  
with CoffeeScript: [http://packjs.heroku.com/?host=http://p.mnmly.com/&include=file-api/src/coffee/script.coffee,file-api/js/handlebars-0.9.0.pre.5.js](http://localhost:9292/?host=http://p.mnmly.com/&include=file-api/src/coffee/script.coffee,file-api/js/handlebars-0.9.0.pre.5.js)  


packcss: [http://packcss.heroku.com/?host=http://blog.paracode.com/&include=css/main.css,css/coderay.css
](http://packcss.heroku.com/?host=http://blog.paracode.com/&include=css/main.css,css/coderay.css
)  
with sass: [http://packcss.heroku.com/?host=http://technocrat.net&include=/stylesheets/standard1.sass,/stylesheets/kai.css](http://localhost:9292/?host=http://technocrat.net&include=/stylesheets/standard1.sass,/stylesheets/kai.css)  


packimg: [http://packimg.heroku.com/?source=http://n5.nabble.com/images/avatar100.png&resize=20x20&format=gif&flip=vertical](http://packimg.heroku.com/?source=http://n5.nabble.com/images/avatar100.png&resize=20x20&format=gif&flip=vertical)

More to come soon.

Stay tuned, [@jondot](http://twitter.com/jondot), [+Dotan Nahum](http://gplus.to/dotan).






Contributing to packs
=====================

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
=========

Copyright (c) 2011 Dotan Nahum. See LICENSE.txt for
further details.


