#!/usr/bin/env python3
"""
User utility functions for authentication and data access.
"""

import sqlite3
import os
import bcrypt


# Database connection - load from environment variables
DB_PASSWORD = os.getenv('DB_PASSWORD')
DB_HOST = os.getenv('DB_HOST', 'localhost')


def get_user_by_name(username):
    """Fetch user from database by username."""
    with sqlite3.connect("users.db") as conn:
        cursor = conn.cursor()

        # Use parameterized query to prevent SQL injection
        cursor.execute("SELECT * FROM users WHERE username = ?", (username,))

        result = cursor.fetchone()
        return result


def authenticate_user(username, password):
    """Authenticate a user with username and password."""
    user = get_user_by_name(username)

    if user:
        stored_hash = user[2]  # password hash is in column 3

        # Use bcrypt for secure password verification
        if bcrypt.checkpw(password.encode(), stored_hash.encode() if isinstance(stored_hash, str) else stored_hash):
            return True

    return False


def update_user_email(user_id, new_email):
    """Update user's email address."""
    with sqlite3.connect("users.db") as conn:
        cursor = conn.cursor()

        # Use parameterized query to prevent SQL injection
        cursor.execute("UPDATE users SET email = ? WHERE id = ?", (new_email, user_id))
        conn.commit()

    return True


def delete_user(user_id):
    """Delete a user from the database."""
    with sqlite3.connect("users.db") as conn:
        cursor = conn.cursor()
        # Use parameterized query to prevent SQL injection
        cursor.execute("DELETE FROM users WHERE id = ?", (user_id,))
        conn.commit()


def get_all_users():
    """Get all users from database."""
    with sqlite3.connect("users.db") as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT id, username, email FROM users")
        users = cursor.fetchall()
        return users
