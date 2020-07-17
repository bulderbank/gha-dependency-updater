#!/bin/sh -l
#Input variables, set autoamtically by the gha workflow.
INPUT_PATH_TO_FILE=$1
INPUT_LINE_SELECTOR=$2
INPUT_DEPENDENCY_ORG_REPO=$3
releases_url="https://api.github.com/repos/${INPUT_DEPENDENCY_ORG_REPO}/releases"

echo
echo "Fetching releases from $releases_url"
releases_payload=$(curl $releases_url)
echo

current_version=$(cat $INPUT_PATH_TO_FILE | grep "$INPUT_LINE_SELECTOR" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+")
echo "Our version: $current_version"
echo

newest_releases=$(echo $releases_payload | jq '.[].tag_name' | grep -v rc | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+")
echo "Released versions"
echo "$newest_releases"
echo

newest_version=$(echo "$newest_releases" | sed -e "$ a $current_version" | sort -r --version-sort | head -n 1)

# Because the current_version has been added to the version list, and the list is sorted by version
# if newest_version != current_version, newest_version is a higher version than current_version.
# if we didn't add the current_version to the list we could risk a downgrade if the current_version
# for some reason didn't exist in the list.
if [ ! $newest_version == $current_version ]
then
    echo "Current version ($current_version) is not the same as the newest version ($newest_version)"
    echo "Creating pr with bump to newest version"

    line_number_of_version_line=$(grep -n "$INPUT_LINE_SELECTOR" $INPUT_PATH_TO_FILE | grep -Eo '^[^:]+')
    sed "$line_number_of_version_line s/$current_version/$newest_version/" "$INPUT_PATH_TO_FILE"
    releaseUrl=$(echo $releases_payload | jq --arg newest_version "$newest_version" '
        map(select(.tag_name 
        | match($newest_version))) 
        | .[].html_url ' \
        | sed -e 's/^"//' -e 's/"$//')
    echo "::set-output name=new-version::$newest_version"
    echo "::set-output name=release-url::$releaseUrl"
else
    echo  echo "Current version ($current_version) is the newest version"
fi





