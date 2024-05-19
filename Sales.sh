#!/bin/bash
echo "1 - data sheet"
echo "2 - total revenue"
echo "3 - monthly sales"
echo "4 - Best Selling Product"
echo "5 - Average Revenue Per Sale"
echo "6 - Date Range"
echo "7 - Product Analysis"
read -p "plaease select what information you would like to access " num

#creates files
if [[ num -eq 1 ]]; then
        echo "Sales Sheet"
        awk -F ',' '{print $1, $2, $3, $4}' sales_data.csv
        awk -F ',' '{print $4}' sales_data.csv > revenue.csv
        awk -F ',' '{print $1, $4}' sales_data.csv | sort > dates_revenue.csv
fi

rm total.txt
touch total.txt
if [[ num -eq 2 ]]; then
        echo "Total Revenue"
        total_sum=$(awk '{total += $1} END {print total}' ./revenue.csv)
        echo "total Revenue: $total_sum"
fi

if [[ num -eq 3 ]]; then
        echo "Monthly Sales"
        cat dates_revenue.csv
fi

if [[ num -eq 4 ]]; then
        echo "Best Selling Product"
        awk -F ',' '{print $2, $3}' sales_data.csv | sort > best_selling.csv
        totalA=$(awk '/A/ {total += $3} END {print total}' best_selling.csv)
        totalB=$(awk '/B/ {total += $3} END {print total}' best_selling.csv)
        totalC=$(awk '/C/ {total += $3} END {print total}' best_selling.csv)
        echo "total of Product A sold: $totalA"
        echo "total of Product B sold: $totalB"
        echo "total of Product C sold: $totalC"
fi

if [[ num -eq 5 ]]; then
        echo "Average Revenue per sale"
        average_revenue_per_sale=$(tail -n +2 sales_data.csv | awk -F ',' '{sum += $4 / $3} END {printf "%.2f\n", sum / NR}')
        echo "Average Revenue per Sale: \$${average_revenue_per_sale}"
fi

if [[ num -eq 6 ]]; then
        echo "Date Range"
        earliest_date=$(tail -n +2 sales_data.csv | sort -t ',' -k1,1n | head -n 1 | cut -d ',' -f1)
        latest_date=$(tail -n +2 sales_data.csv | sort -t ',' -k1,1nr | head -n 1 | cut -d ',' -f1)
        echo "Date Range: ${earliest_date} to ${latest_date}"
fi

if [[ num -eq 7 ]]; then
read -p "Enter a product name: " product_name
        product_units_sold=$(grep "$product_name" sales_data.csv | awk -F ',' '{sum+=$3} END {print sum}')
        product_revenue=$(grep "$product_name" sales_data.csv | awk -F ',' '{sum+=$4} END{printf "%.2f\n", sum}')
        if [ -n "$product_units_sold" ]; then
                echo "Product Analysis for ${product_name}:"
                echo "Total Units Sold: ${product_units_sold}"
                echo "Total Revenue: \$${product_revenue}"
        else
                echo "Product '${product_name}' not found in the dataset."
        fi
fi
