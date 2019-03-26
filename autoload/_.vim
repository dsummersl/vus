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
    let l:Hashfn = a:1
  else
    let l:Hashfn = function('vus#internal#dfltmemo')
  endif
  let l:result = { 'data': { 'hits': 0, 'misses': 0},
        \'fn': a:fn,
        \'hash': l:Hashfn
        \}
  function l:result.clear() dict
    let self.data = { 'hits': 0, 'misses': 0}
  endfunction
  function l:result.call(...) dict
    let hash = self.hash(a:000)
    if !has_key(self.data,hash)
      let self.data[hash] = call(self.fn,a:000)
      let self.data['misses'] += 1
    else
      let self.data['hits'] += 1
    endif
    return self.data[hash]
  endfunction
  return l:result
endfunction

" Return the maximum value of a list or dictionary.
"
" Parameters:
"      list: a list or dictionary.
"  selector: (optional). One of:
"  - string: will be evaluated. Variables 'el' (current element from the
"            list), 'i' (index of the element), and 'list' (the list) are provided.
"  - TODO funcref: A function with three parameters: el, i, list.
"
" When 'list' is a dictionary, returns the key with the max value.
function! _#max(list,...)
  return vus#internal#minmax(a:list,'max',a:000)
endfunction

" Return the minimum value of a list or dictionary.
"
" Parameters:
"      list: a list or dictionary.
"  selector: (optional). One of:
"  - string: will be evaluated. Variables 'el' (current element from the
"            list), 'i' (index of the element), and 'list' (the list) are provided.
"  - TODO funcref: A function with three parameters: el, i, list.
"
" When 'list' is a dictionary, returns the key with the min value.
function! _#min(list,...)
  return vus#internal#minmax(a:list,'min',a:000)
endfunction

" Reduce a list down to one value.
"
" Parameters:
"   list: list or dictionary.
"   func: reduction function (funcref). TODO support a string as well as a funcref.
"   memo: initial value of the reduction.
"
" When 'list' is a list:
"   The run is provided with 'el', 'i', 'list' and 'memo'
"   (current value of the reduction). Must return the new value of the
"   reduction.
"
" When 'list' is a dictionary:
"   The function is provided 'key', 'val', 'list' and 'memo'
"
function! _#reduce(list,func,memo)
  " if its a list:
  if type(a:list) == 3
    let length = len(a:list)
    for i in range(length)
      call a:func(a:list[i],i,a:list,a:memo)
    endfor
    return a:memo
  elseif type(a:list) == 4
    let dict = a:list
    for key in keys(a:list)
      let val = a:list[key]
      call a:func(key,val,dict,a:memo)
    endfor
    return a:memo
  else
    throw 'List must be a List or Dictionary.'
  endif
endfunction

" Add up all the elements in a list.
"
" Returns:
"   - the sum of the list.
function! _#sum(list)
  let s:sum = 0
  for i in a:list
    let s:sum += i
  endfor
  return s:sum
endfunction

" Sort a list.
"
" Parameters:
"
"            list: a list.
"
"   sort function: (optional) if... 
"                  - A string (that is evaluated) where 'a' and 'b' must be
"                    compared and returned (see Vim's sort() method).
"                  - A function (with two params, a and b).
"                  - A funcref and a dictionary (see Vim's sort()).
"                  - number 1. sort with ignorecase.
"                  - number 2. try to convert strings to numbers and sort
"                    numerically
"
"            dict: (optional) dictionary related to 'sort function' (see sort())
" 
" Returns: sorted list.
function! _#sort(list,...)
  if exists('a:2')
    " if its a funcref
    return sort(a:list,a:1,a:2)
  elseif exists('a:1')
    " when its a number
    if type(a:1) == 0
      if a:1 == 1
        return sort(a:list,1)
      elseif a:1 == 2
        return _#sort(a:list,'str2nr(a) == str2nr(b) ? 0 : str2nr(a) > str2nr(b) ? 1 : -1')
      else
        throw 'Unknown numerical sort type: only 1 and 2 are supported.'
      endif
    " if its a string
    elseif type(a:1) == 1
      " the cmpstr is a string representation of the comparison function (which
      " will use a/b to do the comparison:
      let b:cmpstr = a:1
      function! CmpStrFunc(a,b)
        let a = a:a
        let b = a:b
        exec "return ". b:cmpstr
      endfunction
      let result = sort(a:list,function("CmpStrFunc"))
      unlet b:cmpstr
      return result
    " if its a funcref
    elseif type(a:1) == 2
      return sort(a:list,a:1)
    else
      throw '2nd parameter must be a string or funcref.'
    endif
  elseif exists('a:2')
    throw 'Only up to two parameters are supported.'
  endif
  return sort(a:list)
endfunction

" Return the unique elements in a list.
"
" TODO document and support hashes?
" TODO support a funcref?
"
" Parameters: A list.
"
" Returns: A new list, with the unique elements from a:list.
function! _#uniq(list)
  let l:result = []
  for l:i in a:list
    if count(l:result,l:i) == 0
      call add(l:result,l:i)
    endif
  endfor
  return l:result
endfunction


" Restrict a function so that it is called only once within *wait* ms.
"
" Parameters:
"  * fn: a funcref.
"  * wait: ms at most that it will be called.
"
" Returns: A throttled funcref.
function! _#throttle(fn, wait) abort
  let l:result = {
        \'data': {'lastcall': 0, 'lastresult': 0, 'wait': a:wait / 1000.0},
        \'fn': a:fn
        \}
  function l:result.call(...) dict
    let l:lastcall = self.data.lastcall 
    if type(l:lastcall) == 0 || reltimefloat(reltime(l:lastcall)) > self.data.wait
      let self.data.lastcall = reltime()
      let self.data.lastresult = call(self.fn,a:000)
    endif
    return self.data.lastresult
  endfunction
  return l:result
endfunction
