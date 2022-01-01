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

## PATCH `/account`
```
request: {
    username: String,
    password: String,
}
response: none
```

# Search

## GET `/query/?title&tag&rangeStart&rangeEnd`
```
request: none
response: [
    String // url
]
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

## DELETE `\userData`
```
request: auth_token
String // url
response: none
```
