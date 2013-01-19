" the default memoization hashing function.
function! vus#internal#dfltmemo(args)
  return _#hash(string(a:args))
endfunction
