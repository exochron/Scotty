#!/bin/bash

cd Images || return

mv "$(ls -dtr1 ../../../../Screenshots/* | tail -1)" 02_options.jpg
mv "$(ls -dtr1 ../../../../Screenshots/* | tail -1)" 01_menu.jpg

magick 01_menu.jpg -crop 600x567+2090+29 01_menu.jpg
magick 02_options.jpg -crop 799x450+1770+130 02_options.jpg