topic1 = 
  name: "T1"
  id: 100

topic2 =
  name: "aT2"
  id: 20

topics = []
topics.push topic1
topics.push topic2

topics.sort (x, y) ->
  titleA = x.name.toLowerCase()
  titleB = y.name.toLowerCase()
  return -1 if titleA < titleB
  return 1 if titleA > titleB
  return 0

console.log topics
