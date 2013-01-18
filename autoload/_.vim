function! _#sum(list)
  let sum = 0
  for i in a:list
    let sum += i
  endfor
  return sum
endfunction
