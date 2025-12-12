# Make this run regularly on a Raspberry Pi

* Install `awscli`
* Configure `.aws/`
* Initial `git clone` of `danker` into `$HOME`
```
$ crontab -l
0 1 6,24 * * (cd $HOME/danker/;git pull;./rpi/raspberry-danker.sh) 2>&1 | logger -t danker
```
