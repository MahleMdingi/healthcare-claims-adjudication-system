CREATE PROCEDURE usp_ValidateWaitingPeriod
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
            @l_MemberID INT,
            @l_RegistrationDate DATETIME,
            @l_WaitingPeriod INT


        -- ====================================
        -- Validate Claim Exists
        -- ====================================

        IF NOT EXISTS (
            SELECT 1
            FROM Claims
            WHERE ClaimID = @i_ClaimID
        )
        BEGIN
            RAISERROR('Claim does not exist.', 16, 1)
        END


        -- ====================================
        -- Retrieve MemberID
        -- ====================================

        SELECT @l_MemberID = MemberID
        FROM Claims
        WHERE ClaimID = @i_ClaimID


        -- ====================================
        -- Retrieve Registration Date
        -- ====================================

        SELECT @l_RegistrationDate = RegistrationDate
        FROM Members
        WHERE MemberID = @l_MemberID


        -- ====================================
        -- Retrieve Waiting Period
        -- ====================================

        SELECT @l_WaitingPeriod = wp.WaitingPeriodMonths
        FROM WaitingPeriods wp
        LEFT JOIN Benefits b
            ON wp.BenefitID = b.BenefitID
        LEFT JOIN Members m
            ON b.MedicalPlanID = m.MedicalPlanID
        WHERE m.MemberID = @l_MemberID


        -- ====================================
        -- Validate Waiting Period
        -- ====================================

        IF DATEDIFF(MONTH, @l_RegistrationDate, GETDATE()) < @l_WaitingPeriod
        BEGIN

            -- Reject Claim Line
            UPDATE ClaimLines
            SET LineStatus = 'Rejected'
            WHERE ClaimID = @i_ClaimID


            -- Reject Claim
            UPDATE Claims
            SET ClaimStatus = 'Rejected'
            WHERE ClaimID = @i_ClaimID

        END


        COMMIT

    END TRY

    BEGIN CATCH

        ROLLBACK

        SET @l_ErrorMessage = ERROR_MESSAGE()

        RAISERROR(@l_ErrorMessage, 16, 1)

    END CATCH

END
GO
