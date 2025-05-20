SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[api_custom_GetPocketPlatformSermon]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[api_custom_GetPocketPlatformSermon] AS' 
END
GO



-- =============================================
-- api_Custom_GetPocketPlatformSeriesDetails
-- =============================================
-- Description:		This stored procedure returns details for a specific Pocket Platform sermon
-- Last Modified:	5/14/2025
-- JD Blackman
-- Updates:
-- =============================================
ALTER PROCEDURE [dbo].[api_custom_GetPocketPlatformSermon] 
	@DomainID int,
	@Username nvarchar(75) = null,
    @SermonID int = 0,
    @ReturnPath nvarchar(100) = ''
AS
BEGIN

    SELECT
        @SermonID AS Sermon_ID

END
GO

-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_custom_GetPocketPlatformSermon'
DECLARE @spDescription nvarchar(500) = 'This stored procedure returns details for a specific Pocket Platform sermon'

IF NOT EXISTS (SELECT API_Procedure_ID FROM dp_API_Procedures WHERE Procedure_Name = @spName)
BEGIN
	INSERT INTO dp_API_Procedures
	(Procedure_Name, Description)
	VALUES
	(@spName, @spDescription)	
END


DECLARE @AdminRoleID INT = (SELECT Role_ID FROM dp_Roles WHERE Role_Name='Administrators')
IF NOT EXISTS (SELECT * FROM dp_Role_API_Procedures RP INNER JOIN dp_API_Procedures AP ON AP.API_Procedure_ID = RP.API_Procedure_ID WHERE AP.Procedure_Name = @spName AND RP.Role_ID=@AdminRoleID)
BEGIN
	INSERT INTO dp_Role_API_Procedures
	(Domain_ID,  API_Procedure_ID, Role_ID)
	VALUES
	(1, (SELECT API_Procedure_ID FROM dp_API_Procedures WHERE Procedure_Name = @spName), @AdminRoleID)
END
GO
-- ========================================================================================
