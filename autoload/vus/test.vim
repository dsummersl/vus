function! Sum(a,b)
  let b:calls += 1
  return a:a+a:b
endfunction

function! Callback()
  let b:calls += 1
  return 'cb'
endfunction

function! TestThrottleTrailing()
  let b:calls = 0
  let throttle_fn = _#throttle(function('Callback'), 50, 0)
  call VUAssertEquals(throttle_fn.call(), '<throttled>')
  call VUAssertEquals(throttle_fn.call(), '<throttled>')

  sleep 50m

  call VUAssertEquals(b:calls,1)
  call VUAssertEquals(throttle_fn.lastresult(),'cb')
endfunction

function! TestThrottleLeading()
  let b:calls = 0
  let ThrottledFn = _#throttle(function('Callback'), 50)
  call ThrottledFn.call()
  call ThrottledFn.call()
  call VUAssertEquals(b:calls,1)

  sleep 50m

  call VUAssertEquals(b:calls,1)

  call ThrottledFn.call()
  call VUAssertEquals(b:calls,2)
endfunction

function! TestThrottleLeadingNoThrottling()
  let b:calls = 0
  let ThrottledFn = _#throttle(function('Callback'), 50)

  call ThrottledFn.call()
  call VUAssertEquals(b:calls,1)
  sleep 75m

  call ThrottledFn.call()
  call VUAssertEquals(b:calls,2)
  sleep 75m
endfunction

function! TestMemoize()
  let b:calls = 0
  let sumfn = _#memoize(function('Sum'))
  call VUAssertEquals(sumfn.call(1,3),4)
  call VUAssertEquals(sumfn.data['hits'],0)
  call VUAssertEquals(sumfn.data['misses'],1)

  call VUAssertEquals(sumfn.call(1,3),4)
  call VUAssertEquals(sumfn.call(2,3),5)
  call VUAssertEquals(sumfn.data['hits'],1)
  call VUAssertEquals(sumfn.data['misses'],2)

  call sumfn.clear()
  call VUAssertEquals(sumfn.call(2,3),5)
  call VUAssertEquals(sumfn.data['hits'],0)
  call VUAssertEquals(sumfn.data['misses'],1)
endfunction


function! TestMap()
 	call VUAssertEquals(sort(_#map({'a': 5, 'b': 6},'let result = val')),sort([5,6]))
endfunction

function! TestUniq()
	call VUAssertEquals(_#uniq([]),[])
	call VUAssertEquals(_#uniq([1,2,3]),[1,2,3])
	call VUAssertEquals(_#uniq([3,2,1]),[3,2,1])
	call VUAssertEquals(_#uniq([3,2,1,2,3]),[3,2,1])
	call VUAssertEquals(_#uniq(['onea','oneb','onea']),['onea','oneb'])
endfunction

function! TestSort()
	call VUAssertEquals(_#sort([]),[])
	call VUAssertEquals(_#sort([1,3,2]),[1,2,3])
	call VUAssertEquals(_#sort(['abc','Adf','aDc'],1),['abc','aDc','Adf'])
	call VUAssertEquals(_#sort(['10','1','2'],2),['1','2','10'])
  call VUAssertEquals(_#sort(['10','1','2'],'str2nr(a) == str2nr(b) ? 0 : str2nr(a) > str2nr(b) ? 1 : -1'),['1','2','10'])
endfunction

function! TestMinMax()
  try
    _#min([])
    call VUAssertTrue(0)
  catch /.*/
    " an exception is thrown: there is no min in an empty list.
  endtry

  call VUAssertEquals(_#min([1]),1)
  call VUAssertEquals(_#min([1,5]),1)
  call VUAssertEquals(_#min([12,6,1]),1)

  call VUAssertEquals(_#max([1]),1)
  call VUAssertEquals(_#max([1,5]),5)
  call VUAssertEquals(_#max([12,6,1]),12)

  " el, i, list
  call VUAssertEquals(_#min([{'key': 3},{'key': 1}],'el["key"]'),{'key': 1})
  call VUAssertEquals(_#max([{'key': 3},{'key': 1}],'el["key"]'),{'key': 3})

  call VUAssertEquals(_#min({'keya': 3,'keyb': 1},'val'),'keyb')
  call VUAssertEquals(_#max({'keya': 3,'keyb': 1},'val'),'keya')
endfunction

