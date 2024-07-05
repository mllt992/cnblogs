---
title: '[python]Markdown图片引用格式批处理桌面应用程序'
date: 2024-07-06 07:36:35
tags:
---

## 需求

```
使用python编写一个exe，实现批量修改图片引用，将修改后的文件生成为 文件名_blog.md。有一个编辑框，允许接收拖动过来md文件，拖入文件时获取文件路径，有一个编辑框编辑修改后的文件的输出路径，用户拖入文件时，就能自动得到输出的路径
作用是将md文件中的例如
![image-20240706062921362](./[git]git拯救项目之恢复到之前提交的记录/image-20240706062921362.png)改成{% asset_img image-20240706062921362.png '"..." "文章配图"' %} 
![image-20240706063059015](./[git]git拯救项目之恢复到之前提交的记录/image-20240706063059015.png)改成{% asset_img image-20240706063059015.png '"..." "文章配图"' %}
```

## 代码

```python
import os
import re
import wx
from pathlib import Path

"""

使用python编写一个exe，实现批量修改图片引用，将修改后的文件生成为 文件名_blog.md。有一个编辑框，允许接收拖动过来md文件，拖入文件时获取文件路径，有一个编辑框编辑修改后的文件的输出路径，用户拖入文件时，就能自动得到输出的路径
作用是将md文件中的例如
![image-20240706062921362](./[git]git拯救项目之恢复到之前提交的记录/image-20240706062921362.png)改成{% asset_img image-20240706062921362.png '"..." "文章配图"' %} 
![image-20240706063059015](./[git]git拯救项目之恢复到之前提交的记录/image-20240706063059015.png)改成{% asset_img image-20240706063059015.png '"..." "文章配图"' %}

"""


class DropTarget(wx.FileDropTarget):
    def __init__(self, window):
        super().__init__()
        self.window = window

    def OnDropFiles(self, x, y, filenames):
        self.window.set_filenames(filenames)


class MainFrame(wx.Frame):
    def __init__(self, parent, title):
        super().__init__(parent, title=title, size=(600, 400))
        panel = wx.Panel(self)

        self.text_input = wx.TextCtrl(panel, style=wx.TE_MULTILINE | wx.TE_READONLY)
        self.text_output = wx.TextCtrl(panel, style=wx.TE_MULTILINE | wx.TE_READONLY)
        self.btn_convert = wx.Button(panel, label="开始转换")

        vbox = wx.BoxSizer(wx.VERTICAL)
        vbox.Add(self.text_input, proportion=1, flag=wx.EXPAND | wx.ALL, border=5)
        vbox.Add(self.text_output, proportion=1, flag=wx.EXPAND | wx.ALL, border=5)
        vbox.Add(self.btn_convert, flag=wx.EXPAND | wx.ALL, border=5)

        panel.SetSizer(vbox)

        self.SetDropTarget(DropTarget(self))

        self.Bind(wx.EVT_BUTTON, self.on_convert, self.btn_convert)

        self.Centre()
        self.Show(True)

    def set_filenames(self, filenames):
        self.filenames = filenames
        self.text_input.SetValue('\n'.join(filenames))

    def on_convert(self, event):
        for filename in self.filenames:
            if filename.lower().endswith('.md'):
                input_file_path = Path(filename)
                output_file_path = input_file_path.with_name(input_file_path.stem + '_blog' + input_file_path.suffix)
                self.text_output.AppendText(str(output_file_path) + '\n')
                self.convert_markdown_images(str(input_file_path), str(output_file_path))

    def convert_markdown_images(self, input_file, output_file):
        with open(input_file, 'r', encoding='utf-8') as file:
            content = file.read()

        # 修改正则表达式，以匹配Markdown图片链接
        pattern = r'\!\[(?P<alt_text>.*?)\]\((?P<path>.*/)?(?P<file_name>.*?)(?P<extension>\..*)\)'

        # 遍历所有匹配项并构建新的替换字符串
        new_content = re.sub(pattern, lambda m: f'{{% asset_img {m.group("file_name")}{m.group("extension")} \'"{m.group("alt_text")}" "文章配图"\' %}}', content)

        # 将修改后的内容写入输出文件
        with open(output_file, 'w', encoding='utf-8') as file:
            file.write(new_content)

        wx.MessageBox(f"已成功转换'{input_file}'至'{output_file}'", "转换成功", wx.OK)


if __name__ == '__main__':
    app = wx.App()
    MainFrame(None, title="Markdown 图片链接转换器")
    app.MainLoop()



if __name__ == '__main__':
    app = wx.App()
    MainFrame(None, title="Markdown Image Link Converter@萌狼蓝天(mllt.cc)")
    app.MainLoop()
```

### 效果

{% asset_img image-20240706075502201.png '"image-20240706075502201" "文章配图"' %}
