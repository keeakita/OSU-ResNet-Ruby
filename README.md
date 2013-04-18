ResNet Auto Login Script
========================

Yeah, I know there's a Python one, but it used a [regex to parse
HTML](http://stackoverflow.com/a/1732454) and was written in Python 2 (*please*
stop using 2, seriously) but I don't know enough about Python 3 to port it
properly (I tried, it's a mess). So here's my implementation in Ruby.

Usage
-----
 - Download the script
 - Edit the variables at the top
   - $username should be your name.#
   - $password should be either nil (it'll ask for the password when needed) or
     your password. It's recommended to use nil as it's more secure.
   - $daemon will check if you're logged in every 30 seconds if set to true

Requirements
------------
 - Ruby (Tested on 2.0, but 1.9.x should work too)
 - Nokogiri (gem install nokogiri)

TODO
----
 - Make it use KDE's Kwallet to store the username and password
 - (Possibly) Make it use gnome-keyring also. I don't use gnome anymore, we'll
   see.

License
-------
This script is licensed under the [WTFPL](http://www.wtfpl.net/).

Disclaimer
----------
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO BLAH BLAH BLAH ISN'T IT FUNNY HOW
UPPER-CASE MAKES IT SOUND LIKE THE LICENSE IS ANGRY AND SHOUTING AT YOU.
