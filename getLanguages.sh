#!/bin/bash

curl -s http://wikistats.wmflabs.org/display.php?t=wp | sed -n "s/        <td class=\"text\"><a href=\(.*\)>\(.*\)<\/a><\/td><td class=\"text\"><a href=\(.*\)>\(.*\)<\/a><\/td>/\4/p" | sort > wiki.langs
