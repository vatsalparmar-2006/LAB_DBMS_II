------------------------EXTRA SP---------------------------


--1.	Write a stored procedure to return course-wise student count for a specific semester.
CREATE OR ALTER PROC PR_COURSE_STUDENT_COUNT 
    @Semester INT
AS
BEGIN
    SELECT C.CourseName, COUNT(E.StudentID) AS StudentCount
    FROM COURSE C
    LEFT JOIN ENROLLMENT E
    ON C.CourseID = E.CourseID
    WHERE C.Semester = @Semester
    GROUP BY C.CourseName
END

--2.	Create a stored procedure that returns all students who have completed 2 or more than 2 courses.
CREATE OR ALTER PROC PR_STUDENTS_COMPLETED_2_OR_GT2
AS
BEGIN
    SELECT S.Name, COUNT(E.CourseID) AS CompletedCourses
    FROM STUDENT S
    JOIN ENROLLMENT E
    ON S.StudentID = E.StudentID
    WHERE E.Status = 'Completed'
    GROUP BY S.Name
    HAVING COUNT(E.CourseID) >= 2
END

--3.	Create a stored procedure to list students without any active enrollment.

CREATE OR ALTER PROC PR_STUDENTS_NO_ACTIVE
AS
BEGIN
    SELECT Name
    FROM STUDENT
    WHERE StudentID NOT IN (
        SELECT StudentID
        FROM ENROLLMENT
        WHERE Status = 'Active' 
    )
END

--OR
CREATE OR ALTER PROC PR_STUDENTS_NO_ACTIVE
AS
BEGIN
    SELECT S.Name
    FROM STUDENT S
    LEFT JOIN ENROLLMENT E
    ON S.StudentID = E.StudentID AND E.Status = 'Active'
    WHERE E.EnrollmentID IS NULL
END

--4.	Write a stored procedure to list faculty who teach more than one course in the same year.
CREATE OR ALTER PROC PR_FACULTY_MULTIPLE_COURSES
AS
BEGIN
    SELECT F.Name, CA.Year, COUNT(CA.CourseID) AS CourseCount
    FROM FACULTY F
    JOIN COURSE_ASSIGNMENT CA
    ON F.FacultyID = CA.FacultyID
    GROUP BY F.Name, CA.Year
    HAVING COUNT(CA.CourseID) > 1
END

--5.	Create a stored procedure to find faculty who are not assigned any course in a given year.
CREATE OR ALTER PROC PR_FACULTY_NO_COURSE 
    @Year INT
AS
BEGIN
    SELECT F.Name
    FROM FACULTY F
    LEFT JOIN COURSE_ASSIGNMENT CA
    ON F.FacultyID = CA.FacultyID AND CA.Year = @Year
    WHERE CA.AssignmentID IS NULL
END

--6.	Write a stored procedure to fetch top N students based on number of completed courses.
CREATE OR ALTER PROC PR_TOPN_STUDENTS 
    @TopN INT
AS
BEGIN
    SELECT TOP (@TopN) S.Name, COUNT(E.CourseID) AS CompletedCourses
    FROM STUDENT S
    JOIN ENROLLMENT E
    ON S.StudentID = E.StudentID
    WHERE E.status = 'Completed'
    GROUP BY S.Name
    ORDER BY CompletedCourses DESC
END

--7.	Write a stored procedure that returns students with at least one Active and one Completed course.
CREATE OR ALTER PROC PR_STUDENTS_ACTIVE_COMPLETED
AS
BEGIN
    SELECT DISTINCT S.Name
    FROM STUDENT S
    JOIN ENROLLMENT E1 ON S.StudentID = E1.StudentID
    JOIN ENROLLMENT E2 ON S.StudentID = E2.StudentID
    WHERE E1.Status = 'Active'
      AND E2.Status = 'Completed'
END

--OR
CREATE OR ALTER PROC PR_STUDENTS_ACTIVE_COMPLETED
AS
BEGIN
    SELECT S.Name
    FROM STUDENT S
    JOIN ENROLLMENT E ON S.StudentID = E.StudentID
    WHERE E.Status IN ('Active', 'Completed')
    GROUP BY S.Name
    HAVING COUNT(DISTINCT E.Status) = 2
END

--8.	Write a stored procedure to return students whose age is below a given value.
CREATE OR ALTER PROC PR_STUDENTS_BELOW_AGE 
    @Age INT
AS
BEGIN
    SELECT Name, DATEDIFF(YEAR, DateOfBirth, GETDATE()) AS Age
    FROM STUDENT
    WHERE DATEDIFF(YEAR, DateOfBirth, GETDATE()) < @Age
END

--9.	Create a stored procedure that returns courses never enrolled by any student.
CREATE OR ALTER PROC PR_COURSES_NEVER_ENROLLED
AS
BEGIN
    SELECT C.CourseName
    FROM COURSE C
    LEFT JOIN ENROLLMENT E
    ON C.CourseID = E.CourseID
    WHERE E.EnrollmentID IS NULL
END

--10.	Write a stored procedure to display students enrolled in the latest semester of their department.
CREATE OR ALTER PROC PR_STUDENTS_LATEST_SEMESTER
AS
BEGIN
    SELECT DISTINCT S.Name, C.Semester
    FROM STUDENT S
    JOIN ENROLLMENT E ON S.StudentID = E.StudentID
    JOIN COURSE C ON E.CourseID = C.CourseID
    WHERE C.Semester = (
        SELECT MAX(Semester)
        FROM COURSE
        WHERE Department = S.Department
    )
END
--output not checked

--11.	Write a stored procedure that returns students with at least one Active and one Completed course.
CREATE OR ALTER PROC PR_DEPT_HIGHEST_ENROLLMENT 
AS
BEGIN
    SELECT Department, CourseName, COUNT(StudentID) AS StudentCount
    FROM COURSE C, ENROLLMENT E
    WHERE C.CourseID = E.CourseID
    GROUP BY Department, CourseName
    HAVING COUNT(StudentID) >= all (
        SELECT COUNT(E2.StudentID)
        FROM COURSE C2 join ENROLLMENT E2
        on C2.CourseID = E2.CourseID
        where C2.Department = C.Department
        GROUP BY C2.CourseName
    )
END







--11.
CREATE OR ALTER PROC PR_DEPT_HIGHEST_ENROLLMENT
AS
BEGIN
    SELECT C.Department, C.CourseName, COUNT(E.StudentID) AS StudentCount
    FROM COURSE C
    JOIN ENROLLMENT E ON C.CourseID = E.CourseID
    GROUP BY C.Department, C.CourseName
    HAVING COUNT(E.StudentID) = (
        SELECT MAX(CNT)
        FROM (
            SELECT COUNT(E2.StudentID) AS CNT
            FROM COURSE C2
            JOIN ENROLLMENT E2 ON C2.CourseID = E2.CourseID
            WHERE C2.Department = C.Department
            GROUP BY C2.CourseName
        ) T--It gives a temporary name to the subquery result so the outer query can refer to it.
    )
END