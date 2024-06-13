#!/bin/bash

# This script manages a SQLite database to store user records with secure tokens.
# It provides functionality to initialize the database, insert/update user records,
# and set permissions of the database file.

# SQLite database configuration
db_path="userdata.db" # Path to the SQLite database file

# Function to generate secure tokens of fixed length (32 characters)
generate_token() {
    local token

    # Check if OpenSSL is available
    if command -v openssl &> /dev/null; then
        # Generate token using OpenSSL
        token=$(openssl rand -hex 16)  # 16 bytes * 2 hex characters per byte = 32 characters
    else
        # Fallback to using /dev/urandom
        token=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n')
    fi

    echo "$token"
}

# Function to create the database and table
create_database() {
    # Create the database and users table
    sqlite3 "$db_path" <<EOF
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER UNIQUE,
    token TEXT
);
EOF
    echo "Database created successfully."
}

# Function to set permissions for the database file
set_permissions() {
    if [ -f "$db_path" ]; then
        chmod 644 "$db_path"
        echo "Permissions set to 644 for $db_path."
    else
        echo "Error: Database file does not exist."
        exit 1
    fi
}

# Function to insert or update a user record
insert_or_update_user() {
    local user_id=$1
    local token=$2

    # Check if the database exists
    if [ ! -f "$db_path" ]; then
        echo "Error: Database doesn't exist. Run the script with the '-i' or '--init' option to create the database."
        exit 1
    fi

    # Check if the user already exists
    existing_user=$(sqlite3 "$db_path" "SELECT id FROM users WHERE user_id = $user_id")

    if [ -n "$existing_user" ]; then
        # Update the token if the user already exists
        sqlite3 "$db_path" "UPDATE users SET token = '$token' WHERE user_id = $user_id"
        echo "User record updated successfully."
    else
        # Insert a new user record if the user doesn't exist
        sqlite3 "$db_path" "INSERT INTO users (user_id, token) VALUES ($user_id, '$token')"
        echo "New user record inserted successfully."
    fi
}

# Function to display usage message
display_usage() {
    echo "Usage: $0 [-i|--init] [-p|--permissions] [<user_id>]"
    echo "Options:"
    echo "  -i, --init         Initialize the database"
    echo "  -p, --permissions  Set database file permissions to 644"
    echo "Arguments (required when not initializing database):"
    echo "  user_id            User ID"
}

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--init)
            init_db=true
            shift
            ;;
        -p|--permissions)
            set_permissions_flag=true
            shift
            ;;
        -*)
            display_usage
            exit 1
            ;;
        *)
            user_id="$1"
            shift
            ;;
    esac
done

# Handle setting permissions if the flag is set
if [ "$set_permissions_flag" = true ]; then
    set_permissions
    # Exit if only setting permissions
    if [ -z "$init_db" ] && [ -z "$user_id" ]; then
        exit 0
    fi
fi

# Validate and handle initialization of database
if [ "$init_db" = true ]; then
    create_database
    exit 0  # Exit after database initialization if no user_id is provided
fi

# If user_id is provided, generate token and insert/update user record
if [ -n "$user_id" ]; then
    token=$(generate_token)
    insert_or_update_user "$user_id" "$token"
    echo "Generated Token for User ID $user_id: $token"
    exit 0
fi

# If no arguments provided after options and not initializing database, display usage
if [ -z "$init_db" ] && [ -z "$user_id" ] && [ -z "$set_permissions_flag" ]; then
    display_usage
    exit 1
fi

