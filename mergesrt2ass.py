#!/usr/bin/env python2
# encoding: utf-8

# from https://github.com/cubarco/mergesrt2ass/blob/master/mergesrt2ass.py

import pysubs2
import chardet
import sys


def charset_detect(filename):
    with open(filename, 'rb') as fi:
        rawdata = fi.read()
    encoding = chardet.detect(rawdata)['encoding']
    if encoding.lower() == 'gb2312':  # Decoding may fail using GB2312
        encoding = 'gbk'
    return encoding


def merge(file1, file2, outfile):
    subs1 = pysubs2.load(file1, encoding=charset_detect(file1))
    subs2 = pysubs2.load(file2, encoding=charset_detect(file2))

    for line in subs1:
        subs2.append(line)

    subs2.styles["Default"].fontsize = 20.0
    subs2.styles["Default"].shadow = 0.5
    subs2.styles["Default"].outline = 1.0
    subs2.save(outfile)


def help(cmd):
        print ('''
Usage: {} SUBTITLE_FILE_1 SUBTITLE_FILE_2 OUTPUT_FILENAME.

The lines from SUBTITLE_FILE_1 will *probably* be displayed over the lines from
SUBTITLE_FILE_2. And the filename extension of OUTPUT_FILE should be ".ass".
'''
               .format(cmd))


if __name__ == '__main__':
    try:
        file1, file2, outfile = sys.argv[1:4]
    except:
        help(sys.argv[0])
    else:
        assert(outfile.endswith('ass'))
        merge(file1, file2, outfile)
