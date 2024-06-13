<?php
/**
 * Script to submit a post to a phpBB forum as a specific user without using sessions.
 * This script should only run when called by submit.php.
 */

// Check if the constant indicating script execution is defined
if (!defined('RUN_SUBMIT_POST')) {
    die('Access denied.'); // If the constant is not defined, terminate execution
}

// Ensure that the USER_ID constant is defined
if (!defined('USER_ID')) {
    die('User ID not provided.'); // If the user ID is not provided, terminate execution
}

// Use the USER_ID constant to get the user ID
$user_id = USER_ID;

// Check if message, title, and forum_id are set
if (!defined('MESSAGE') || !defined('TITLE') || !defined('FORUM_ID')) {
    die('Message, title, or forum ID not provided.'); // If any required parameter is not provided, terminate execution
}

// Use the defined constants for message, title, and forum_id
$post_text = MESSAGE;
$topic_title = TITLE;
$forum_id = FORUM_ID;

// Configuration
define('IN_PHPBB', true);
$phpbb_root_path = './';
$phpEx = substr(strrchr(__FILE__, '.'), 1);
include($phpbb_root_path . 'common.' . $phpEx);
include($phpbb_root_path . 'includes/functions_posting.' . $phpEx);
include($phpbb_root_path . 'includes/message_parser.' . $phpEx);

// Start phpBB session management
$user->session_begin();
$auth->acl($user->data);
$user->setup('');

// User and forum details
$poster_id = $user_id; // Use the provided user ID

// Fetch user information
$sql = 'SELECT * FROM ' . USERS_TABLE . ' WHERE user_id = ' . (int)$poster_id;
$result = $db->sql_query($sql);
$user_data = $db->sql_fetchrow($result);
$db->sql_freeresult($result);

if (!$user_data) {
    die('User not found.');
}

// Emulate the user for posting
$user->data = array_merge($user->data, $user_data);

// Create the post data array
$data = [
    'forum_id'          => $forum_id,
    'topic_title'       => $topic_title,
    'topic_first_post_id' => 0,
    'topic_last_post_id'  => 0,
    'topic_time_limit'    => 0,
    'topic_replies_real'  => 0,
    'topic_status'        => ITEM_UNLOCKED,
    'icon_id'             => 0,
    'enable_bbcode'       => true,
    'enable_smilies'      => true,
    'enable_urls'         => true,
    'enable_sig'          => true,
    'message'             => $post_text,
    'message_md5'         => md5($post_text),
    'bbcode_bitfield'     => '',
    'bbcode_uid'          => '',
    'post_edit_locked'    => 0,
    'enable_indexing'     => true,
    'notify_set'          => false,
    'notify'              => false,
    'post_time'           => time(),
    'poster_id'           => $poster_id,
    'forum_name'          => '',
    'force_approved_state'    => true, // Set to true to force the post to be approved
    'force_visibility'            => true, // Set to true to force the post to be visible
];

// Parse the message
$message_parser = new parse_message($post_text);
$message_parser->parse(true, true, true, true, false, true, true);

// Update data with parsed text
$data['message']         = $message_parser->message;
$data['bbcode_bitfield'] = $message_parser->bbcode_bitfield;
$data['bbcode_uid']      = $message_parser->bbcode_uid;

// Empty poll array
$poll = array();

// Submit the post
submit_post('post', $topic_title, '', POST_NORMAL, $poll, $data);

echo 'Post submitted successfully.';
?>
