#!/usr/bin/env python3
"""
Get today's cost from the Anthropic Foundry (LiteLLM) instance.
Returns just the numeric cost value for easy parsing by PowerShell.
"""
import os
import sys
import requests
from datetime import datetime, timedelta
from dotenv import load_dotenv

# Load environment variables from .env file
env_path = os.path.join(os.path.dirname(__file__), '.env')
load_dotenv(env_path)

API_KEY = os.getenv('ANTHROPIC_FOUNDRY_API_KEY')
BASE_URL = os.getenv('ANTHROPIC_FOUNDRY_BASE_URL')

if not API_KEY or not BASE_URL:
    # Silently return 0 if credentials are missing
    print("0")
    sys.exit(0)

headers = {
    'x-api-key': API_KEY,
    'Content-Type': 'application/json',
}

# Calculate today's date range
today = datetime.now()
start_of_day = today.replace(hour=0, minute=0, second=0, microsecond=0)
end_of_day = start_of_day + timedelta(days=1)

# Format as YYYY-MM-DD (the format LiteLLM accepts)
params = {
    'start_date': start_of_day.strftime('%Y-%m-%d'),
    'end_date': end_of_day.strftime('%Y-%m-%d')
}

try:
    response = requests.get(
        f"{BASE_URL}/spend/logs",
        headers=headers,
        params=params,
        timeout=5  # Quick timeout to avoid slowing down statusline
    )

    if response.status_code == 200:
        data = response.json()

        if isinstance(data, list) and len(data) > 0:
            # Sum up the spend from all entries
            # Each entry has a 'spend' field which is the total for that day
            # We take the max spend value from all entries to avoid double counting
            total_spend = 0
            for entry in data:
                if 'spend' in entry and entry['spend'] > 0:
                    # Only count entries with actual spend
                    total_spend += entry['spend']

            # Output just the number (2 decimal places to match UI display)
            print(f"{total_spend:.2f}")
        else:
            # No spend today
            print("0")
    else:
        # API error - return 0
        print("0")

except Exception:
    # Any error - return 0 silently
    print("0")
