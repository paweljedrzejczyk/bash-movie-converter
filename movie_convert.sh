#!/bin/bash

###############################################################
# Bash script for converting movies and generating website
#
# Author: Paweł Jędrzejczyk <pawel.jedrzejczyk@pjwstk.edu.pl>
# Album number: 11643
# Date: 22.12.2013r.
# 
# Dependencies: libav-tools
# Tested on Ubuntu 12.04 LTS
###############################################################

html_style() {
	echo "
	<style type='text/css'>
	body {
		margin-top: 100px;
		max-width: 640px;
		margin: 0 auto;
		background: #F9E9C8;
		font-family: Arial, sans-serif;
	}
	
	h1 {
		color: #66532B;
	}
	
	h2 {
		color: #B19967;
	}
	
	.movie img {
		max-width: 100%;
		width: 100%;
		height: auto;
		display: block;
	}
	
	p {
		color: #B19967;
	}
	
	</style>
	"
}


movie_item() {
	echo "
	<div class='movie'>
		<a href='"$1".html'><img src='"$1".jpg' alt=''/></a>
		<p>"$1"</p>
	</div>
	" 
	
	echo "$(html_header)
		<h1>"$1"</h1>
		<video width='640' height='480' controls>
			<source src='"$1".mp4' type='video/mp4'>
			<source src='"$1".ogg' type='video/ogg'>
		</video>
	$(html_footer)" >> ${1}.html
}

html_header() {
	echo "
	<!doctype html>
	<html>
	<head>
		<title>PJWSTKtube</title>
		<meta charset='utf-8' />
		$(html_style)
	</head>
	<body>
		<h1>Welcome to PJWSTKtube</h1>
	"
}

html_footer() {
	echo "
	</body>
	</html>
	"
}

if [ $1 = "-h" ] || [ $1 = "--help" ]
then
	echo -e "Script for converting all movies from specified \ndirectory and generating website"
	echo
	echo "Usage: ./movie_convert.sh directory"
	exit
fi

if [[ -z $1 ]]
then
	echo "Directory must be specified"
	exit
fi

files=$(find $1 -iregex '.*\(avi\|mpeg\|flv\|mp4\|m4v\)' 2> /dev/null)

if [[ -n $files ]]
then

	html_header > index.html

	for f in $files
	do
	
		file=$f
		
		echo "Movie: "$file
		
		filename=$(echo ${file%.*} | sed -e 's/\//_/g');

		hours=$(avprobe $file 2>&1 | grep "Duration" | sed -e 's/.* \([[:digit:]]\{2\}\):\([[:digit:]]\{2\}\):\([[:digit:]]\{2\}\).\([[:digit:]]*\).*/\1/')
		minutes=$(avprobe $file 2>&1 | grep "Duration" | sed -e 's/.* \([[:digit:]]\{2\}\):\([[:digit:]]\{2\}\):\([[:digit:]]\{2\}\).\([[:digit:]]*\).*/\2/')
		total_minutes=$(($hours*60+$minutes))


		if [ $total_minutes -lt 3 ]
		then
			echo "Generating thumbnail from the beginning of the movie"
			avconv -i $file ${filename}.jpg &> /dev/null
		else
			echo "Generating thumbnail from the 3rd minute"
			avconv -i $file -ss 00:03:00 ${filename}.jpg &> /dev/null
		fi
		
		echo "Converting"
		avconv -i $file ${filename}.mp4 &> /dev/null
		avconv -i $file ${filename}.ogg &> /dev/null
		
		echo "Done"
		echo
		
		movie_item ${filename} >> index.html
	
	done
	
	html_footer >> index.html
	
	echo "Open index.html in your browser"

else
	echo "No movies found"
	exit
fi
