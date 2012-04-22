# obj1 = '"obj1": { "name": "summer", "age": 10 }'
# obj2 = '"obj2": { "name": "mac", "age": 9 }'

# text = "{" + "#{obj1}, #{obj2}" + "}"

# console.log text

# data = JSON.parse text
# console.log data
# console.log data.obj2.name

obj1 = '{ "id": 1, "title": "first blog post", "content": "blah 111 blah blah" }'
obj2 = '{ "id": 2, "title": "second blog post", "content": "blah 222 blah blah" }'

text = '{ "topics": [' + obj1 + ", " + obj2 + ']}'
console.log text

data = JSON.parse text
console.log data
console.log data.topics[0].title

