#!/bin/bash

# ======= CONFIGURATION =======
# 1. Set your widget's TARGET ID (the folder name it should have in Plasma).
WIDGET_ID="org.kde.plasma.simplebattery"
# 2. Set your LOCAL folder name (the folder in your project directory).
LOCAL_FOLDER="package"
# =============================

PLASMOIDS_PATH="$HOME/.local/share/plasma/plasmoids"
SOURCE_PATH="./$LOCAL_FOLDER"
TARGET_PATH="$PLASMOIDS_PATH/$WIDGET_ID"

if [ "$1" = "install" ]; then
  # Check if the local source folder exists
  if [ ! -d "$SOURCE_PATH" ]; then
    echo "❌ ERROR: Local widget folder '$LOCAL_FOLDER' not found in current directory."
    echo "   Current directory is: $(pwd)"
    exit 1
  fi

  echo "📦 Installing widget..."
  echo "   From: $SOURCE_PATH"
  echo "   To:   $TARGET_PATH"

  # Remove old version and copy new one
  rm -rf "$TARGET_PATH"
  cp -r "$SOURCE_PATH" "$TARGET_PATH"

  # Restart plasmashell to make it appear immediately
  echo "🔄 Restarting Plasma shell..."
  plasmashell --replace >/dev/null 2>&1 &
  echo "✅ Done! The widget '$WIDGET_ID' should now be available in the 'Add Widgets' menu."

elif [ "$1" = "remove" ]; then
  echo "🗑️  Removing widget '$WIDGET_ID'..."

  if [ ! -d "$TARGET_PATH" ]; then
    echo "⚠️  Widget '$WIDGET_ID' is not currently installed."
    exit 0
  fi

  # Remove the widget folder
  rm -rf "$TARGET_PATH"

  # Restart plasmashell to clear it from the system
  echo "🔄 Restarting Plasma shell..."
  plasmashell --replace >/dev/null 2>&1 &
  echo "✅ Widget removed."

elif [ "$1" = "reinstall" ]; then
  # Shortcut: remove and install in one command
  "$0" remove
  sleep 5 # Brief pause to let plasmashell restart
  "$0" install

else
  # Show usage instructions
  echo "📋 Widget Folder Manager"
  echo "========================"
  echo "Manages the widget located in: ./$LOCAL_FOLDER"
  echo "Uses the target ID: $WIDGET_ID"
  echo ""
  echo "Usage:"
  echo "  $0 install     - Copy the local folder to Plasma and install"
  echo "  $0 remove      - Remove the widget from Plasma"
  echo "  $0 reinstall   - Quickly remove then re-install (good for testing)"
  echo ""
  echo "Note: Run this script from your project directory where the '$LOCAL_FOLDER' exists."
fi
