g++ -O2 -std=c++20 "$1" -o main

status=$?

if [ "$status" -ne 0 ]; then
    echo "Compilation Error"
    exit 1
fi

for file in ./inputs/*.in; do
	[ -f "$file" ] || continue
	
	filename=$(basename "$file")
	
	timeout "$2"s  ./main < $file > "./output-main/${filename%.in}.out"
	
	status=$?

	if [ "$status" -eq 124 ]; then
        echo "TLE on test ${filename%.in}"
        exit 124

    elif [ "$status" -ne 0 ]; then
        echo "RE on test ${filename%.in}"
        exit 1
    fi

done