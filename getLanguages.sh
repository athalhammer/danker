curl http://wikistats.wmflabs.org/display.php?t=wp | grep "</td><td class=\"text\">" | sed s/"        <td class=\"text\"><a href=\(.*\)>\(.*\)<\/a><\/td><td class=\"text\"><a href=\(.*\)>\(.*\)<\/a><\/td>"/"\4"/ | sort > wiki.langs

