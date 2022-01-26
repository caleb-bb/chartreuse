#!/usr/bin/env bash
if [ -z $@ ]
then
    echo "I need a URL, champ. A directory name following the -d flag is optional. If the directory doesn't exist yet, I'll create it for you. Otherwise the scraped contents will go into that directory."
    exit 1
fi

url=$1
shift
while getopts ":d:" opt; do
    case $opt in
        d) directory=$OPTARG
    esac
done

echo "running: mix run -e \"Scrapexer.scrape_site(\"$url\",\"$directory\")"
mix run -e "Scrapexer.scrape_site(\"$url\",\"$directory\")"
