#!/user/bin/awk -f

BEGIN{
	FS = ","
	maxScore = -1
	minScore = 10000
}

#Assume header is the first row, skips
NR==1{
	next
}

{
	studentID = $1
	studentName = $2

	scoreTotal = 0
	courseCount = 0

	for(i = 3; i <= NF; i++) {
		scoreTotal += $i
		courseCount++
	}

	avg = scoreTotal/courseCount

	status = (avg >= 70) ? "Pass" : "Fail"

	#Store Results

	totalScore[studentName] = scoreTotal
	avgScore[studentName] = avg
	studentStatus[studentName] = status #Pass/fail
	studentIDMap[studentName] = studentID #map name to ID

	studentNames[NR] = studentName	#Store name and line number for the chart later
	studentCount++

	if(scoreTotal > maxScore) {
		maxScore = scoreTotal
		topStudent = studentName
	}

	if(scoreTotal < minScore) {
		minScore = scoreTotal
		botStudent = studentName
	}
}

END{
	print"Student Report:"
	print"---------------"

	for (i = 2; i <= studentCount + 1; i++) {

        name = studentNames[i]

	#string, string, int, float, string
        printf("StudentID: %s, Name: %s, Total: %d, Average: %.2f, Status: %s\n",
            studentIDMap[name], name, totalScore[name], avgScore[name], studentStatus[name])

    }

    print "\nTop scoring student:"
    printf("Name: %s, Total: %d\n", topStudent, totalScore[topStudent])

    print "\nLowest scoring student:"     
    printf("Name: %s, Total: %d\n", botStudent, totalScore[botStudent])
}	
