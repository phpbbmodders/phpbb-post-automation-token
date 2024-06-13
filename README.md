### Automated phpBB Forum Post Submission and Token Management

This project comprises scripts designed for automating post submissions to a phpBB forum and managing user tokens using Bash and PHP scripts. The tool submits a post as a specific user using a token instead of a username/password. The token is tied to the numeric user ID of the user and is stored in a separate SQLite database, making this an edit-less solution(requires `sqlite3` utility to be installed). The admin simply adds the user via the Bash script. Then, the user needs to add their token to the Bash (curl) script and adjust the message and title, etc. The script uses URL encoding for these values. BBCode can be used since it gets parsed by phpBB when submitted.

### Purpose

The scripts fulfill the following functions:

#### ./submit_post_token.php:
- Enables posting to a phpBB forum as a specified user without session reliance. This script requires invocation by `submit.php`, which validates a secret token for access. The user ID associated with the token is passed from the SQLite database to `submit_post_token.php` for post attribution.

#### ./addtoken.sh:
- Manages user tokens within a SQLite database (userdata.db). It generates secure tokens for designated user IDs and updates existing tokens as needed. It uses OpenSSL, if installed, for generating these tokens, and falls back to /dev/urandom otherwise.

#### ./submit.php:
- Validates a token provided via URL against `userdata.db`. Upon successful validation, `submit.php` includes `submit_post_token.php` to submit posts to the phpBB forum on behalf of authenticated users, ensuring proper token-based authorization and user identification.

#### ./sendtourl.sh:
- Constructs a URL for submitting a post to a phpBB forum using `curl`. It encodes parameters such as token, message content, title, and forum ID, appending them to the URL constructed from specified domain and port settings.

### Additional Clarifications

- **Session Management**: `submit_post_token.php` utilizes phpBB's session management functions (`$user->session_begin()`, `$auth->acl($user->data)`, `$user->setup('')`) to emulate user context for posting, maintaining forum integrity and permissions.

- **Message Parsing**: Before submission, `submit_post_token.php` employs `parse_message` to process and format post content (`$post_text`) with BBCode and other attributes (`$data['message']`, `$data['bbcode_bitfield']`, `$data['bbcode_uid']`), ensuring proper rendering within the forum.

- **Database Interaction**: `submit.php` interacts with `userdata.db` using SQLite3 to validate tokens and retrieve associated user IDs for secure post submissions.

### Apache .htaccess Configuration for Security

To deny access to sensitive files such as `userdata.db`, add the following configuration to your Apache setup:

```
<Files "userdata.db">
    Require all denied
</Files>

<FilesMatch "\.(?i:db)$">
    Require all denied
</FilesMatch>
```

### Nginx Configuration for Security

To deny access to sensitive files such as `userdata.db`, add the following configuration to your Nginx setup:


```
# Deny access to userdata.db directly
location = /userdata.db {
    deny all;
    return 403;
}

# Deny access to any file ending with .db
location ~ \.db$ {
    deny all;
    return 403;
}
```
