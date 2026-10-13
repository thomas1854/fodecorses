<<<<<<< HEAD
# Stress/compare script: checks a second solution against a main (reference) solution.
# Usage: ./run.sh main.cpp sub.cpp <time_limit_seconds>
#   $1 = reference solution (its output is treated as the correct answer)
#   $2 = solution being tested
#   $3 = time limit per test, in seconds (applied via `timeout`)
# Expects: ./inputs/*.in as test inputs, and ./output-main and ./output-sub
#          directories to already exist for the generated outputs.
=======
g++ -O2 -std=c++20 "$1" -o sub
>>>>>>> 4b010f7 (feat: modified run script and added build script)

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