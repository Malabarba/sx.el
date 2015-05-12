#!/usr/bin/env bash

DESTINATION_BRANCH=gh-pages
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

function notify-done {
    local title
    local message
    title="SX Tag Bot"
    message="Finished retrieving tag lists"
    case $(uname | tr '[[:upper:]]' '[[:lower:]]') in
        darwin)
            terminal-notifier \
                -message ${message} \
                -title ${title} \
                -sound default
            ;;
        *)
            echo ${message}
    esac
}

function generate-tags {
    emacs -Q --batch \
          -L "./" -L "./bot/" -l sx-bot \
          -f sx-bot-fetch-and-write-tags
    ret=$?
    notify-done
    return ${ret}
}

git branch ${DESTINATION_BRANCH} || git checkout ${DESTINATION_BRANCH}
git pull &&
    generate-tags &&
    git stage data/ &&
    git commit -m "Update tag data" &&
    echo 'Ready for "git push"'

git checkout ${CURRENT_BRANCH}
