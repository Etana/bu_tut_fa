#!/bin/sh

mkdir -p res img

rm res/*

for f in 14 8 1 115 51 99
do
  curl "http://forum.forumactif.com/sitemap$f.xml" | grep -Eo "https?://forum\.forumactif\.com/t[0-9]+-[^<]+" | while read url
  do
    x="res/$(echo "$url" | sed 's/[\/]/|/g').html"
    sleep 0.5
    curl -L "$url" > $x
  done
done

sed -i 's/<head><t/<head><base href="http:\/\/forum.forumactif.com\/"><t/' res/*

cd img

grep -oriEh 'https?://[a-zA-Z0-9~%&+=,.?/_-]+\.(png|jpeg|jpg|gif|webp)' ../res | sort -u | while read f
do
  x=$(echo "$f" | sed 's/[\/]/|/g')
  if [ ! -f "$x" ]
  then
    sleep 0.5
    curl -L "$f" > $x
  fi
done


dead_img=$(file * | grep -Ev ':\s+(PNG|GIF|JPEG|Web/P) image data' | sed -r 's/:\s+.*//g' | sed 's/|/\//g')

cd ../res

tuto_topics=$(grep -rFl "$(echo '<a href="/f14-questions-reponses-frequentes" class="nav">'; echo '<a href="/f8-trucs-et-astuces" class="nav">')")

for dead in $dead_img
do
  dead=$(echo "$dead" | sed 's/|/\//g')
  echo $tuto_topics | xargs grep -Fl "$dead" | sed 's/\.html$//' | sed 's/|/\//g' | xargs -rL1 echo "$dead : "
done > ../list_dead.txt

cd ..

cat list_dead.txt | awk '{print $3, $1}' | sort | awk '{if($1 == save) print "\t[*]"$2; else {if(save!="")print "[/list]\n"; print $1, "\n[list]\n\t[*]" $2; } save=$1}END{print "[/list]"}' > list_dead_by_topic.txt
