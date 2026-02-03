
-- Lab-6 : AFTER Trigger – Extra Questions
------------------------------------------------------------

-- For Query 4

-- 1) Example Output in LOG Table
-- (Hint: Use variables OR directly select values from inserted table)

-- Expected Log Format:
-- Student with StudentID - 105, Name - Rahul, Department - IT added successfully!


-- 2) If rows are inserted one-by-one,
--    how many times will the trigger run?

-- Example: inserting rows individually

INSERT INTO STUDENT VALUES
(23,'Jay Patel','jay@univ.edu','9879999084','CSE','2005-09-18',2024);

INSERT INTO STUDENT VALUES
(24,'Jay Patel','jay@univ.edu','9879999084','CSE','2005-09-18',2024);

INSERT INTO STUDENT VALUES
(25,'Jay Patel','jay@univ.edu','9879999084','CSE','2005-09-18',2024);


-- 3) If multiple students are inserted in a single INSERT statement,
--    how many times does the trigger run?

-- Example: Insert multiple students at once (insert many)

INSERT INTO STUDENT VALUES
(29,'Jay Patel','jay@univ.edu','9879999084','CSE','2005-09-18',2024),
(30,'Jay Patel','jay@univ.edu','9879999084','CSE','2005-09-18',2024),
(31,'Jay Patel','jay@univ.edu','9879999084','CSE','2005-09-18',2024);

-- Question:
-- How many times does the trigger execute?
-- How many log entries are inserted in the LOG table?


-- 4) Can triggers return values?

-- 5) Does a trigger run per row or per statement?





----------------------------------------------------------------------------------------------------------------

-- Solution


GO
CREATE OR ALTER TRIGGER TR_AFTER_STUDENT_INSERT
ON STUDENT
FOR INSERT
AS
BEGIN
    -- Using variables (handles only one row)
    
    DECLARE @SID INT,
            @NAME VARCHAR(100),
            @DEPT VARCHAR(50);

    SELECT 
        @SID = StudentID,
        @NAME = StuName,
        @DEPT = StuDepartment
    FROM inserted;

    INSERT INTO LOG (LogMessage, logDate)
    VALUES (
        'Student with StudentID - ' + CAST(@SID AS VARCHAR) +
        ', Name - ' + @NAME +
        ', Department - ' + @DEPT +
        ' added successfully!',
        GETDATE()
    );
END;
GO

------------------------------------------------------------
-- Case 1: Rows inserted one-by-one
-- Trigger runs once per INSERT statement
-- Therefore, trigger runs 3 times here.
------------------------------------------------------------

INSERT INTO STUDENT VALUES
(33,'Jay Patel','jay@univ.edu','9879999084','CSE','2005-09-18',2024);

INSERT INTO STUDENT VALUES
(34,'Jay Patel','jay@univ.edu','9879999084','CSE','2005-09-18',2024);

INSERT INTO STUDENT VALUES
(35,'Jay Patel','jay@univ.edu','9879999084','CSE','2005-09-18',2024);

SELECT * FROM LOG;
SELECT * FROM STUDENT;

------------------------------------------------------------
-- Case 2: Multiple rows inserted at once
-- Trigger runs only once.
-- But variables store only one row,
-- so only one log entry is inserted.
------------------------------------------------------------

INSERT INTO STUDENT VALUES
(36,'Jay Patel','jay@univ.edu','9879999084','CSE','2005-09-18',2024),
(37,'Jay Patel','jay@univ.edu','9879999084','CSE','2005-09-18',2024),
(38,'Jay Patel','jay@univ.edu','9879999084','CSE','2005-09-18',2024);

SELECT * FROM LOG;
SELECT * FROM STUDENT;

------------------------------------------------------------
-- Correct Method: Handle multiple rows properly
-- Use SELECT FROM inserted instead of variables.
------------------------------------------------------------

GO
CREATE OR ALTER TRIGGER TR_AFTER_STUDENT_INSERT
ON STUDENT
FOR INSERT
AS
BEGIN
    INSERT INTO LOG (LogMessage, logDate)
    SELECT
        'Student with StudentID - ' + CAST(StudentID AS VARCHAR) +
        ', Name - ' + StuName +
        ', Department - ' + StuDepartment +
        ' added successfully!',
        GETDATE()
    FROM inserted;
END;
GO


------------------------------------------------------------
-- Insert multiple rows again
-- Trigger runs once, but all rows are logged.
------------------------------------------------------------

INSERT INTO STUDENT VALUES
(42,'Jay Patel','jay@univ.edu','9879999084','CSE','2005-09-18',2024),
(43,'Jay Patel','jay@univ.edu','9879999084','CSE','2005-09-18',2024),
(44,'Jay Patel','jay@univ.edu','9879999084','CSE','2005-09-18',2024);

SELECT * FROM LOG;



-- 4) No, triggers cannot return values.

-- 5) Trigger runs once per statement, not per row.


------------------------------------------------------------
-- Important Notes
------------------------------------------------------------
-- 2. inserted table may contain multiple rows.
-- 3. Variables store only one row.
-- 4. Always use SELECT ... FROM inserted to handle multiple rows.
------------------------------------------------------------
