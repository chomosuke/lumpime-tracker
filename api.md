- 200 if okay
- 204 if already deleted or not found
- 401 if unauthorized
- 404 if not found
- 409 if conflict

# Account

## POST `/login`
```
request: {
    username: String,
    password: String,
}
response: String // auth_token
```

## POST `/register`
```
request: {
    username: String,
    password: String,
}
response: String // auth_token
```

## PATCH `/user`
```
request: auth_token
{
    username?: String,
    password?: String,
}
response: none
```

## GET `/username`
```
request: auth_token
response: String
```

# Search & Get

## GET `/meta`
```
request: none
response: {
    newest: int
    genres: [String]
}
```

## GET `/query/?query&seasons&genres&start&limit&nsfw`
// seasons & genres will be seperated by ,
```
request: none
response: [String] // id
```

## GET `/film/:id`
```
request: none
response: {
    url: String
    name: String
    alt_names: [String]
    english: String
    img_url: String
    episodes: int
    seasons: [int]
    genres: [String]
    status: String
}
```

# User Film Data

## PUT `/user/film/:id`
```
request: auth_token
{
    // arbitary json object.
}
response: none
```

## GET `/user/film/:id`
```
request: auth_token
response: {
    // arbitary json object.
}
```

# Film List

## POST `/user/filmList`
```
request: auth_token
String // key
response: none
```

## GET `/user/filmLists`
```
request: auth_token
response: [String] // keys
```

## DELETE `/user/filmList/:key`
```
request: auth_token
response: none
```

## POST `/user/filmList/item/:key`
```
request: auth_token
String // id
response: none
```

## GET `/user/filmList/items/:key`
```
request: auth_token
response: [String] // ids
```

## DELETE `/user/filmList/item/:key/:id`
```
request: auth_token
response: none
```

## PUT `/user/filmList/items/:key`
```
request: auth_token
[String] // ids
response: none
```
