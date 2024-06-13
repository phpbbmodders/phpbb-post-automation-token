#!/bin/bash

###########################################################
# Script to submit a post to a forum using curl.
#
# Parameters:
# - TOKEN: The authentication token for the API.
# - MESSAGE: The content of the post, with BBCode or plain text.
# - TITLE: The title of the post.
# - FORUM_ID: The ID of the forum where the post will be submitted.
# - BOARD: Optional. The folder name if the forum is in a subdirectory.
#
# Domain and Port:
# - DOMAIN: The domain where the forum is hosted.
# - PORT: The port number (default HTTP port is 80, change if different).
#
# URL Encoding:
# - The script handles URL encoding of MESSAGE and TITLE using jq.
#
# Example usage:
# - Submitting a post to a forum located at http://192.168.1.80:8002/forum/
#   with TOKEN, MESSAGE, TITLE, and FORUM_ID defined.
#
# Note: Requires jq for URL-encoding of MESSAGE and TITLE.
###########################################################

# Define your parameters
TOKEN="sekretToken"
MESSAGE="This is a test [color=purple][b]message[/b][/color]"
TITLE="Test Title7"
FORUM_ID="13"
BOARD="forum"  # Leave empty if board is at the root of the domain else provide the name of the folder the board is in

# Define your domain and port
DOMAIN="192.168.1.80"
PORT="80" # Default http port is 80, only change if yours is different

# Construct the base URL
URL="http://$DOMAIN:$PORT/"

# Append BOARD to the URL path if not empty
if [ -n "$BOARD" ]; then
    URL="$URL$BOARD/"
fi

# URL-encode the parameters
ENCODED_MESSAGE=$(echo "$MESSAGE" | jq -sRr @uri)
ENCODED_TITLE=$(echo "$TITLE" | jq -sRr @uri)

# Append the query parameters correctly
URL="${URL}submit.php?token=$TOKEN&message=$ENCODED_MESSAGE&title=$ENCODED_TITLE&forum_id=$FORUM_ID"

# Make the HTTP request using curl
curl "$URL"

