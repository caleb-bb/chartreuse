#!/usr/bin/env bash

while getopts ":d:" opt; do
    case $opt in
        d) directory=$OPTARG
    esac
done

echo $directory

#mix run -e "Scrapexer.scrape_site(\"$1\",\"$directory\")"
