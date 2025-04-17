
CREATE PROCEDURE [dbo].[GetTotalDefaulters]
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #DefaulterUsers (
        UserID INT,
        LastTSDate DATE,
        DefaultCount INT
    );

    BEGIN
        INSERT INTO #DefaulterUsers (UserID, LastTSDate, DefaultCount)

        SELECT 
            U.UserID,
            ISNULL(
			(SELECT TOP 1 EndDate
			FROM TimesheetHdr
			WHERE UserID = U.UserID 
			ORDER BY EndDate DESC),
			'2024-10-05'
			) AS LastTSDate,
            0 AS DefaultCount
        FROM 
            Users AS U
			LEFT JOIN TimesheetHdr AS T ON U.UserID = T.UserID
			GROUP BY U.UserID;

        UPDATE #DefaulterUsers
        
        SET DefaultCount = DATEDIFF(DAY, LastTSDate, GETUTCDATE()) / 7
                            + CASE WHEN DATEDIFF(DAY, LastTSDate, GETUTCDATE()) % 7 > 0 THEN 1 ELSE 0 END
                            - CASE WHEN DATEPART(WEEKDAY, LastTSDate) = 6 THEN 1 ELSE 0 END;

        DELETE FROM #DefaulterUsers WHERE DefaultCount <= 0;

        SELECT COUNT(*) AS TotalDefaulterCount FROM #DefaulterUsers;
    END;

    DROP TABLE #DefaulterUsers;
END;
