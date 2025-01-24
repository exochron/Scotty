#!/bin/bash

cd Images || return

mv "$(ls -dtr1 ../../../../Screenshots/* | tail -1)" 02_options.jpg
mv "$(ls -dtr1 ../../../../Screenshots/* | tail -1)" 01_menu.jpg

magick 01_menu.jpg -crop 407x491+2105+29 01_menu.jpg
magick 02_options.jpg -crop 799x400+1770+130 02_options.jpg