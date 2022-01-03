- 200 if okay
- 401 if unauthorized
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

## GET `/query/?query&seasons&genres&start&limit`
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
    img_url: String
    episodes: int
    seasons: [int]
    genres: [String]
    status: String
}
```

# User data

## PUT `/user/film`
```
request: auth_token
{
    url: String,
    data: {
        // arbitary json object.
    }
}
response: none
```

## GET `/user/film`
```
request: auth_token
response: [
    {
        url: String,
        data: {
            // arbitary json object.
        }
    }
]
```

## DELETE `/user/film`
```
request: auth_token
String // url
response: none
```

## PUT `/user/data`
request: auth_token
{
    // arbitary json object
}
response: none

## GET `/user/data`
request: auth_token
response: {
    // arbitary json object
}
