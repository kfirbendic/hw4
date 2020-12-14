#!/bin/bash

/* getting full page html */
wget https://www.ynetnews.com/category/3082

/* taking only articles that end with 9 letters and numbers and sort it into txt */
grep -o -E "https://www.ynetnews.com/article/\b[[:alnum:]]{9}\b" 3082 | sort | uniq |\
cat > templist.txt

/* finding the number of articles */
max_line=$(grep -o -E "https://www.ynetnews.com/article/\b[[:alnum:]]{9}\b" 3082 | sort | uniq\
| cat -n | tail -1 | awk '{print $1}')

/* find how many times Netanyahu or Gantz show in every article and save in templist.txt */
for(( i=1; i<=max_line; i++)); do

	current_line=$(sed -n "${i}p"  templist.txt)  
	wget $current_line

	/* choosing the file name by giving him the last 9 letters and numbers after the fifth slash */
	current_file=$(awk -F/ '{print $5}' templist.txt | sed -n "${i}p") 


	num_of_times_net=$(grep -o Netanyahu $current_file | cat -n | tail -1 |\
	 awk '{print $1}')
	num_of_times_gan=$(grep -o Gantz $current_file | cat -n | tail -1 |\
	 awk '{print $1}')

	/* if Netanyahu or Gantz wasnt in the article, they have no num so we giving them boolean zero */
	((num_of_times_net=num_of_times_net+0))
	((num_of_times_gan=num_of_times_gan+0))
	if	(( num_of_times_net == 0 )) &&  (( num_of_times_gan == 0 ));
	   then 
	   sed -i "s/$current_file/&, -/" templist.txt;
	   else 
	   sed -i\
	    "s/$current_file/&, Netanyahu, $num_of_times_net, Gantz, $num_of_times_gan/" templist.txt;
	fi
	/* removing the file we already checked in this iteration */
	rm $current_file 

done

/* inserting the number of articles into the first line in the results.csv */
echo $max_line > results.csv

/* inserting templist.txt after max_line into the results.txt */
less templist.txt >> results.csv

/* removing files that we dont need anymore */
rm templist.txt
rm "3082"








