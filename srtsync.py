#!/usr/bin/env python3
# coding: utf-8
# @2022-06-05 14:24:41
# vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

import re
import pysubs2


def get_features(s: str, is_chn: bool = False, eng_after_chn: bool = True) -> str:
    '''提取一句话中英文内容，并删除标签、标点'''
    # 只提取英文
    if is_chn:
        if '\\N' in s:
            s = s.split('\\N')[eng_after_chn]
        else:
            s = 'no eng text'
    else:
        s = s.replace('\\N', '')
    # 移除 <i> 标签
    s = s.replace('{\\i0}', '').replace('{\\i1}', '')
    s = s.lower()
    # 删除标点
    s = re.sub(r'[^\w]+', '', s)
    return s


def load_srt(srt: str, is_chn: bool = False) -> tuple:
    texts = []
    subs = pysubs2.load(srt)
    for sub in subs:
        text = get_features(sub.text, is_chn)
        texts.append(text)

    return subs, texts


def fix_timeline(srt_eng: str, srt_chn_eng: str) -> None:
    subs_eng, text_eng = load_srt(srt_eng)
    subs_chn, text_chn_eng = load_srt(srt_chn_eng, is_chn=True)

    subs_chn_list = list(subs_chn)

    index_chn = 0
    index_eng = 0
    replace_map = {}
    for text in text_chn_eng:
        index_chn += 1
        if text not in text_eng:
            continue
        index_eng = text_eng.index(text)
        if replace_map.get(index_eng):  # 重复台词
            for i in range(1, text_eng.count(text)):
                # 从上一次位置往后查找
                index_eng = text_eng.index(text, index_eng)
                if not replace_map.get(index_eng):
                    break

        replace_map[index_eng] = subs_chn_list[index_chn - 1].text

    # 替换对应文本内容
    index_eng = 0
    for sub in subs_eng:
        text = replace_map.get(index_eng)
        index_eng += 1
        if not text:
            continue
        sub.text = text
    subs_eng.save(srt_chn_eng)


if __name__ == '__main__':
    import sys
    srt_eng = sys.argv[1]
    srt_chn_eng = sys.argv[2]
    fix_timeline(srt_eng, srt_chn_eng)
