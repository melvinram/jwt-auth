# JWT Auth

This app is an exploration of how to implement JWT authentication in a Rails app that will power a React app. Security is a top concern. After researching online, [The Ultimate Guide to handling JWTs on frontend clients](https://hasura.io/blog/best-practices-of-using-jwt-with-graphql/) seems to offer the best advice and that article is what most of this exercise will be focused on implementing. After an initial version is working, I'm going to use it to talk about it with friends that know a lot more about security than I do and will also try to hack it/break it.

## Requirements

How should this work?

### Login

`POST /auth_tokens` - Generates JWT and returns in the response. The JWT generated should be stored in-memory in the React app. The JWT token will need to expire as well so it's not valid forever.

The app will also generate a refresh token and will persist it to the database. This refresh token will be sent back as a `HttpOnly` cookie.

### Authenticated requests

Include the in-memory JWT token as a header to make requests.

This means the Rails app will need a way to validate the JWT tokens being sent in and have a session or session like thing that tells controllers about the context of the request.

### Authenticated requests with invalid token

If the JWT token is not valid (expired or bad value), a `401: Unauthorized` response should be returned. The client will use that as a hint that the user has logged out.

### Authenticated requests with no token

First we will try to refresh the token. If that fails, then ask the user to login again.

### Logout

Remove JWT token from in-memory store of React.
Mark current refresh token for the user as invalid.

### Logout on all devices

Force all tokens expiring after a certain time to be considered invalid.
Mark all refresh tokens for the user as invalid.

### Refreshing the JWT token

`POST /auth/refresh` - This will generate a new JWT token, which will be sent back in the body. It will also generate a new refresh token, which will again be sent back as a `HttpOnly` cookie.
