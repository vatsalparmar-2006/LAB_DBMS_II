
-- Lab : INSTEAD OF Trigger – Extra Questions
------------------------------------------------------------


-- =========================================================
-- Query 4
-- =========================================================

-- Detect which operation is attempted on COURSE table
-- and log it in LOG table.
--
-- Task:
-- If user tries INSERT, UPDATE or DELETE on COURSE,
-- operation should be blocked and logged.
--
-- Hint:
-- Use inserted and deleted tables to detect operation.
--
-- Test:
-- 1) Try inserting into COURSE
-- 2) Try updating COURSE
-- 3) Try deleting COURSE
-- 4) Check LOG table entries.


-- =========================================================
-- Query 5
-- =========================================================
-- Students are NOT allowed to update EnrollmentYear.
-- However, updates to other columns should work.
--
-- Example:
-- Update department → Allowed
-- Update enrollment year → Blocked
--
-- Task:
-- Modify trigger so only EnrollmentYear update is blocked,
-- but other updates are allowed.


-- =========================================================
-- Query 6
-- =========================================================
-- Age validation during student insertion.
--
-- Task:
-- When inserting a student,
-- calculate age using DateOfBirth.
--
-- If age < 18 → insertion must be blocked.
-- If age >= 18 → record inserted.

-- =========================================================
-- Conceptual Questions
-- =========================================================
-- Can multiple INSTEAD OF triggers exist on one table?

-- What is the difference between AFTER trigger and INSTEAD OF trigger?

-- What data is stored in inserted and deleted tables?     



----------------------------------------------------------------------------------------------------------------
-- Solutions
----------------------------------------------------------------------------------------------------------------


-- =========================================================
-- Query 4
-- =========================================================
GO
CREATE OR ALTER TRIGGER TR_LOG_COURSE_OPERATIONS
ON COURSE
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @InsertedCount INT,
            @DeletedCount INT;

    SELECT @InsertedCount = COUNT(*) FROM inserted;
    SELECT @DeletedCount = COUNT(*) FROM deleted;

    IF @InsertedCount > 0 AND @DeletedCount > 0
        INSERT INTO LOG VALUES('UPDATE attempted on COURSE', GETDATE());
    ELSE IF @InsertedCount > 0
        INSERT INTO LOG VALUES('INSERT attempted on COURSE', GETDATE());
    ELSE IF @DeletedCount > 0
        INSERT INTO LOG VALUES('DELETE attempted on COURSE', GETDATE());

    PRINT 'Operation blocked and logged.';
END;
GO

-- =========================================================
-- Query 5
-- =========================================================
GO
CREATE OR ALTER TRIGGER TR_STUDENT_UPDATE
ON STUDENT
INSTEAD OF UPDATE
AS
BEGIN
    IF UPDATE(EnrollmentYear)
    BEGIN
        PRINT 'Students are not allowed to update their enrollment year.';
        RETURN;
    END;

    UPDATE s
    SET
        s.StuName = i.StuName,
        s.StuEmail = i.StuEmail,
        s.StuPhone = i.StuPhone,
        s.StuDepartment = i.StuDepartment,
        s.StuDateOfBirth = i.StuDateOfBirth
    FROM STUDENT s
    JOIN inserted i
        ON s.StudentID = i.StudentID;
END;
GO

-- =========================================================
-- Query 6
-- =========================================================
GO
CREATE OR ALTER TRIGGER TR_STUDENT_PREVENT_AGE
ON STUDENT
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @DOB DATE;

    SELECT @DOB = StuDateOfBirth FROM inserted;

    IF DATEDIFF(YEAR, @DOB, GETDATE()) < 18
    BEGIN
        PRINT 'Student must be at least 18 years old.';
        RETURN;
    END;

    INSERT INTO STUDENT
    SELECT * FROM inserted;
END;
GO



-- =========================================================
-- Query 7
-- =========================================================
GO
CREATE OR ALTER TRIGGER TR_UNIQUE_FACULTY_EMAIL
ON FACULTY
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    DECLARE @Email VARCHAR(100);

    SELECT @Email = FacultyEmail FROM inserted;

    IF @Email IN (SELECT FacultyEmail FROM FACULTY)
    BEGIN
        PRINT 'Duplicate faculty email is not allowed.';
        RETURN;
    END;

    INSERT INTO FACULTY
    SELECT * FROM inserted;
END;
GO