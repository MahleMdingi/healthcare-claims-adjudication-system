CREATE PROCEDURE usp_AdjudicateClaim
    @i_ClaimID INT
AS
BEGIN

    BEGIN TRY

        BEGIN TRAN

        -- ====================================
        -- Declare Variables
        -- ====================================

        DECLARE
            @l_ErrorMessage VARCHAR(1000),
            @l_ClaimStatus VARCHAR(100),
            @l_LineStatus VARCHAR(100)


        -- ====================================
        -- Validate Claim Exists
        -- ====================================

        IF NOT EXISTS (
            SELECT 1
            FROM Claims
            WHERE ClaimID = @i_ClaimID
        )
        BEGIN
            RAISERROR('Claim does not exist.',16,1)
        END


        -- ====================================
        -- Execute Waiting Period Validation
        -- ====================================

        EXEC usp_ValidateWaitingPeriod @i_ClaimID


        -- ====================================
        -- Execute Benefit Limit Validation
        -- ====================================

        EXEC usp_ValidateBenefitLimit @i_ClaimID


        -- ====================================
        -- Retrieve Current Claim Status
        -- ====================================

        SELECT @l_ClaimStatus = ClaimStatus
        FROM Claims
        WHERE ClaimID = @i_ClaimID


        -- ====================================
        -- Retrieve Current Claim Line Status
        -- ====================================

        SELECT @l_LineStatus = LineStatus
        FROM ClaimLines
        WHERE ClaimID = @i_ClaimID


        -- ====================================
        -- Approve Claim Line
        -- ====================================

        IF @l_LineStatus = 'Pending'
        BEGIN

            UPDATE ClaimLines
            SET LineStatus = 'Approved'
            WHERE ClaimID = @i_ClaimID

        END


        -- ====================================
        -- Approve Claim
        -- ====================================

        IF @l_ClaimStatus = 'Pending'
        BEGIN

            UPDATE Claims
            SET ClaimStatus = 'Approved'
            WHERE ClaimID = @i_ClaimID

        END


        COMMIT

    END TRY

    BEGIN CATCH

        ROLLBACK

        SET @l_ErrorMessage = ERROR_MESSAGE()

        RAISERROR(@l_ErrorMessage,16,1)

    END CATCH

END
GO
