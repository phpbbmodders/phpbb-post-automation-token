<?php
// SQLite database file path
$db_path = 'userdata.db';

// Check if the token, message, title, and forum_id are provided in the URL
if (isset($_GET['token']) && isset($_GET['message']) && isset($_GET['title']) && isset($_GET['forum_id'])) {
    $token = $_GET['token'];
    $message = $_GET['message'];
    $title = $_GET['title'];
    $forum_id = $_GET['forum_id'];

    // Open the SQLite database
    $db = new SQLite3($db_path);

    // Prepare a query to fetch the user ID for the provided token
    $query = $db->prepare("SELECT user_id, token FROM users WHERE token = :token");
    $query->bindValue(':token', $token, SQLITE3_TEXT);

    // Execute the query
    $result = $query->execute();

    // Fetch the user ID and token from the result
    $row = $result->fetchArray(SQLITE3_ASSOC);

    // Close the database connection
    $db->close();

    // Check if the query returned a valid result
    if ($row !== false && isset($row['user_id'], $row['token'])) {
        $user_id = $row['user_id'];
        $stored_token = $row['token'];

        // Validate the provided token against the stored token
        if ($token === $stored_token) {
            // Token is valid, include or redirect to the submit post script with user ID, message, title, and forum_id
            define('RUN_SUBMIT_POST', true);
            define('USER_ID', $user_id); // Pass the user ID to submit_post_token.php
            define('MESSAGE', $message); // Pass the message to submit_post_token.php
            define('TITLE', $title); // Pass the title to submit_post_token.php
            define('FORUM_ID', $forum_id); // Pass the forum_id to submit_post_token.php
            include('submit_post_token.php');
            exit(); // Terminate script execution after including submit_post_token.php
        }
    }

    // Invalid token or user ID not found
    die('Invalid token or user ID not found.');
} else {
    // Token, message, title, or forum_id is not provided
    die('Token, message, title, or forum ID not provided.');
}
?>
