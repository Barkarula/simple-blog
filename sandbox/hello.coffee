test = ->
  a = {}
  a.a = 'a'
  # a.b = 'b'
  a.hasErrors = if a.a or a.b then true else false
  return a.hasErrors

console.log test()