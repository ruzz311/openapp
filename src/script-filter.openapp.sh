RESOURCES="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources"

function createXMLItem {
    # APPNAME="$(tr -d '.app' <<< "$1")"
    APPNAME="$(sed -e 's/\.app$//' <<< "$1")"
    APP_PATH="/Applications/$APPNAME"
    ICON_PATH="$(getIconPath "$1")"
    ITEMARG="$(getItemArg "$1")"

    TITLE="<title>$APPNAME</title>"
    SUBTITLE="<subtitle>$APP_PATH</subtitle>"
    ICON="<icon>$ICON_PATH</icon>"
    echo "<item uid=\"$APPNAME\" arg=\"$ITEMARG\">$TITLE$SUBTITLE$ICON</item>"
}

function getItemArg {
    APPNAME="$1"
    EXECUTEABLE=`defaults read "/Applications/$APPNAME/Contents/Info" CFBundleExecutable`
    echo "/Applications/$APPNAME/Contents/MacOS/$EXECUTEABLE"
}

function getIconPath {
    APPNAME="$1"
    ICON_NAME=`defaults read "/Applications/$APPNAME/Contents/Info" CFBundleIconFile|sed -e 's/\.icns$//'`
    ICON_PATH="/Applications/$APPNAME/Contents/Resources/$ICON_NAME.icns"
    if [[ -e "ICON_PATH" ]]; then
        ICON_PATH="$RESOURCES/ApplicationsFolderIcon.icns"
    fi
    echo "$ICON_PATH"
}

# TODO: remove if not needed
function escapeSpaces {
    echo "$(printf "%q\n" "$1")"
}

ITEMS=""
# find apps
while read -r line ; do
    item=$(createXMLItem "$line")
    ITEMS+="${item}"
    #echo "ItemCreated! $item"
done <<< "$(ls /Applications | grep -i "{query}")"
RESULT=$(echo "<?xml version=\"1.0\"?><items>$ITEMS</items>")

cat <<< "$RESULT"
