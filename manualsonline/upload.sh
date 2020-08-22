#!/bin/bash

url="$1"

check="yes"
idup="y"
brand="$1"

[ -d $brand ] || mkdir -p $brand
brandurl="www.manualsonline.com/brands/$brand "
[ -f $brandurl ] || wget -x -c $brandurl -P $brand
cat $brand/$brandurl | grep -A1 manual-cta | grep $brand | grep product_list | sed 's|.*href="||g' | sed 's|".*||g' | sed 's|http://||g' | sort | uniq > $brand/plist.txt

for url in $(cat $brand/plist.txt); do
	[ -f $brand/$url ] || wget -x -c $url -P $brand
	#cat $brand/$url | grep '<h5>' | grep href= | sed "s|.*href=\"|$(echo "$url" | sed 's|/manuals/.*||g')|g" | sed 's|".*||g' >> $brand/mlist.txt
	#cat $brand/mlist-u.txt | sort | uniq > $brand/mlist.txt
	mlist="$(cat $brand/$url | grep '<h5>' | grep href= | sed "s|.*href=\"|$(echo "$url" | sed 's|/manuals/.*||g')|g" | sed 's|".*||g')"
#done

for murl in $mlist; do
	echo $murl
	[ -f $brand/$murl ] || wget -x -c $murl -P $brand
	#cat $brand/$murl | grep pdfstream | sed 's|.*href="||g' | sed 's|".*||g' | sort | uniq >> $brand/pdfurls-unsorted.txt
	#cat $brand/pdfurls-unsorted.txt | sort | uniq > $brand/pdfurls.txt
	pdfid="$(cat $brand/$murl | grep pdfasset | grep thumbbase | sed 's|-thumb-.*||g'  | sed 's|.*/||g' | sort | uniq)"
	pdfurls="http://dl.owneriq.net/${pdfid:0:1}/${pdfid}.pdf"
		for pdfurl in $pdfurls; do
			id1="$(basename $pdfurl .pdf)"
			id="manualsonline-id-$id1"
			echo $id
			#echo "$title"
			file="$brand/$(basename $pdfurl)"
			if [ "$idup" = "y" ]; then
				if [ "$(grep $id $brand/ids.txt)" != "" ]; then
					echo "$id was recently uploaded."
					continue
				fi
			fi
			if [ "$check" == "yes" ]; then
				url="archive.org/download/$id"
				[ -f "$url" ] || wget -x -c $url
				if [ -f "$url" ]; then
					if [ "$(grep "$(basename "$file")" $url)" != "" ]; then
						echo "$file is in $url"
						continue
					fi
				fi
			fi
			title="$(cat $brand/$murl | grep '<title>' | head -1 | sed 's|.*<title>||g' | sed 's| \| .*||g')"

			[ -f $file ] || wget -c $pdfurl -O $file

			basekeywords="manualsonline; manuals; ${brand};"

		ia upload $id "$file" -H "x-archive-check-file:0" -H "x-archive-queue-derive:0" \
			--metadata="collection:godaneinbox" \
			--metadata="mediatype:texts" \
			--metadata="title:$title" \
			--metadata="subject:${basekeywords}"

			if [ "$idup" == "y" ]; then 
				echo "$id" >> $brand/ids.txt
			fi
		done
	done
done

		
