console.log __filename
console.log __dirname

a = [1, 2, 3, 4, 5]
for i in [0..a.length-1]
  console.log a[i]
  break if i is 2
