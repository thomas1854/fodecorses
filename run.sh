# Stress/compare script: checks a second solution against a main (reference) solution.
# Usage: ./run.sh main.cpp sub.cpp <time_limit_seconds>
#   $1 = reference solution (its output is treated as the correct answer)
#   $2 = solution being tested
#   $3 = time limit per test, in seconds (applied via `timeout`)
# Expects: ./inputs/*.in as test inputs, and ./output-main and ./output-sub
#          directories to already exist for the generated outputs.

# Compile both programs; if either compile fails, stop the script right away
g++ $1 -o main || exit 1
g++ $2 -o sub || exit 1

# ---- Phase 1: generate the expected outputs using the reference solution ----
# Run the main program on every input file and save its outputs
for file in ./inputs/*.in; do
	# Skip if the file doesn't really exist (e.g. the glob matched nothing)
	[ -f "$file" ] || continue
	# Get just the file name (without the folder), e.g. 1.in
	filename=$(basename "$file")
	
	# Feed the input to the program (limited by $3 seconds) and save the result as .out
	timeout "$3"s  ./main < $file > "./output-main/${filename%.in}.out"
	done

# ---- Phase 2: run the tested solution and compare against the reference ----
# Do the same for the second program, but also judge each test as it finishes
for file in ./inputs/*.in; do
	[ -f "$file" ] || continue
	filename=$(basename "$file")

	# Run the second program under the same time limit
	timeout $3s ./sub < $file > "./output-sub/${filename%.in}.out"
	
	# Save the exit code right away (before any other command overwrites $?)
	status=$?

	# Path of the second program's output (the one we are going to check)
	expected=./output-sub/${filename%.in}.out

	# Exit code 124 means `timeout` killed the program -> Time Limit Exceeded
	if [ "$status" -eq 124 ]; then
		echo "TLE on test ${filename%.in}"
		exit 124
	# Any other non-zero exit code means the program crashed -> Runtime Error
	elif [ "$status" -ne 0 ]; then 
		echo "RE on test ${filename%.in} "
		exit 1

    # Compare the two outputs token by token, ignoring whitespace differences
    # (tr turns every run of whitespace into a single newline so each word sits
    #  on its own line, sed removes empty lines; diff output itself is discarded)
    elif ! diff -w -B <(tr -s '[:space:]' '\n' < ./output-main/${filename%.in}.out | sed '/^$/d') \
                    <(tr -s '[:space:]' '\n' < "$expected" | sed '/^$/d') > /dev/null; then
    # Outputs differ -> Wrong Answer: print which test failed and stop
    echo "WA on test ${filename%.in}"
        exit 1
	fi
	done



# Reaching here means every test passed (no TLE, RE, or WA)
echo "AC"
