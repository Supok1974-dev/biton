#!/bin/bash
# create multiresolution windows icon
ICON_SRC=../../src/qt/res/icons/biton.png
ICON_DST=../../src/qt/res/icons/biton.ico
convert ${ICON_SRC} -resize 16x16 biton-16.png
convert ${ICON_SRC} -resize 32x32 biton-32.png
convert ${ICON_SRC} -resize 48x48 biton-48.png
convert biton-16.png biton-32.png biton-48.png ${ICON_DST}

