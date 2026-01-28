#!/bin/bash
# PreToolUse Hook - Safety Net
# Blocks dangerous commands before they execute
#
# Exit codes:
#   0 = Allow the action
#   2 = Block the action (message sent to stderr becomes error for agent)

# Read the tool input from stdin
INPUT=$(cat)

# Extract tool name and command (if Bash tool)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
BASH_COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# ============================================
# DANGEROUS COMMAND PATTERNS
# ============================================
# SECURITY: Use \s+ for whitespace matching to prevent bypass with extra spaces
# Example: "rm  -rf /" (two spaces) would bypass "rm -rf /" but not "rm\s+-rf\s+/"

DANGEROUS_PATTERNS=(
    # Destructive file operations (use \s+ for whitespace to prevent bypass with extra spaces)
    'rm\s+-rf\s+/'
    'rm\s+-rf\s+/\*'
    'rm\s+-rf\s+~'
    'rm\s+-rf\s+\$HOME'

    # Git destructive operations
    'git\s+reset\s+--hard'
    'git\s+push.*--force'
    'git\s+push.*-f\s'
    'git\s+clean\s+-fdx'

    # Database destructive operations
    'drop\s+table'
    'drop\s+database'
    'truncate\s+table'
    'delete\s+from.*where\s+1\s*=\s*1'
    'delete\s+from.*without\s+where'

    # System-level operations
    'chmod\s+777'
    'chmod\s+-R\s+777'
    'sudo\s+rm'
    'sudo\s+chmod'
    '>\s*/dev/sd'
    'mkfs'
    'dd\s+if=.*/dev/'

    # Credential exposure
    'cat\s+.*\.env'
    'cat\s+.*credentials'
    'cat\s+.*secret'
    'cat\s+.*/etc/passwd'
    'cat\s+.*/etc/shadow'
    'echo\s+.*API_KEY'
    'echo\s+.*SECRET'
    'echo\s+.*PASSWORD'

    # Network exfiltration patterns
    'curl.*\|.*sh'
    'wget.*\|.*sh'
    'curl.*\|.*bash'
    'wget.*\|.*bash'
)

# ============================================
# SENSITIVE FILE PATTERNS
# ============================================
# SECURITY: Comprehensive list of credential and configuration files
# that should never be read or modified by agents

SENSITIVE_FILES=(
    # Environment files
    ".env"
    ".env.local"
    ".env.production"
    ".env.development"
    ".env.staging"

    # Credential files
    "credentials.json"
    "secrets.yaml"
    "secrets.yml"
    "service-account.json"

    # SSH keys
    ".ssh/id_rsa"
    ".ssh/id_ed25519"
    ".ssh/id_dsa"
    ".ssh/authorized_keys"
    ".ssh/known_hosts"

    # Certificate/key files
    "*.pem"
    "*.key"
    "*.p12"
    "*.pfx"

    # AWS credentials
    ".aws/credentials"
    ".aws/config"

    # GCP credentials
    "gcloud/credentials"
    "application_default_credentials.json"

    # Azure credentials
    ".azure/credentials"

    # Docker credentials
    ".docker/config.json"

    # Kubernetes credentials
    ".kube/config"

    # System files (absolute paths)
    "/etc/passwd"
    "/etc/shadow"
    "/etc/sudoers"
    "/etc/ssh/ssh_host"

    # NPM/Yarn tokens
    ".npmrc"
    ".yarnrc"

    # Git credentials
    ".git-credentials"
    ".netrc"
)

# ============================================
# CHECK BASH COMMANDS
# ============================================

if [[ "$TOOL_NAME" == "Bash" ]] && [[ -n "$BASH_COMMAND" ]]; then
    # Convert to lowercase for matching
    CMD_LOWER=$(echo "$BASH_COMMAND" | tr '[:upper:]' '[:lower:]')

    for pattern in "${DANGEROUS_PATTERNS[@]}"; do
        if echo "$CMD_LOWER" | grep -qiE "$pattern"; then
            echo "BLOCKED: Dangerous command detected." >&2
            echo "Pattern matched: $pattern" >&2
            echo "Command: $BASH_COMMAND" >&2
            echo "" >&2
            echo "This action violates safety protocols." >&2
            echo "If this is intentional, please run the command manually." >&2
            exit 2
        fi
    done
fi

# ============================================
# CHECK FILE ACCESS
# ============================================

if [[ "$TOOL_NAME" == "Read" || "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "Edit" ]]; then
    if [[ -n "$FILE_PATH" ]]; then
        FILE_LOWER=$(echo "$FILE_PATH" | tr '[:upper:]' '[:lower:]')
        FILE_NAME=$(basename "$FILE_PATH")

        for pattern in "${SENSITIVE_FILES[@]}"; do
            # Check if filename matches pattern
            if [[ "$FILE_NAME" == $pattern ]] || [[ "$FILE_LOWER" == *"$pattern"* ]]; then
                echo "BLOCKED: Attempt to access sensitive file." >&2
                echo "File: $FILE_PATH" >&2
                echo "Pattern matched: $pattern" >&2
                echo "" >&2
                echo "Sensitive files should not be read or modified by agents." >&2
                echo "Handle credentials manually for security." >&2
                exit 2
            fi
        done
    fi
fi

# ============================================
# CHECK FOR SECRETS IN WRITE OPERATIONS
# ============================================

if [[ "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "Edit" ]]; then
    CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty')

    if [[ -n "$CONTENT" ]]; then
        # Check for hardcoded secrets patterns
        if echo "$CONTENT" | grep -qiE "(password|api_key|secret|token)\s*[:=]\s*['\"][^'\"]{8,}['\"]"; then
            echo "WARNING: Potential hardcoded secret detected in content." >&2
            echo "File: $FILE_PATH" >&2
            echo "" >&2
            echo "Consider using environment variables instead." >&2
            # This is a warning, not a block - exit 0
        fi
    fi
fi

# ============================================
# ALL CHECKS PASSED
# ============================================

exit 0
