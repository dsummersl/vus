" the default memoization hashing function.
function! vus#internal#dfltmemo(args)
  return _#hash(string(a:args))
endfunction

function! vus#internal#minmaxfnc(el,i,list,memo)
  let el = a:el
  let i = a:i
  let key = a:el
  let val = a:i
  let list = a:list
  if has_key(a:memo,'extra')
    call VULog("type of extra = ". type(a:memo['extra']) )
    if type(a:memo['extra']) == 1
      " if a string, evaluate it directly:
      exec "let rval = ". a:memo['extra']
    else
      throw 'Only custom strings are allowed.'
    endif
  else
    let rval = el
  endif
  if a:memo['val'] == '__noval__'
    let a:memo['val'] = rval
    let a:memo['valel'] = el
  else
    if a:memo['op'] == 'min'
      if rval < a:memo['val']
        let a:memo['val'] = rval
        let a:memo['valel'] = el
      endif
    elseif a:memo['op'] == 'max'
      if rval > a:memo['val']
        let a:memo['val'] = rval
        let a:memo['valel'] = el
      endif
    else
      throw "Only min/max operations are supported."
    endif
  endif
endfunction

function! vus#internal#minmax(list,op,extras)
  let memo = { 'val': '__noval__', 'op': a:op }
  if len(a:extras) > 0
    let memo['extra'] = a:extras[0]
  endif
  if len(a:list) == 0
    throw 'No elements in list.'
  endif
  let min = _#reduce(a:list,function('vus#internal#minmaxfnc'),memo)
  if min['val'] == '__noval__'
    throw 'No min found!'
  endif
  return min['valel']
endfunction
