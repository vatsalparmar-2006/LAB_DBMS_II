
-- Lab-8 : Exception Handling

-- PART-A

--1. Handle Divide by Zero Error and Print message like: Error occurs that is - Divide by zero error.

-- System Defined Exception

PRINT 5 / 0;
-----------------------------------------------------------------
BEGIN TRY

	DECLARE @A INT = 10,@B INT = 10;

	DECLARE @RESULT INT;
	SET @RESULT = @A / @B;

	PRINT @RESULT;
END TRY

BEGIN CATCH

	PRINT 'Error occurs that is - Divide by zero error.'

END CATCH

-- Take Input From User (Use Stored Procedure)

GO
CREATE OR ALTER PROCEDURE PR_DivideNumbers
	@A	INT,
	@B	INT
AS
BEGIN
	BEGIN TRY
		DECLARE @RESULT INT;
		SET @RESULT = @A / @B;

		PRINT 'Result = ' + CAST(@RESULT AS VARCHAR);
	END TRY
	BEGIN CATCH
		PRINT 'Error occurs that is - Divide by zero error.'
	END CATCH
END;
GO

EXEC PR_DivideNumbers 10,2;
EXEC PR_DivideNumbers 10,0;


-- OR - THROW inside CATCH (without parameters)

BEGIN TRY
	SELECT 10 / 0
END TRY
BEGIN CATCH
	THROW;		-- rethrows the same error.
END CATCH


--2. Try to convert string to integer and handle the error using try-catch block.

BEGIN TRY
	DECLARE @N INT;

	SET @N = CAST('ABC' AS INT);

	PRINT 'Converted Value = ' + CAST(@N AS VARCHAR);
END TRY
BEGIN CATCH
	 PRINT 'Error: Cannot convert string to integer';
END CATCH


--3. Create a procedure that prints the sum of two numbers: take both numbers as integer & handle exception with all error functions if any one enters string value in numbers otherwise print result.

GO
CREATE OR ALTER PROCEDURE PR_AddNumbers
	@N1 INT,@N2 INT
AS
BEGIN
	BEGIN TRY
		DECLARE @SUM INT;
		SET @SUM = @N1 + @N2;

		PRINT 'Sum = ' + CAST(@SUM AS VARCHAR);
	END TRY
	BEGIN CATCH
		-- ERROR FUNCTIONS

		SELECT 
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() AS ErrorState,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage,
			ERROR_PROCEDURE() AS ErrorProcedure
	END CATCH;
END;
GO

EXEC PR_AddNumbers 10,20;
EXEC PR_AddNumbers 10,'DARSHAN';

-- Here, Error shows like - Error converting data type varchar to int.(Not from Catch block)

-- SQL Server tries to convert 'DARSHAN' to INT before the procedure starts.
-- That means the error happens before entering the TRY block.

-- TRY-CATCH only catches errors that occur inside the TRY block.

-- To handle such errors, take parameters as VARCHAR and convert them inside TRY

GO
CREATE OR ALTER PROCEDURE PR_AddNumbers
    @N1 VARCHAR(10),
    @N2 VARCHAR(10)
AS
BEGIN

BEGIN TRY

    DECLARE @A INT
    DECLARE @B INT
    DECLARE @SUM INT

    SET @A = CAST(@N1 AS INT)
    SET @B = CAST(@N2 AS INT)

    SET @SUM = @A + @B

    PRINT 'Sum = ' + CAST(@SUM AS VARCHAR)

END TRY

BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_PROCEDURE() AS ErrorProcedure

END CATCH
END;
GO

EXEC PR_AddNumbers 10,'DARSHAN';

--4. Handle a Primary Key Violation while inserting data into student table and print the error details such as the error message, error number, severity, and state.

BEGIN TRY
	INSERT INTO STUDENT(StudentID,StuName,StuEmail,StuPhone,StuDepartment,StuDateOfBirth,StuEnrollmentYear)
	VALUES (1,'Darshan','darshan@univ.edu','9879999084','CSE','2005-09-18',2023);
END TRY

BEGIN CATCH
	PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS VARCHAR);
	PRINT 'Error Message : ' + ERROR_MESSAGE();
	PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
	PRINT 'Error Severity : ' + CAST(ERROR_SEVERITY() AS VARCHAR);

END CATCH

--5. Throw custom exception using stored procedure which accepts StudentID as input & that throw Error like no StudentID is available in database.

-- User Defined Exception

-- THROW ERROR_NUMBER , MESSAGE , STATE;

-- NOTE: Error_number must be greater than 50000 & state is between 0-255.
-- 1   49999 => for system-defined errors

-- state parameter indicates => the location or reason of the error.

GO
CREATE OR ALTER PROCEDURE PR_CheckStudent
	@SID INT
AS
BEGIN
	BEGIN TRY

		DECLARE @COUNT INT;

		SELECT @COUNT = COUNT(*) FROM STUDENT 
		WHERE StudentID = @SID;

		IF @COUNT = 0
			THROW 50001,'No StudentID is available in database',1
		ELSE
			PRINT 'StudentID exists in database'

	END TRY

	BEGIN CATCH
			
		SELECT
        	ERROR_NUMBER() AS ErrorNumber,
        	ERROR_STATE() AS ErrorState,
        	ERROR_MESSAGE() AS ErrorMessage

	END CATCH
END;
GO

-- OR

GO
CREATE OR ALTER PROCEDURE PR_CheckStudent
	@SID INT
AS
BEGIN
	BEGIN TRY
		
		IF NOT EXISTS
		(
			SELECT * FROM STUDENT WHERE StudentID = @SID
		)

		THROW 50001, 'No StudentID is available in database', 1;
		
		ELSE
			PRINT 'Student exists in database';

	END TRY

	BEGIN CATCH
			
		SELECT
        	ERROR_NUMBER() AS ErrorNumber,
        	ERROR_STATE() AS ErrorState,
        	ERROR_MESSAGE() AS ErrorMessage

	END CATCH
END;
GO

EXEC PR_CheckStudent 1;
EXEC PR_CheckStudent 111;


-- To Check all system-defined error numbers and messages.

SELECT * FROM sys.messages;

-- SELECT message_id,text from sys.messages where message_id = 8134;

-- Using RAISERROR(): RAISERROR (message, severity, state)

GO
CREATE OR ALTER PROCEDURE PR_CheckStudent_RaiseError
    @SID INT
AS
BEGIN

BEGIN TRY

    DECLARE @Count INT

    SELECT @Count = COUNT(*)
    FROM STUDENT
    WHERE StudentID = @SID

    IF @Count = 0
        RAISERROR('No StudentID is available in database',16,1)
    ELSE
        PRINT 'StudentID exists in database'

END TRY

BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine

END CATCH

END
GO

EXEC PR_CheckStudent_RaiseError 111;

-- ERROR_LINE() shows the error line within the procedure, not the full query script line number.


--6. Handle a Foreign Key Violation while inserting data into Enrollment table and print appropriate error
--message.

BEGIN TRY

	INSERT INTO ENROLLMENT(StudentID,CourseID,EnrollmentDate,Grade,EnrollmentStatus)
	VALUES (100,'CS5001','2023-03-03','A+','Completed');

	PRINT 'Enrollment inserted successfully'
END TRY

BEGIN CATCH
	
	PRINT 'Error: Foreign Key violation. StudentID or CourseID does not exist - ' + CAST(ERROR_NUMBER() AS VARCHAR)

END CATCH


-- PART-B

--7. Handle Invalid Date Format

BEGIN TRY
	DECLARE @InputDate DATE;

	SET @InputDate = CAST('2026-13-03' AS DATE)

	PRINT 'Valid Date Format'
END TRY

BEGIN CATCH
	
	PRINT 'Error: Invalid Date Format'

END CATCH

--8. Procedure to Update faculty s Email with Error Handling.

GO
CREATE OR ALTER PROCEDURE PR_UpdateFacultyEmail
	@FID		INT,
	@NewEmail	VARCHAR(100)
AS
BEGIN
	BEGIN TRY
		UPDATE FACULTY 
		SET FacultyEmail = @NewEmail
		WHERE FacultyID = @FID;

		PRINT 'Faculty Email updated successfully'
	END TRY

	BEGIN CATCH
		 PRINT 'Error occurred while updating email'
		 PRINT ERROR_MESSAGE()
	END CATCH
END;
GO

EXEC PR_UpdateFacultyEmail 101,'sheth@univ.edu';

EXEC PR_UpdateFacultyEmail 1,'patel@univ.edu';

-- Here, we pass an ID that does not exist, SQL Server does NOT treat it as an error.

-- We can use @@ROWCOUNT to check how many number of rows affected.

GO
CREATE OR ALTER PROCEDURE PR_UpdateFacultyEmail
	@FID INT,
	@NewEmail VARCHAR(100)
AS
BEGIN

BEGIN TRY

	UPDATE FACULTY
	SET FacultyEmail = @NewEmail
	WHERE FacultyID = @FID;

	IF @@ROWCOUNT = 0
		PRINT 'Error: FacultyID not found'
	ELSE
		PRINT 'Faculty Email updated successfully'

END TRY

BEGIN CATCH

	PRINT 'Error occurred while updating email'
	PRINT ERROR_MESSAGE()

END CATCH

END
GO

EXEC PR_UpdateFacultyEmail 1,'patel@univ.edu';
SELECT * FROM FACULTY;


--9. Throw custom exception that throws error if the data is invalid.

-- For this query - Check whether the given email format is valid; if it is invalid, throw a custom exception using THROW.

BEGIN TRY
	
	DECLARE @EMAIL VARCHAR(100) = 'InvalidEmail'

	IF @EMAIL NOT LIKE '%@%.%'
		THROW 50001,'Invalid Email Format',1

	PRINT 'Valid Email'

END TRY

BEGIN CATCH
	PRINT ERROR_MESSAGE()
END CATCH


-- PART-C

--10. Write a script that checks if a faculty s salary is NULL. If it is, use RAISERROR to show a message with a severity of 16. (Note: Do not use any table)

DECLARE @SALARY DECIMAL(10,2)

SET @SALARY = NULL

IF @SALARY IS NULL
BEGIN
	RAISERROR('Faculty salary cannot be NULL',16,1)
END
ELSE
BEGIN
    PRINT 'Salary is valid'
END