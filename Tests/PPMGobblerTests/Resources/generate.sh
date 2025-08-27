#!/usr/bin/env bash

# This Image Magick and netpbm to be installed
set -e

# P1
echo "Generating P1 test files..."
magick sample.png -compress none -depth 1 pbm:test_p1_1.pbm
sed $'3i\\\n# This is a comment\n' test_p1_1.pbm > test_p1_1_comments.pbm
awk 'NR <= 2 { print; next } { gsub(/[[:space:]]/, ""); printf "%s", $0 } END { print "" }' test_p1_1.pbm > test_p1_1_no_blank.pbm

# P2
echo "Generating P2 test files..."
magick sample.png -compress none -depth 8 pgm:test_p2_255.pgm
pnmdepth 10000 test_p2_255.pgm | pnmtoplainpnm > test_p2_10000.pgm
pnmdepth 65535 test_p2_255.pgm | pnmtoplainpnm > test_p2_65535.pgm
sed $'4i\\\n# This is a comment\n' test_p2_255.pgm > test_p2_255_comments.pgm
tr '\n' ' ' < test_p2_255.pgm > test_p2_255_no_blank.pgm

# P3
echo "Generating P3 test files..."
magick sample.png -compress none -depth 8 ppm:test_p3_255.ppm
pnmdepth 10000 test_p3_255.ppm | pnmtoplainpnm | sed -e '4,${N; s/\n//;}' > test_p3_10000.ppm
pnmdepth 65535 test_p3_255.ppm | pnmtoplainpnm | sed -e '4,${N; s/\n//;}' > test_p3_65535.ppm
sed $'4i\\\n# This is a comment\n' test_p3_255.ppm > test_p3_255_comments.ppm
tr '\n' ' ' < test_p3_255.ppm > test_p3_255_no_blank.ppm

# P4
echo "Generating P4 test files..."
magick sample.png -depth 1 pbm:test_p4_1.pbm

# P5
echo "Generating P5 test files..."
magick sample.png -depth 8 pgm:test_p5_255.pgm
pnmdepth 10000 test_p5_255.pgm > test_p5_10000.pgm
pnmdepth 65535 test_p5_255.pgm > test_p5_65535.pgm

# P6
echo "Generating P6 test files..."
magick sample.png -depth 8 ppm:test_p6_255.ppm
pnmdepth 10000 test_p6_255.ppm > test_p6_10000.ppm
pnmdepth 65535 test_p6_255.ppm > test_p6_65535.ppm

# Done
echo "Done"
