# 项目名称

这个项目是rust的代码到ts的转换，并且主要面向cocos creator。

## 介绍

同上。

## 安装

你要先安装(rust环境)[https://www.rust-lang.org/zh-CN/learn/get-started]

然后安装just：
```bash
cargo install just
```

然后：
1. 编译wasm并且到指定路径，你可以自己改路径。
```bash
just build
```

2. 生成模版代码到指定路径，你可以自己改路径
```bash
just gen_by 你的类名
```
