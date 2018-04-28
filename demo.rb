# encoding=UTF-8
#!/usr/bin/env ruby -w
#
# Simple demo program for RMagick
#
# Concept and algorithms lifted from Magick++ demo script written
# by Bob Friesenhahn.
#
require 'rmagick'
include Magick


# test.png 283 KB
# Small_test.png 158 KB
# 1000 times test
# result:
# => Small_test total: 63.29585313796997, averge: 0.06329585313796997
# => test.png total: 163.59502601623535, averge: 0.16359502601623535

def composing
  background = Image.read('test.png').first
  avatar = Image.read('499317.jpeg').first

  avatar_resized = avatar.resize_to_fit(40,40)
  avatar_resized.border!(1, 1, 'black')
  avatar_resized.shadow(2, 5, 3)

  marketing_image = background.composite(avatar_resized, 30, 58, OverCompositeOp)

  text = "耀你的命 show me your lives!"

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

def minimize
  background = Image.read('test.png').first
  background.minify.write('Small_test.png')
end

start_time = Time.now.to_f

minimize

composing


# 1000.times{
#   composing
# }


# end_time = Time.now.to_f


# spend_time = end_time - start_time

# average_time = spend_time/1000

# p "total: #{spend_time}, averge: #{average_time}"


exit
