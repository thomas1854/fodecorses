g++ -O2 -std=c++20 "$1" -o sub

status=$?

if [ "$status" -ne 0 ]; then
    echo "Compilation Error"
    exit 1
fi

for file in ./inputs/*.in; do
    [ -f "$file" ] || continue
    
    filename=$(basename "$file")

    main_out=$(tr -s '[:space:]' '\n' < "./output-main/${filename%.in}.out" | sed '/^$/d')

    sub_out=$(timeout "${2}s" ./sub < "$file")

    status=$?

    if [ "$status" -eq 124 ]; then
        echo "TLE on test ${filename%.in}"
        exit 124

    elif [ "$status" -ne 0 ]; then
        echo "RE on test ${filename%.in}"
        exit 1
    fi

    sub_out=$(printf '%s' "$sub_out" | tr -s '[:space:]' '\n' | sed '/^$/d')
    
    if [ "$sub_out" != "$main_out" ]; then
        echo "WA on test ${filename%.in}"
        exit 1
    fi
done

echo "AC"
