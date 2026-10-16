# Run build.sh first (compiles the main/reference solution)
bash build.sh ac.cpp $2

# $1: sub-solution $2: time limit in seconds $3: memory limit in MB $4: scope id

# Compile the submitted solution into an executable called "sub"
g++ -O2 -std=c++20 "$1" -o sub

# Save the exit code of the compiler (0 = success)
status=$?

# If compilation failed, print the verdict and stop
if [ "$status" -ne 0 ]; then
    echo "Compilation Error"
    exit 1
fi

# Loop over every input test file
for file in ./inputs/*.in; do
    # Skip if it's not a real file (e.g., the folder is empty)
    [ -f "$file" ] || continue
    
    # Get just the file name without the folder path (e.g., 1.in)
    filename=$(basename "$file")

    # Read the expected output, split it into one word per line, and remove empty lines
    main_out=$(tr -s '[:space:]' '\n' < "./output-main/${filename%.in}.out" | sed '/^$/d')

    # Run the submission with limits:
    # systemd-run limits memory, timeout limits time, input comes from the test file
    sub_out=$(systemd-run --user --quiet --no-ask-password --scope --unit="${4}" -p MemoryMax="${3}M" --working-directory="$PWD" timeout "${2}s" ./sub < "$file")

    # Save the exit code of the run
    status=$?

	# Clear the failed scope record
	systemctl --user reset-failed "${4}.scope" 2>/dev/null

	# 137 = killed (memory limit exceeded)
	if [ "$status" -eq 137 ]; then
		echo "MLE on test ${filename%.in}"
        exit 137
    # 124 = killed by timeout (time limit exceeded)
    elif [ "$status" -eq 124 ]; then
        echo "TLE on test ${filename%.in}"
        exit 124
    # Any other non-zero code = program crashed (runtime error)
    elif [ "$status" -ne 0 ]; then
        echo "RE on test ${filename%.in}"
        exit 1
    fi

    # Clean the submission output the same way: one word per line, no empty lines
    sub_out=$(printf '%s' "$sub_out" | tr -s '[:space:]' '\n' | sed '/^$/d')
    
    # Compare submission output with expected output
    if [ "$sub_out" != "$main_out" ]; then
        echo "WA on test ${filename%.in}"
        exit 1
    fi
done

# All tests passed
echo "AC"