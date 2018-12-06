# Sessions

The session data is used to identify a user using cookies, in the cookie we store an ID and tied that ID to a record in the database.

When a user login on Zera, we stored in the user session the user identification that can be used later on another requests, you can also create another entries:

#### Default session vars
- user_id (Int)
- name (String)
- email (String)
- is_admin (0/1)
- keep_loged (0/1)


##### Get session data
Get the session data by its name. If not found return an empty string.
```perl
$self->sess('name');
```

##### Set session data
Set session data by name. If the session data already exists, it would be overwritten, if not it would be created.
```perl
$self->sess('name','value');
```
##### General notes
The data is stored in the database, it is tied to the user's browser cookie. If the user logs out, the session's data gets cleared, also if the user deletes it's cookies, then the tie will be lost and the user will need to login again.
