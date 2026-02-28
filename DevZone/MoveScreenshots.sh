#!/bin/bash

cd Images || return

mv "$(ls -dtr1 ../../../../Screenshots/* | tail -1)" 03_options.jpg
mv "$(ls -dtr1 ../../../../Screenshots/* | tail -1)" 02_transmog.jpg
mv "$(ls -dtr1 ../../../../Screenshots/* | tail -1)" 01_menu.jpg

magick 01_menu.jpg -crop 600x590+2090+29 01_menu.jpg
magick 02_transmog.jpg -crop 842x1000+2121+45 02_transmog.jpg
magick 03_options.jpg -crop 799x470+1770+130 03_options.jpg