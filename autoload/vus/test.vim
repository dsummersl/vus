function! Sum(a,b)
  let b:calls += 1
  return a:a+a:b
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
