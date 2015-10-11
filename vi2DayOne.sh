#!/bin/bash
#
# October 11, 2015 - John Raymonds
#
# WARNING -- THIS SCRIPT IS NOT MEANT TO BE A UNIVERSAL viJournal TO DayOne CONVERTER!!!
# You WILL need to edit this script to get it to work and it may not work at all given
# how deeply you used the features in viJournal. This script relies on rtftomarkdown.rb
# (https://gist.github.com/ttscoff/3861434) which seems to work generally well but still
# produced output that needed a lot of edits in certain circumstances (like pasted web
# content in viJournal). I have no idea if this is an issue with the content or the ruby
# script and since it only effected about 3% of my entries I did not care to find a
# better solution.
#
# IT IS HIGLY SUGGESTED -- EVEN IF YOU THINK YOU KNOW WHAT YOU ARE DOING -- TO EXPERIMENT
# ON SINGLE EXPORTED ENTRIES AND THEN MOVE ONTO LARGER BATCHES. EITHER WAY -- KEEPING
# A FULL BACKUP OF YOUR ORIGINAL DayOne JOURNAL SHOULD NOT BE CONSIDERED OPTIONAL!!!
# 
# Read all the comments in this script and then edit as needed. After getting the script
# ready go to viJournal and select the entries you want to export. Then go to:
#
# File->Export Selected Entries...->Separate Files (One Per Entry)...
#
# and export into the same directory as this script. Then go into Terminal and execute
# this script. I did it by making the script executable:
#
# chmod +x vi2DayOne.sh
#
# and then after navigating to the directory doing:
#
# ./vi2DayOne.sh
#
# process all .rtf files in the current directory
# needs rtftomarkdown.rb in the current directory as well
#
for file in *.rtf
do
 # do something on "$file"
 # convert the rtf files to markdown with a ruby script
 #
 ./rtftomarkdown.rb "$file"
 rm "$file"
done

for file in *.rtfd
do
 # do something on "$file"
 # convert the rtf directories to markdown with the same ruby script
 #
 ./rtftomarkdown.rb "$file"
 #
 # we are not going to remove the Rich Text Format Directory as these are the most
 # problematic and keeping them here is a good reference to go back and check manually
 #rm -r "$file"
done

for file in *.md
do
 # do something on "$file"
 # kill off the first few lines that viJournal uses to insert the date
 # the first '' in the sed command means we do not want a backup file
 #
 sed -i '' 1,4d "$file"
 #
 # add a tag to the first line of the file
 #
 # we will manually edit the entries to add a newline after the tag and to convert
 # it into an actual journal tag within DayOne since the dayone CLI does NOT do this
 # for us. The easiest way I have found to cycle through the new entries with tags is
 # to the Calendar view in the app and click on the search icon. From there type in
 # 'JournalTag' and if you use unique tags you will only see the newly imported entries.
 # Thankfully DayOne remembers not only the search parameters but also the entry you
 # clicked on to view detail or edit. Thus, it is easy to go through the whole list
 # of newly imported entries by cycling through the calendar, search, and detail
 # screens.
 #
 # IF YOU DO NOT WANT TO ADD A TAG COMMENT OUT THE LINE BELOW
 # IF YOU DO WANT A TAG -- THEN CHANGE 'JournalTag' TO WHATEVER TAG YOU WISH
 #
 sed -i '' $'1i\\\n#JournalTag\n' "$file"
done

for file in *.md
do
 # do something on "$file"
 # the following assumes a journal name of EXACTLY 8 characters like "Personal"
 # as shown on the next line. If your export does not match this length then you
 # will need to adjust all of the cut values.
 #
 # Personal 2014-01-18.rtf
 #
 # This also assumes DD/MM/YYYY format works -- if you are in a country that uses
 # different formatting you will probably need to change the order
 #
 year="$(echo "$file" | cut -c 10,11,12,13)"
 day="$(echo "$file" | cut -c 15,16)"
 month="$(echo "$file" | cut -c 18,19)"
 theDate=\"$day"/"$month"/"$year" 12:00PM"\"
 #
 # after we parsed the date format into something we know works for the CLI
 # then use the CLI to create our entries
 #
 /usr/local/bin/dayone -d="$theDate" -s=false new < "$file"
 #
 # if you want to keep the .md files around as a reference while you manually edit
 # or otherwise adjust the newly imported entries simply comment out the line below
 #
 rm "$file"
done