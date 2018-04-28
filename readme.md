# Mac下安装rmagick遇到的问题
@(Work Around)[rails, ruby, gem, rmagic, imagemagick, macos, High Sierra]


macOS: **High Sierra 10.13.4**
ruby version: `2.4.2`

```powershell
$ gem install rmagick
```

1. **No package 'MagickCore' found**
```powershell
...
ackage MagickCore was not found in the pkg-config search path.
Perhaps you should add the directory containing `MagickCore.pc'
to the PKG_CONFIG_PATH environment variable
No package 'MagickCore' found
checking for outdated ImageMagick version (<= 6.4.9)... *** extconf.rb failed ***
...
```
第一个问题是因为没有安装 `imagemagick`, 遂安装之，
然后把 PATH 加载一下，重新 `gem install rmagick`
```
$ brew install imagemagick
$ mdfind MagickCore.pc
$ export PKG_CONFIG_PATH=/usr/local/Cellar/imagemagick/7.0.7-28/lib/pkgconfig
```


2.  然后遇到的是 **Can't install RMagick 2.16.0. Can't find MagickWand.h.**

```powershell
$ gem install rmagick
Building native extensions.  This could take a while...
ERROR:  Error installing rmagick:
    ERROR: Failed to build gem native extension.

    current directory: 
    ...
checking for wand/MagickWand.h... no

Can't install RMagick 2.16.0. Can't find MagickWand.h.
*** extconf.rb failed ***
Could not create Makefile due to some reason, probably lack of necessary
libraries and/or headers.  Check the mkmf.log file for more details.  You may
need configuration options.
...
```

参照网上方法，先找到文件`MagickWand.h` , 再加入PATH：
```powershell
$ mdfind MagickWand.h
$ C_INCLUDE_PATH=/usr/local/Cellar/imagemagick/7.0.7-28/include/ImageMagick-7/
```
还是继续这个错误，and then i got this:
> [RMagick installation: Can't find MagickWand.h
](https://stackoverflow.com/questions/39494672/rmagick-installation-cant-find-magickwand-h)

和我是一个版本 **RMagick 2.16.0**, 然后也是安装得了 version 7 的 **imagemagick**，
下面的解决方案是重新安装 version 6。 
```powershell
$ brew unlink imagemagick
# imagemagick@6 is keg-only, so you'll need to force linking.
$ brew install imagemagick@6 && brew link imagemagick@6 --force
```
 记得根据安装提示加入PATH

```powershell
$ echo 'export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"' >> ~/.zshrc
```

3. 仍然出现 **Can't install RMagick 2.16.0. Can't find MagickWand.h.**
    思考了一下可能是`PATH`没换过来，回到第二个问题开始的地方
 
```powershell
$ mdfind MagickWand.h
/usr/local/Cellar/imagemagick@6/6.9.9-40/share/doc/ImageMagick-6/www/api/MagickWand/struct__MagickWand.html
/usr/local/Cellar/imagemagick@6/6.9.9-40/include/ImageMagick-6/wand/magick-wand.h # <= this what we need 
/usr/local/Cellar/imagemagick@6/6.9.9-40/include/ImageMagick-6/wand/MagickWand.h
/usr/local/Cellar/imagemagick/7.0.7-28/share/doc/ImageMagick-7/www/magick-wand.html
...

$ C_INCLUDE_PATH=/usr/local/Cellar/imagemagick@6/6.9.9-40/include/ImageMagick-6/
$ gem install rmagick
Building native extensions.  This could take a while...
Successfully installed rmagick-2.16.0
Parsing documentation for rmagick-2.16.0
Installing ri documentation for rmagick-2.16.0
Done installing documentation for rmagick after 1 seconds
1 gem installed
```

4. 然后开开心心的去coding，发生如下错误:
```powershell
...
 9): Symbol not found: _AdaptiveBlurImage (LoadError)
  Referenced from: /Volumes/external/projects/path/vendor/bundle/ruby/2.2.0/extensions/x86_64-darwin-14/2.2.0-static/rmagick-2.16.0/RMagick2.bundle
  ...
```
或者
```powershell
...
...sions/2.4.2/lib/ruby/2.4.0/rubygems/core_ext/kernel_require.rb:55:in `require': dlopen(/Users/xxx/.rbenv/versions/2.4.2/lib/ruby/gems/2.4.0/gems/rmagick-2.16.0/lib/RMagick2.bundle, 9): Library not loaded: /usr/local/opt/imagemagick/lib/libMagickWand-7.Q16HDRI.5.dylib (LoadError)
...
```

看起来是之前的gem不干净，reinstall一下就好了

```powershell
$ gem uninstall rmagick
$ gem install rmagick
```


5. 写了个demo，运行，报错：
```powershell
$ ruby demo.rb
demo.rb:14:in `display': delegate library support not built-in `test.png' (X11) @ error/display.c/DisplayImages/16056 (Magick::ImageMagickError)
    from demo.rb:14:in `<main>'
```
网搜一堆回答，看来是macOS的问题，卸载原来的 **imagemagick**，用x11的方式再来一次

```powershell
$ brew uninstall imagemagick
$ brew install imagemagick@6 --with-x11
Warning: imagemagick@6: this formula has no --with-x11 option so it will be ignored!
```
看来带版本的 不能这样玩儿啊。官网论坛看一下：
> [**Mac OS X binary is not X11 enabled**](https://imagemagick.org/discourse-server/viewtopic.php?t=32616)
> If your issue is that you cannot display images without X11, then you need to download and install XQuartz. Apple does not provide X11 any more. See https://www.xquartz.org and https://support.apple.com/en-us/HT201341

好的看来装一下 **xquartz**就行
```powershell
$ brew cask install xquartz
==> Satisfying dependencies
==> Downloading https://dl.bintray.com/xquartz/downloads/XQuartz-2.7.11.dmg
########################################                       62.1%
```
装完以后还是不行。

查了半小时Google，发现这个X11的问题只是影响 `display` 这个命令，这个本质上和 `open` 是一样一样的。囧！放弃，只要能合成图片就行了，还要什么自行车。



6. **RMagick: unable to read font `Helvetica'**
    为了能读到系统字体也是麻烦的不行，还需要安装一个不知道用来干嘛的东西。
```powershell
$ brew install gs
```

7. 尝试往图片上写中文乱码
  字体的原因，除了需要安装 **7.** 里面那个扩展，还需要下载中文字体，放在可以访问的路径，最终代码差不多这样，给背景图上加上了图片和文字：
 
```powershell
def composing
  background = Image.read('test.png').first
  avatar = Image.read('499317.jpeg').first

  avatar_resized = avatar.resize_to_fit(40,40)
  avatar_resized.border!(1, 1, 'black')
  avatar_resized.shadow(2, 5, 3)

  marketing_image = background.composite(avatar_resized, 30, 58, OverCompositeOp)

  text = "孙晓迪 askldjaskljdlasd KJ"

  content = Magick::Draw.new
    content.annotate(marketing_image, 0, 0, 60, 550, text) do
     self.font = './ZuiYouTi-2.ttf'
     self.pointsize = 24
     self.font_weight = Magick::BoldWeight
     self.fill = 'black'
     self.gravity = Magick::SouthEastGravity
    end


  marketing_image.write("marketing_image.png")
end
```