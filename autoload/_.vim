function! _#sum(list)
  let sum = 0
  for i in a:list
    let sum += i
  endfor
  return sum
endfunction

" Perform a mapping on the dictionary
"
" Parameters:
"   - dictionary: the dictionary to  map to (not modified)
"   - evaluation: A string that is evaluated (via exec "").
"        'key' == the current key in the dictionary
"        'val' == the current value
"        'result' == if set, then included in the results
"     TODO support funcref...if set, then use a function with key/val params.
"
" Returns:
"   - a list of the results
"
"
" Example:
"
" TODO support a function
" call VUAssertEquals(vimunit#util#map({'a': 5, 'b': 6},'let result = val'),[5,6])
function! _#map(dictionary,evaluation)
  let results = []
  for [key,val] in items(a:dictionary)
    exec a:evaluation
    if exists('result')
      call add(results,result)
    endif
    unlet result
  endfor
  return results
endfunction

" Wrap a function with a memoization storage mechanism.
" If the parameters to the function match previous
"
" Parameters:
"   fn     = the funcref of the function that will be memoized.
"   hashfn = (optional) how to compute the hash for a fn hit (defaults to the
"            hash of the parameters passed to the function). the function
"            should take a list of arguments (equal to what is passed to 'fn')
"
" Returns:
"   A callable dictionary with these props/methods:
"    - call() -- take the same params as 'fn'
"    - clear() -- clear the cache
"    - .data['hits'] -- number of cache hits
"    - .data['misses'] -- number of cache hits
"
function! _#memoize(fn,...)
  if exists('a:1')
    let Hashfn = a:1
  else
    let Hashfn = function('mvom#util#location#dfltmemo')
  endif
  let result = { 'data': { 'hits': 0, 'misses': 0},
        \'fn': a:fn,
        \'hash': Hashfn
        \}
  function result.clear() dict
    let self.data = { 'hits': 0, 'misses': 0}
  endfunction
  function result.call(...) dict
    let hash = self.hash(a:000)
    if !has_key(self.data,hash)
      let self.data[hash] = call(self.fn,a:000)
      let self.data['misses'] += 1
    else
      let self.data['hits'] += 1
    endif
    return self.data[hash]
  endfunction
  return result
endfunction
