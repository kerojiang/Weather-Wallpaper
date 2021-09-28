#!/bin/bash

#自定义字体位置
fontPath='/usr/share/fonts/myfonts/GuDianLiShu.ttf'
#位置留空则自动根据当前ip获取天气信息
location='黄埔区南岗'
#天气信息格式,天气,温度,体感温度,湿度,风向,降水,气压,日出时间,日落时间
wInfoTxt=$HOME'/图片/winfo.txt'
#天气(中文),unsplash用中文查询天气壁纸不太准,所以英文天气用于查询,中文用于显示
#wzhTxt=$HOME'/图片/wzh.txt'
#一言
oneTxt=$HOME'/图片/one.txt'
#天气临时壁纸
tempImg=$HOME'/图片/weatherTemp.png'
#天气壁纸
img=$HOME'/图片/weather.png'
#颜色数组
colorArray=("#ffb3a7" "#f00056" "#ff4c00" "#c32136" "#9d2933" "#ffa400" "#a88462" "#d9b611" "#60281e" "#9c5333" "#789262" "#0aa344" "#0c8918" "#3de1ad" "#bbcdc5" "#177cb0" "#4b5cc4" "#b0a4e3" "#4a4266" "#3eede7" "#f2fdff" "#fcefe8" "#f0f0f4" "#7397ab" "#75878a" "#30dff3" "#88ada6" "#41555d" "#725e82" "#622a1d" "#493131" "#f2be45" "#a78e44" "#bacac6" "#d6ecf0") 




while :
do
  curl -s -m 5 -o $wInfoTxt 'https://wttr.in/'$location'?format="%C,%t,%f,%h,%w,%p,%P,%S,%s"&lang=zh'

  #curl -s -m 5 -o $wzhTxt 'https://wttr.in/'$location'?format="%C"&lang=zh'

  curl -s -m 5 -o $oneTxt  'https://v1.hitokoto.cn/?encode=text'

  if [ -s "$wInfoTxt" ]; then
  # if [ -s "$wzhTxt" ]; then
     if [ -s "$oneTxt" ]; then
       # wzh=$(cat $wzhTxt)
        #去除""符号
       # wzh=${wzh//\"/}

        onezh=$(cat $oneTxt)

        wInfoTemp=$(cat $wInfoTxt)

        #去除""符号
        wInfoTemp=${wInfoTemp//\"/}

        #大写转换为小写
        wInfoTemp=${wInfoTemp,}

        #天气
        weather=`echo $wInfoTemp | awk -F ',' '{print $1}'`
        #空格转换为-,unsplash网站格式要求
        #weather=`echo $weather | sed 's/ /-/g'`

        #温度
        temperature=`echo $wInfoTemp | awk -F ',' '{print $2}'`
        temperature=`echo $temperature | awk -F '+' '{print $2}'`

        #体感温度
        feelTemp=`echo $wInfoTemp | awk -F ',' '{print $3}'`
        feelTemp=`echo $feelTemp | awk -F '+' '{print $2}'`

        #湿度
        humidity=`echo $wInfoTemp | awk -F ',' '{print $4}'`

        #风向
        wind=`echo $wInfoTemp | awk -F ',' '{print $5}'`

        #降水
        precipitation=`echo $wInfoTemp | awk -F ',' '{print $6}'`

        #气压
        pressure=`echo $wInfoTemp | awk -F ',' '{print $7}'`

        #日出时间
        sunrise=`echo $wInfoTemp | awk -F ',' '{print $8}'`

        #日落时间
        sunset=`echo $wInfoTemp | awk -F ',' '{print $9}'`

        #当前时间
        currentTime=$(date "+%H:%M:%S")
      


        #获取天气壁纸
        #wget -q  -T 5 -O $tempImg https://source.unsplash.com/1920x1080?$weather
        wget -q  -T 5 -O $tempImg https://source.unsplash.com/1920x1080?wallpapers

        if [ -s "$tempImg" ]; then
           #获取tempImg文件大小
           tempImgSize=$(ls -l $tempImg | awk '{print $5}')
           #判断当前tempImg是否有效,用tempImg替代img
           if [ "$tempImgSize" -gt "10000" ]; then
      
            #随机中国色
            color=${colorArray[$RANDOM%35+1]}
             
             #在图片输出信息
             convert -fill $color -font $fontPath -pointsize 40 -draw "text 1300,100 '$weather  $temperature' " -draw "text 1350,160 '体感 $feelTemp'"  $tempImg $tempImg
           
             convert -fill $color -font $fontPath -pointsize 30 -draw "text 1650,100 '湿度 $humidity'" -draw "text 1650,140 '风向 $wind'" -draw "text 1650,180 '降水 $precipitation'" $tempImg $tempImg
           
              convert -fill $color -font $fontPath -pointsize 30 -draw "text 1400,220 '日出 $sunrise'" -draw "text 1600,220 '日落 $sunset'" $tempImg $tempImg
            
              convert -fill $color -font $fontPath -pointsize 30 -draw "text 1450,270 '更新时间 $currentTime'" $tempImg $tempImg
            
              convert -fill $color -font $fontPath -pointsize 25 -draw "text 1330,315 '$onezh'" $tempImg $tempImg
            
              mv -f  $tempImg $img
       
              backPath=$(gsettings get org.gnome.desktop.background picture-uri | awk '{print $1}')
              #背景设置一次就可以
              if [ "$backPath" !=  "'file:/'$img" ]; then
                 gsettings set org.gnome.desktop.background picture-uri 'file://'$img
              fi
            fi
         fi
         #rm $wInfoTxt $wzhTxt $oneTxt  
         rm $wInfoTxt $oneTxt  
     fi
  # fi
 fi
  sleep 600 #停10分钟再执行
done
