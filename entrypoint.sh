#!/bin/sh -l

filepath=$1
versionLineIdentifier=$2
dependecyOrgRepo=$3
temporaryFile="dfhvdfknvodnpovuhihdfivhdfiojersdafasdfwerdbbyteqwkjlosdafasdf"
releasesJson="werqwfknvodnpovasdsdfivhdfiojersdafasdfwerdbbyteqwkjlosdfa.json"

echo "Our version"
currentVersion=$(cat $filepath | grep "$versionLineIdentifier" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+")
#currentVersion="3.2.3"
echo $currentVersion

echo
echo "Released versions"
curl https://api.github.com/repos/${dependecyOrgRepo}/releases > $releasesJson
cat $releasesJson | jq '.[].tag_name' | grep -v rc | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+" > $temporaryFile
echo $currentVersion >> $temporaryFile
cat $temporaryFile | sort -rV
newVersion=$(cat $temporaryFile | sort -rV | head -n 1)
rm $temporaryFile

# Because the currentVersion has been added to the version list, and the list is sorted by version
# if newVersion != currentVersion, newVersion is a higher version than currentVersion.
# if we didn't add the currentVersion to the list we could risk a downgrade if the currentVersion
# for some reason didn't exist in the list.
if [ ! $newVersion == $currentVersion ]
then
    echo "Current version ($currentVersion) is not the same as the newest version ($newVersion)"
    echo "Creating pr with bump to newest version"

    lineNumberOfVersionLine=$(grep -n "$versionLineIdentifier" $filepath | grep -Eo '^[^:]+')
    sed -i "$lineNumberOfVersionLine s/$currentVersion/$newVersion/" "$filepath"
    releaseUrl=$(cat $releasesJson | jq --arg newVersion "$newVersion" '
        map(select(.tag_name | match($newVersion))) | .[].html_url ' \
        | sed -e 's/^"//' -e 's/"$//')
    echo "::set-output name=new-version::$newVersion"
    echo "::set-output name=release-url::$releaseUrl"
fi

rm $releasesJson




