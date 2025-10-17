#!/bin/bash

# A wrapper script for the Gemini CLI to handle errors gracefully with user interaction.

MAX_RETRIES=3
INITIAL_BACKOFF=2
GEMINI_COMMAND="$@"

# --- Helper Functions ---

# Function to ask the user a yes/no question
# Writes to /dev/tty to ensure prompts reach the user even in non-interactive contexts
ask_user() {
  local prompt="$1"
  # Check if we have access to a terminal
  if [ ! -t 0 ] && [ -e /dev/tty ]; then
    exec < /dev/tty
  fi

  while true; do
    echo -n "$prompt (y/n): " >&2
    read choice
    case "$choice" in
      [Yy]* ) return 0;; # Success (yes)
      [Nn]* ) return 1;; # Failure (no)
      * ) echo "Please answer 'y' or 'n'." >&2;;
    esac
  done
}

# --- Main Execution Logic ---

attempt=0
model_switched=false

while [ $attempt -lt $MAX_RETRIES ]; do
  # Execute the gemini command, capturing both stdout and stderr
  # We redirect stderr to a temporary file to analyze it for specific error messages.
  STDERR_FILE=$(mktemp)
  eval "$GEMINI_COMMAND" 2> "$STDERR_FILE"
  exit_code=$?
  STDERR_OUTPUT=$(<"$STDERR_FILE")
  rm "$STDERR_FILE"

  # --- Success Condition ---
  if [ $exit_code -eq 0 ]; then
    exit 0
  fi

  # --- Error Handling ---

  # Check for Quota Error (typically for Pro model)
  if [[ "$STDERR_OUTPUT" == *"RESOURCE_EXHAUSTED"* || "$STDERR_OUTPUT" == *"Quota exceeded"* ]]; then
    echo "Gemini API Warning: Quota limit reached for Gemini Pro." >&2

    # Only offer model switch if we haven't already switched
    if [ "$model_switched" = false ] && ask_user "Would you like to try again using the Gemini Flash model instead?"; then
      # Replace the model in the command and retry immediately
      GEMINI_COMMAND=${GEMINI_COMMAND//gemini-2.5-pro/gemini-flash-latest}
      echo "Switching to Flash model and retrying..." >&2
      model_switched=true
      # Don't increment attempt counter for model switch
      continue
    else
      echo "Aborting Gemini command. Handing control back to Claude." >&2
      exit 1 # Abort
    fi

  # Check for Overloaded/Unavailable Error (common for Flash model)
  elif [[ "$STDERR_OUTPUT" == *"Service Unavailable"* || "$STDERR_OUTPUT" == *"model is overloaded"* || "$STDERR_OUTPUT" == *"503"* ]]; then
    echo "Gemini API is currently overloaded or unavailable." >&2
    # Fall through to the retry logic below

  # Handle other unknown errors
  else
    echo "An unexpected Gemini CLI error occurred (Exit Code: $exit_code):" >&2
    echo "$STDERR_OUTPUT" >&2
    # Fall through to the retry logic below
  fi

  # --- Retry Logic ---
  attempt=$((attempt + 1))
  if [ $attempt -ge $MAX_RETRIES ]; then
    break # Exit loop if max retries are reached
  fi

  backoff_time=$((INITIAL_BACKOFF * (2 ** (attempt - 1))))
  echo "Retrying in $backoff_time seconds (Attempt $attempt/$MAX_RETRIES)..." >&2
  sleep $backoff_time
done


# --- Failure Condition after Retries ---
echo "Gemini command failed after $MAX_RETRIES attempts." >&2
if ask_user "Do you want to hand this task over to Claude to complete?"; then
  echo "User chose to hand off to Claude. Aborting Gemini command." >&2
  exit 1 # Non-zero exit signals failure, allowing Claude's main agent to take over
else
  echo "User chose not to hand off. Exiting." >&2
  exit 1
fi
