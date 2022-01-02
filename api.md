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
response: auth_token: String
```

## POST `/register`
```
request: {
    username: String,
    password: String,
}
response: auth_token: String
```

## PATCH `/account`
```
request: auth_token
{
    username: String,
    password: String,
}
response: none
```

## GET `/username`
```
request: auth_token
response: String
```

# Search & get

## GET `/query/?query&tags&start&limit`
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

## PUT `/userData`
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

## GET `/userData`
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

## DELETE `/userData`
```
request: auth_token
String // url
response: none
```
