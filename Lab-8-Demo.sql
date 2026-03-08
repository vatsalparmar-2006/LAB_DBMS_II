
-- Lab-8 Demo - Exception Handling

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


--3. Create a procedure that prints the sum of two numbers: take both numbers as integer & handle
-- exception with all error functions if any one enters string value in numbers otherwise print result.

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

-- SQL Server first tries to convert 'DARSHAN' to INT before the procedure starts.
-- That means the error happens before entering the TRY block.

-- TRY…CATCH only catches errors that occur inside the TRY block.

-- To handle such errors, take parameters as VARCHAR and convert them inside TRY.

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
    SET @B = CAST(@N2 AS INT)				-- 14th line

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

-- ERROR_LINE() shows the error line within the procedure, not the full query script line number.


--5. Throw custom exception using stored procedure which accepts StudentID as input & that throws
-- Error like no StudentID is available in database.

-- User Defined Exception

-- THROW ERROR_NUMBER , MESSAGE , STATE;

-- NOTE: Error_number must be greater than 50000 & state is between 0-255.
-- 1 – 49999 => for system-defined errors

-- state parameter indicates => the location or reason of the error.

GO
CREATE OR ALTER PROCEDURE PR_CheckStudent
	@SID INT
AS
BEGIN
	BEGIN TRY

	DECLARE @COUNT INT;

	SELECT @COUNT = COUNT(*) FROM STUDENT WHERE StudentID = @SID;

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


-- Using RAISERROR():

-- RAISERROR (message, severity, state)

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


--------------------------------------------------------------------------------------------------------------

-- 9. Throw custom exception that throws error if the data is invalid.

-- For this 9th query - Check whether the given email format is valid; if it is invalid, 
-- throw a custom exception using THROW.