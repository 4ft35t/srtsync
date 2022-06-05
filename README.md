# srtsync
Automatic synchronization of subtitles with video embed subtitle, the correct the start point of every Sentence. Only for .srt, not support .ass.

根据视频内嵌英文字幕的时间轴，自动校准双语字幕。一般视频内嵌字幕都是 srt，故本项目只支持 srt 不支持 ass。

## 原理
用双语字幕中的英文，去找内嵌字幕对应位置，把双语内容替换进去。


如果可以下载到时间轴准确的英文字幕，可以大幅节约从视频中提取字幕的时间。

## 安装
```
git clone https://github.com/4ft35t/srtsync.git
cd srtsync
pip3 install -r requirements.txt
```

## 使用方法
### 方式一
` python3 srtsync.py srt_in_video.srt srt_chn_eng.srt`

### 方式二
使用 srtsync.sh 自动从视频中提取英文字幕, 并校准
`bash srtsync.sh video.mkv srt_chn_eng.srt`

## 其他
尝试过 https://github.com/smacke/ffsubsync，可以处理不同台词偏移不一致的问题，但是不能完全处理好。故而突发奇想，用最简单的方法处理问题。

本项目不能用硬字幕来校准，有需求请使用其他优秀的工具，ffsubsync 项目首页有罗列其它类似工具，这里不再赘述。
