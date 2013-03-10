
Basic building blocks for computational design projects in JavaScript. 
Written in CoffeeScript for browser and server environments.


Note
====

This is my latest attempt at combining useful computational design tools with core packages like Math, Colour and Physics 
into one cohesive library. I gave up on earlier projects either due to a lack of time or because the implementation language
had to change and so on.

As our projects start to converge more and more towards using web tools, 
also in browser-less e.g. installation and generative projects, it seemed like a good idea to give this bundeling attempt another go.

Because of all this, please bear in mind that the codebase will change a lot for the next couple versions!


Build
=====

Simply build with ```$ make build``` and use the library in your Node/ CommonJS project.


Development
===========

Working with a library in development e.g. fieldkit.

Set up NPM to store packages under user folder
```
$ vi ~/.npmrc
prefix = /Users/marcus/Documents/Development/npm
```

Adjust PATH to find binaries installed with NPM
```
$ vi ~/.profile
export PATH=$PATH:/Users/marcus/Documents/Development/npm/bin/
```

Clone library
```
$ git clone git@github.com:field/FieldKit.git
$ cd FieldKit
```

Create NPM package link
```$ npm link```

In Composer project dir - link library into project
```$ npm link fieldkit```

further reading on 
http://justjs.com/posts/npm-link-developing-your-own-npm-modules-without-tears


TODO
====

[] standardize .toString results
[] decide on package format (simulation, physics, maths packages?)
[] templated example library
[] look into automated documentation generators e.g literal coffeescript or doccu
[] find automated test tool
[] start writing automated test


Credits
=======

Released under the BSD license.  Full details in the included LICENSE file.

(c) 2013, Marcus Wendt <marcus@field.io>

