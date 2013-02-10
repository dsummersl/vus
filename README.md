VUS
===
An underscore like support library for Vim.

Functions currently implemented. See the source for more details:

 * _#sum()
 * _#map()
 * _#memoize()
 * _#hash()
 * _#uniq()
 * _#sort()
 * _#reduce()
 * _#min()
 * _#max()

Install
====

Drop into your plugins folder, use vundle, or pathogen. 

Testing
====

I used vimunit for testing. If you have it installed, you can run all the tests like so:

    ../vimunit/vutest.sh autoload/vus/test.vim

Requirements:
====

Vim Version 7.3.390+ (patch 29x fixes a lack in the sort() function that
several functions in this library require). '+python' support is also required.
