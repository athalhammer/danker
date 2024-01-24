# Make this run regularly on a Raspberry Pi

```
$ crontab -l
0 1 7,24 * * export PATH="$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";cd $HOME/danker/;git pull;./rpi/raspberry-danker.sh
```
