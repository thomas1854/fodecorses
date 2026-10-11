# Usage: ./run.sh main.cpp sub.cpp
# $1 = first solution file, $2 = second solution file

# Compile both programs; if either compile fails, stop the script right away
g++ $1 -o main || exit 1
g++ $2 -o sub || exit 1

# Run the main program on every input file and save its outputs
for file in ./inputs/*.in; do
	# Skip if the file doesn't really exist
	[ -f "$file" ] || continue
	# Get just the file name (without the folder)
	filename=$(basename "$file")
	
	# Feed the input to the program and save the result as .out
	./main < $file > "./output-main/${filename%.in}.out"
	done

# Do the same for the second program
for file in ./inputs/*.in; do
	[ -f "$file" ] || continue
	filename=$(basename "$file")
	./sub < $file > "./output-sub/${filename%.in}.out"
	done




# Compare every output of main with the matching output of sub
for file in ./output-main/*.out; do
    [ -f "$file" ] || continue

    name=$(basename "$file")
    expected="./output-sub/$name"

    # Compare outputs, ignoring whitespace differences
    # (tr puts each word on its own line, sed removes empty lines)
    if ! diff -w -B <(tr -s '[:space:]' '\n' < $file | sed '/^$/d') \
                    <(tr -s '[:space:]' '\n' < "$expected" | sed '/^$/d') > /dev/null; then
    # Outputs differ: print which test failed and stop
    echo "WA on test ${name%.out}"
        exit 1
    fi
done

# Every test matched
echo "AC"
