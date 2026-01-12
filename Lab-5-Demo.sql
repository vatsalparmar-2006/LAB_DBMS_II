
-- Lab-5 : Cursor Demo

--1. Create a cursor Course_Cursor to fetch all rows from COURSE table and display them.

GO
DECLARE @CID VARCHAR(10), @CNAME VARCHAR(100), @CREDITS INT, @DEPT VARCHAR(50), @SEM INT;

-- 1) DECLARE
DECLARE Course_Cursor CURSOR FOR
SELECT CourseID,CourseName,CourseCredits,CourseDepartment,CourseSemester FROM COURSE;

--2) OPEN
OPEN Course_Cursor

--3) FETCH
FETCH NEXT FROM Course_Cursor INTO @CID,@CNAME,@CREDITS,@DEPT,@SEM

--4) CONDITION
WHILE @@FETCH_STATUS = 0
BEGIN
	-- PRINT CONCAT('ID: ',@CID, ', NAME: ',@CNAME, ', CREDITS: ',@CREDITS, ', DEPARTMENT: ',@DEPT, ', SEM: ',@SEM)

	SELECT @CID AS CourseID,@CNAME AS COURSE,@CREDITS AS CREDITS,@DEPT AS DEPARTMENT,@SEM AS SEMESTER

	FETCH NEXT FROM Course_Cursor INTO @CID,@CNAME,@CREDITS,@DEPT,@SEM
END;

--5) CLOSE - Releases result set (COURSE TABLE)
CLOSE Course_Cursor;

--6) DEALLOCATE - Releases memory and deletes cursor definition
DEALLOCATE Course_Cursor;
GO

--5. Create a cursor Course_CursorUpdate that retrieves all courses and increases Credits by 1 for courses
--with Credits less than 4.

GO
DECLARE @CID VARCHAR(10), @CREDITS INT

DECLARE Course_CursorUpdate CURSOR FOR
SELECT CourseID,CourseCredits FROM COURSE WHERE CourseCredits < 4;

OPEN Course_CursorUpdate;

FETCH NEXT FROM Course_CursorUpdate INTO @CID,@CREDITS;

WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE COURSE SET CourseCredits = CourseCredits + 1
	WHERE CourseID = @CID;

	FETCH NEXT FROM Course_CursorUpdate INTO @CID,@CREDITS;
END;

CLOSE Course_CursorUpdate;

DEALLOCATE Course_CursorUpdate;
GO

--6. Create a Cursor to fetch Student Name with Course Name (Example: Raj Patel is enrolled in Database
--Management System)

GO
DECLARE @SNAME VARCHAR(100), @CNAME VARCHAR(100)

DECLARE Enroll_Cursor CURSOR FOR
SELECT S.StuName,C.CourseName FROM
STUDENT S JOIN ENROLLMENT E
ON S.StudentID = E.StudentID
JOIN COURSE C
ON E.CourseID = C.CourseID

OPEN Enroll_Cursor;

FETCH NEXT FROM Enroll_Cursor INTO @SNAME,@CNAME;

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @SNAME + ' is enrollend in ' + @CNAME;

	FETCH NEXT FROM Enroll_Cursor INTO @SNAME,@CNAME;
END;

CLOSE Enroll_Cursor;

DEALLOCATE Enroll_Cursor;
GO

--7. Create a cursor to insert data into new table if student belong to ‘CSE’ department. (create new table
--CSEStudent with relevant columns)

CREATE TABLE CSEStudent
(
    StudentID INT,
    StuName VARCHAR(100),
    StuDepartment VARCHAR(50)
)

GO
DECLARE @SID INT, @SNAME VARCHAR(100), @DEPT VARCHAR(50)

DECLARE CSE_Cursor CURSOR FOR
SELECT StudentID,StuName,StuDepartment FROM STUDENT
WHERE StuDepartment = 'CSE';

OPEN CSE_Cursor;

FETCH NEXT FROM CSE_Cursor INTO @SID,@SNAME,@DEPT;

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO CSEStudent(StudentID,StuName,StuDepartment)
	VALUES (@SID,@SNAME,@DEPT);

	FETCH NEXT FROM CSE_Cursor INTO @SID,@SNAME,@DEPT;
END;

CLOSE CSE_Cursor;

DEALLOCATE CSE_Cursor;
GO

SELECT * FROM STUDENT;
SELECT * FROM CSEStudent;

-- TRUNCATE TABLE CSESTUDENT;