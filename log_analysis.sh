#Getting all the files which has winning chances 
cat Final_lor_api | grep 'winningChances' > log_with_only_winning_chances

#Removing all the comma, space, collen
tr ',"{}[]:' ' ' < log_with_only_winning_chances > 23110100_lor_api_with_no_commas

awk '{
    # Initialize variables to store extra numbers
    Date_log = $1
    Time_log_h = $2  
    Time_log_m = $3 
    Time_log_s = $4 
    extra_1 = "";
    extra0 = "";
    extra1 = "";
    extra2 = "";
    extra3 = "";
    extra4 = "";
    extra5 = "";
    extra6 = "";
    extra7 = "";
    extra8 = "";

    # Check if there are extra numbers
    if ($28 != "" && $35 != "" &&  $33==2) {
        extra_1 = gensub(/[^0-9]*/, "", "g", $28);
        extra0 = gensub(/[^0-9]*/, "", "g", $35);
    }
    if ($37 != "" && $44 != "" &&  $42==2) {
        extra1 = gensub(/[^0-9]*/, "", "g", $37);
        extra2 = gensub(/[^0-9]*/, "", "g", $44);
    }
    if ($46 != "" && $53 != "" &&  $51==2) {
        extra3 = gensub(/[^0-9]*/, "", "g", $46);
        extra4 = gensub(/[^0-9]*/, "", "g", $53);
    }
    if ($55 != "" && $62 != "" &&  $60==2) {
        extra5 = gensub(/[^0-9]*/, "", "g", $55);
        extra6 = gensub(/[^0-9]*/, "", "g", $62);
    }
    if ($64 != "" && $71 != "" &&  $69==2) {
        extra7 = gensub(/[^0-9]*/, "", "g", $64); 
        extra8 = gensub(/[^0-9]*/, "", "g", $71);
    }

    # Print extra numbers on separate lines if they exist
    if (extra_1 != "" && extra0 != "") {
        printf "%s %s:%s:%s, %s, %s\n", Date_log, Time_log_h,Time_log_m,Time_log_s, extra_1, extra0;
    }
    if (extra1 != "" && extra2 != "") {
        printf "%s %s:%s:%s, %s, %s\n", Date_log, Time_log_h,Time_log_m,Time_log_s, extra1, extra2;
    }
    if (extra3 != "" && extra4 != "") {
        printf "%s %s:%s:%s, %s, %s\n", Date_log, Time_log_h,Time_log_m,Time_log_s, extra3, extra4;
    }
    if (extra5 != "" && extra6 != "") {
        printf "%s %s:%s:%s, %s, %s\n", Date_log, Time_log_h,Time_log_m,Time_log_s, extra5, extra6;
    }
    if (extra7 != "" && extra8 != "") {
        printf "%s %s:%s:%s, %s, %s\n", Date_log, Time_log_h,Time_log_m,Time_log_s, extra7, extra8;
    }
}' 23110100_lor_api_with_no_commas > All_winning_chance_plus_relevant_chance

#Sorting so you can find the first post request
sort -t',' -n -k2 All_winning_chance_plus_relevant_chance > All_winning_chances_after_sorting

#After sorting based on the numbers the duplicate entries are removed. Now you can easily seperate the first post request
input_file="All_winning_chances_after_sorting"

# Output file
output_file="First_API_Post"

# Create an associative array to store unique numbers
declare -A seen_numbers

# Read each line from the input file
while IFS=, read -r timestamp number rest; do
    # Check if the number is not in the associative array
    if [[ ! -n ${seen_numbers["$number"]} ]]; then
        # Save the line to the output file
        echo "$timestamp, $number, $rest" >> "$output_file"
        # Mark the number as seen in the associative array
        seen_numbers["$number"]=1
    fi
done < "$input_file"

#Extracting the relevant entries in the relord log
while IFS=, read -r col1 col2 _ _ _ _ _ _ col9 _ _; do
    # Check if col9 contains a space
    if [[ "${col9}" = " " ]]; then
        # Assign 0 to col9
        col9=" "0
    fi

    # Print the formatted output
    echo "$col1,$col2,$col9"
done < Final_lor_reload > Entries_of_relord_log


 #Removing the , for easy extration 
 tr ',' ' ' < First_API_Post > API_first_post_no_commas
 tr ',' ' ' < Entries_of_relord_log > Entries_of_relord_log_no_commas

#Primary key mapping
awk 'NR==FNR{a[$3]=$0; next} $3 in a {print a[$3] " "$1 " " $2 " " $4}' API_first_post_no_commas Entries_of_relord_log_no_commas > Relord_log_plus_First_API_relord

#Mapping based on time stamp
# Input log file
input_file="Relord_log_plus_First_API_relord"

# Output file
output_file="IR_logging_before_putting_relord"
output_file1="IR_logging_after_putting_relord"

while IFS=' ' read -r date1 time1 col1 col2 date2 time2 col4; do
  # Parse date and time components
  IFS='/' read -r day1 month1 year1 <<< "$date1"
  IFS=':' read -r hour1 minute1 second1 <<< "$time1"
  IFS='/' read -r day2 month2 year2 <<< "$date2"
  IFS=':' read -r hour2 minute2 second2 <<< "$time2"

  # Convert YY to YYYY
  year1="20${year1}"
  year2="20${year2}"

  # Convert dates and times to timestamp for comparison
  timestamp1=$(date -d "${year1}-${month1}-${day1} ${hour1}:${minute1}:${second1}" +"%s" 2>/dev/null)
  timestamp2=$(date -d "${year2}-${month2}-${day2} ${hour2}:${minute2}:${second2}" +"%s" 2>/dev/null)

  # Check if timestamps are valid integers
  if [ -n "$timestamp1" ] && [ -n "$timestamp2" ] 2>/dev/null; then
    # Compare timestamps
    if [ "$timestamp1" -lt "$timestamp2" ]; then
      # Save the specified columns to the output file
      echo "$col1, $col2">> "$output_file"
    else 
      # Echo "sad" when the condition is not met
      echo "$col1, $col2, $col4" >> "$output_file1"
    fi
  fi
done < "$input_file"

awk -F', *' '{ sum[$1] += $3; second[$1] = $2 } END { for (key in sum) print key ", " second[key] ", " sum[key] }' IR_logging_after_putting_relord > IR_logging_after_putting_relord_sum
awk '{print $1, $2-$3}' IR_logging_after_putting_relord_sum > IR_of_logging_after_putting_relord
cat IR_logging_before_putting_relord IR_of_logging_after_putting_relord >IR_BF_relord
cat IR_BF_relord | awk -F',' '!seen[$1]++' > Megga_Wassana_Initial_Count

#Getting the final request
sort -t',' -n -k2,2 -k1,2r All_winning_chance_plus_relevant_chance > Sorting_RO_Winning_Chance
cat Sorting_RO_Winning_Chance | awk -F',' '!seen[$2]++' | awk -F', ' '{print $2, $3}' > Megga_Wassana_Final_Count

#Getting the relord in the relevant time frame. 
cat Sorting_RO_Winning_Chance | awk -F',' '!seen[$2]++' > Last_API_Post

tr ',' ' ' < Last_API_Post > Last_API_Post_no_commas
tr ',' ' ' < First_API_Post > First_API_Post_no_commas
#Check why some number is missing
awk 'NR==FNR{a[$3]=$0; next} $3 in a {print a[$3] " "$1 " " $2 " " $4}' Last_API_Post_no_commas First_API_Post_no_commas > First_Last_API_Post

awk 'NR==FNR{a[$3]=$0; next} $3 in a {print a[$3] " "$1 " " $2 " " $4}' First_Last_API_Post Entries_of_relord_log_no_commas > Join_First_last_relord_entries

#Time comparision
input_file="Join_First_last_relord_entries"

# Output file
output_file="Relord_entries_in_time_frame"
output_file1="Check"

while IFS=' ' read -r date1 time1 col1 col2 date2 time2 col3 date3 time3 col4 ; do
  # Parse date and time components
  IFS='/' read -r day1 month1 year1 <<< "$date1"
  IFS=':' read -r hour1 minute1 second1 <<< "$time1"
  IFS='/' read -r day2 month2 year2 <<< "$date2"
  IFS=':' read -r hour2 minute2 second2 <<< "$time2"
  IFS='/' read -r day3 month3 year3 <<< "$date3"
  IFS=':' read -r hour3 minute3 second3 <<< "$time3"

  # Convert YY to YYYY
  year1="20${year1}"
  year2="20${year2}"
  year3="20${year3}"

  # Convert dates and times to timestamp for comparison
  timestamp1=$(date -d "${year1}-${month1}-${day1} ${hour1}:${minute1}:${second1}" +"%s" 2>/dev/null)
  timestamp2=$(date -d "${year2}-${month2}-${day2} ${hour2}:${minute2}:${second2}" +"%s" 2>/dev/null)
  timestamp3=$(date -d "${year3}-${month3}-${day3} ${hour3}:${minute3}:${second3}" +"%s" 2>/dev/null)

  # Check if timestamps are valid integers
  if [ -n "$timestamp1" ] && [ -n "$timestamp2" ] && [ -n "$timestamp3" ] 2>/dev/null; then
    # Compare timestamps
    if [ "$timestamp2" -lt "$timestamp3" ] && [ "$timestamp3" -lt "$timestamp1" ]; then
      # Save the specified columns to the output file
      echo "$col1,$col4" >> "$output_file"
    else
      echo "$col1,$col4" >> "$output_file1"
    fi
  fi
done < "$input_file"

#Getting the final coumnt of the relord log
awk -F',' '{count[$1]++; sum[$1]+=$2} END {for (key in count) print key, sum[key]}' Relord_entries_in_time_frame >> Megga_Wassana_Relord_Count

#Getting the scratch quantity in relevant time frame
#Getting only the scratch logs
awk -F', ' '/\{"status":1/ && $6=="scratch" {for(i=1; i<=20; i++) if($i) printf "%s%s", $i, (i==20)?"":", "; print ""}' Final_lor_api > All_the_scratch_logs

#Removing all the comma, space, collen
tr ',"{}[]' ' ' < All_the_scratch_logs > All_the_scratch_logs_no_commas
#awk -F'[:,"]+' '/"number"/ {printf "%s\n", $13}' All_the_scratch_logs > Getting_only_the_number_in_scratch
awk '{print $1 " " $2 ", " $12   }' All_the_scratch_logs_no_commas > Scratch_num_with_Time_frame

awk 'NR==FNR{a[$3]=$0; next} $3 in a {print a[$3], $1 " " $2 1}' First_Last_API_Post Scratch_num_with_Time_frame > Join_First_last_scratch_entries

#Time comparision
input_file="Join_First_last_scratch_entries"

# Output file
output_file="Scratch_entries_in_time_frame"
output_file1="Check"


while IFS=' ' read -r date1 time1 col1 col2 date2 time2 col3 date3 time3 col4 ; do
  # Parse date and time components
  IFS='/' read -r day1 month1 year1 <<< "$date1"
  IFS=':' read -r hour1 minute1 second1 <<< "$time1"
  IFS='/' read -r day2 month2 year2 <<< "$date2"
  IFS=':' read -r hour2 minute2 second2 <<< "$time2"
  IFS='/' read -r day3 month3 year3 <<< "$date3"
  IFS=':' read -r hour3 minute3 second3 <<< "$time3"

  # Convert YY to YYYY
  year1="20${year1}"
  year2="20${year2}"
  year3="20${year3}"

  # Convert dates and times to timestamp for comparison
  timestamp1=$(date -d "${year1}-${month1}-${day1} ${hour1}:${minute1}:${second1}" +"%s" 2>/dev/null)
  timestamp2=$(date -d "${year2}-${month2}-${day2} ${hour2}:${minute2}:${second2}" +"%s" 2>/dev/null)
  timestamp3=$(date -d "${year3}-${month3}-${day3} ${hour3}:${minute3}:${second3}" +"%s" 2>/dev/null)

  # Check if timestamps are valid integers
  if [ -n "$timestamp1" ] && [ -n "$timestamp2" ] && [ -n "$timestamp3" ] 2>/dev/null; then
    # Compare timestamps
    if [ "$timestamp2" -lt "$timestamp3" ] && [ "$timestamp3" -lt "$timestamp1" ]; then
      # Save the specified columns to the output file
      echo "$col1,$col4" >> "$output_file"
    else
      echo "$col1,$col4" >> "$output_file1"
    fi
  fi
done < "$input_file"

sort Scratch_entries_in_time_frame | uniq -c | awk '{print $2 " " $1}' >Megga_Wassana_Count_of_scratch

 





















