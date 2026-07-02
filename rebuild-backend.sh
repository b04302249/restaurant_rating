#!/bin/bash
cd "$(dirname "$0")/backend" && ./gradlew classes --quiet && echo "✅ Backend rebuilt — devtools should auto-restart"
