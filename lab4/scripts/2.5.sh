#!/bin/bash
find ~ -name "*.txt" > /tmp/2.5.txt
cat /tmp/2.5.txt | wc -l
du -h /tmp/2.5.txt | cut -f1
rm /tmp/2.5.txt
