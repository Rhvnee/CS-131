#!/bin/bash

#Input data URL
read -p "Enter the URL of the CSV or ZIP file: " url

#Create working dir.
mkdir -p csv_data
cd csv_data || exit 1

#Download the file linked by the user input
filename=$(basename "$url")
curl -L -o "$filename" "$url"

#Check for unzip command installed or not
if [[ "$filename" == *.zip ]]; then

    if ! command -v unzip &> /dev/null; then

        echo " 'unzip' is not installed. Unzip $filename manually and rerun."
        exit 1

    else

        unzip -o "$filename"
        rm "$filename"

    fi

fi

#Find first CSV file
csv_file=$(find . -type f -name "*.csv" | head -n 1)
if [ ! -f "$csv_file" ]; then

    echo "No CSV file."
    exit 1

fi

#Read headers using semicolon delimiter
IFS=';' read -r -a headers < "$csv_file"

# Display features with index numbers
echo "Index | Feature"
echo "------|--------"

for i in "${!headers[@]}"; do

    clean_header=$(echo "${headers[$i]}" | sed 's/^"//;s/"$//')
    echo "$i | $clean_header"

done

#Ask for column index
read -p "Enter comma-separated indices of numerical columns (e.g., 0,1,2): " numeric_indices

#Create summary file
summary_file="summary.md"
echo "# Summary for $(basename "$csv_file")" > "$summary_file"
echo "" >> "$summary_file"

#Feature list
echo "## Feature Index and Names" >> "$summary_file"
for i in "${!headers[@]}"; do

    clean_header=$(echo "${headers[$i]}" | sed 's/^"//;s/"$//')
    echo "$i. $clean_header" >> "$summary_file"

done

#Table header for the summary file
echo "" >> "$summary_file"
echo "## Statistics (Numerical Features)" >> "$summary_file"
printf "| Index | Feature | Min | Max | Mean | StdDev |\n" >> "$summary_file"
printf "|-------|---------|-----|-----|------|--------|\n" >> "$summary_file"

#Convert user input into array index
IFS=',' read -ra num_indices <<< "$numeric_indices"

# Calculate stats for each column
for idx in "${num_indices[@]}"; do

    col_name=$(echo "${headers[$idx]}" | sed 's/^"//;s/"$//')
    awk -F';' -v col="$((idx+1))" -v col_idx="$idx" -v feature="$col_name" '
        NR > 1 && $col ~ /^[0-9.]+$/ {
            x[NR] = $col
            sum += $col
            if (NR == 2 || $col < min) min = $col
            if (NR == 2 || $col > max) max = $col
        }
        END {
            n = NR - 1
            mean = sum / n
            for (i = 2; i <= NR; i++) {
                std += (x[i] - mean)^2
            }
            stddev = sqrt(std / n)
            printf "| %d | %s | %.2f | %.2f | %.3f | %.3f |\n", col_idx, feature, min, max, mean, stddev
        }
    ' "$csv_file" >> "$summary_file"
done

echo ""
echo "Summary written to: $summary_file"

