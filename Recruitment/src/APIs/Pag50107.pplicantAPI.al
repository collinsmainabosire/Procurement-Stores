namespace BCTRAINING.BCTRAINING;

page 50107 "pplicant API"
{
    APIGroup = 'jobportal';
    APIPublisher = 'bcTraining';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'pplicantAPI';
    DelayedInsert = true;
    EntityName = 'applicant';
    EntitySetName = 'applicants';
    PageType = API;
    SourceTable = "Job Applicant";
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("ApplicantID"; Rec."Applicant ID")
                {
                    Caption = 'Applicant ID';
                    Editable = false;
                }

                field("FirstName"; Rec."First Name")
                {
                    Caption = 'First Name';
                }

                field("LastName"; Rec."Last Name")
                {
                    Caption = 'Last Name';
                }

                field("Email"; Rec."User Email")
                {
                    Caption = 'Email';
                }

                field("PhoneNumber"; Rec."Phone Number")
                {
                    Caption = 'Phone';
                }

                field("CurrentPosition"; Rec."Current Position")
                {
                    Caption = 'Current Position';
                }

                field("YearsOfExperience"; Rec."Years of Experience")
                {
                    Caption = 'Experience';
                }

                field("Status"; Rec."Status")
                {
                    Caption = 'Status';
                }

                field("CreatedDate"; Rec."Created Date")
                {
                    Caption = 'Created';
                    Editable = false;
                }

                field("Address"; Rec."Address")
                {
                    Caption = 'Address';
                }

                field("City"; Rec."City")
                {
                    Caption = 'City';
                }

                field("Country"; Rec."Country")
                {
                    Caption = 'Country';
                }
            }
        }
    }
    // ============================================
    // API OPERATIONS
    // ============================================

    trigger OnOpenPage()
    begin
        // This runs when API is called
        // Initialize API context
    end;

    // Custom API Actions
    // These allow POST requests to specific endpoints

    procedure RegisterApplicant(FirstName: Text[100]; LastName: Text[100]; Email: Text[100]; PhoneNumber: Text[20]; Password: Text) RegistrationResult: JsonObject
    var
        JobApplicant: Record "Job Applicant";
        PasswordHashHelper: Codeunit "Password Hash Helper";
        ValidationError: Text;
    begin
        // Initialize result object
        RegistrationResult := JsonObject.JsonObject();

        try
            // Validate inputs
            if (FirstName = '') or (LastName = '') or (Email = '') or (Password = '') then begin
            RegistrationResult.Add('success', false);
            RegistrationResult.Add('message', 'All fields are required');
            exit;
        end;

        // Validate password strength
        ValidationError := PasswordHashHelper.ValidatePasswordStrength(Password);
        if ValidationError <> '' then begin
            RegistrationResult.Add('success', false);
            RegistrationResult.Add('message', ValidationError);
            exit;
        end;

        // Check if email already exists
        JobApplicant.SetRange("User Email", Email);
        if JobApplicant.FindFirst() then begin
            RegistrationResult.Add('success', false);
            RegistrationResult.Add('message', 'Email already registered');
            exit;
        end;

        // Create new applicant
        JobApplicant.Init();
        JobApplicant."First Name" := FirstName;
        JobApplicant."Last Name" := LastName;
        JobApplicant."User Email" := Email;
        JobApplicant."Email" := Email;
        JobApplicant."Phone Number" := PhoneNumber;
        JobApplicant."Status" := JobApplicant."Status"::Active;

        // Insert record (OnInsert trigger will generate ID)
        JobApplicant.Insert(true);

        // Set password
        JobApplicant.SetPassword(Password);

        // Return success with applicant details
        RegistrationResult.Add('success', true);
        RegistrationResult.Add('message', 'Registration successful');
        RegistrationResult.Add('applicantId', JobApplicant."Applicant ID");
        RegistrationResult.Add('name', JobApplicant.GetFullName());
        RegistrationResult.Add('email', JobApplicant."User Email");

        catch Error: ErrorInfo
            RegistrationResult.Add('success', false);
        RegistrationResult.Add('message', Error.Message);
    end;
    end;

    procedure AuthenticateApplicant(
        Email: Text[100];
        Password: Text
    ) AuthResult: JsonObject
    var
        JobApplicant: Record "Job Applicant";
        PasswordHashHelper: Codeunit "Password Hash Helper";
        JWTToken: Text;
    begin
        // Initialize result
        AuthResult := JsonObject.JsonObject();

        try
            // Find applicant by email
            JobApplicant.SetRange("User Email", Email);

        if not JobApplicant.FindFirst() then begin
            AuthResult.Add('success', false);
            AuthResult.Add('message', 'Invalid email or password');
            exit;
        end;

        // Check if account is active
        if JobApplicant."Status" <> JobApplicant."Status"::Active then begin
            AuthResult.Add('success', false);
            AuthResult.Add('message', 'Account is not active');
            exit;
        end;

        // Verify password
        if not JobApplicant.VerifyPassword(Password) then begin
            AuthResult.Add('success', false);
            AuthResult.Add('message', 'Invalid email or password');
            AuthResult.Add('failedAttempts', JobApplicant."Failed Login Attempts");
            exit;
        end;

        // Password correct - generate JWT token
        JWTToken := GenerateJWTToken(JobApplicant."Applicant ID", JobApplicant."User Email");

        // Return success
        AuthResult.Add('success', true);
        AuthResult.Add('message', 'Authentication successful');
        AuthResult.Add('applicantId', JobApplicant."Applicant ID");
        AuthResult.Add('name', JobApplicant.GetFullName());
        AuthResult.Add('email', JobApplicant."User Email");
        AuthResult.Add('token', JWTToken);
        AuthResult.Add('expiresIn', 86400); // 24 hours in seconds

        catch Error: ErrorInfo
            AuthResult.Add('success', false);
        AuthResult.Add('message', 'Authentication error: ' + Error.Message);
    end;
    end;

    procedure GetApplicantProfile(ApplicantID: Code[20]) ProfileResult: JsonObject
    var
        JobApplicant: Record "Job Applicant";
        ApplicantQualification: Record "Applicant Qualification";
        JobApplication: Record "Job Application";
        QualArray: JsonArray;
        AppArray: JsonArray;
        QualObject: JsonObject;
        AppObject: JsonObject;
    begin
        ProfileResult := JsonObject.JsonObject();

        try
            // Get applicant
            if not JobApplicant.Get(ApplicantID) then begin
            ProfileResult.Add('success', false);
            ProfileResult.Add('message', 'Applicant not found');
            exit;
        end;

        // Build profile object
        ProfileResult.Add('success', true);
        ProfileResult.Add('applicantId', JobApplicant."Applicant ID");
        ProfileResult.Add('firstName', JobApplicant."First Name");
        ProfileResult.Add('lastName', JobApplicant."Last Name");
        ProfileResult.Add('email', JobApplicant."User Email");
        ProfileResult.Add('phone', JobApplicant."Phone Number");
        ProfileResult.Add('dateOfBirth', Format(JobApplicant."Date of Birth", 0, '<Year4>-<Month,2>-<Day,2>'));
        ProfileResult.Add('currentPosition', JobApplicant."Current Position");
        ProfileResult.Add('currentCompany', JobApplicant."Current Company");
        ProfileResult.Add('yearsOfExperience', JobApplicant."Years of Experience");
        ProfileResult.Add('summary', JobApplicant."Summary");
        ProfileResult.Add('address', JobApplicant."Address");
        ProfileResult.Add('city', JobApplicant."City");
        ProfileResult.Add('country', JobApplicant."Country");
        ProfileResult.Add('linkedIn', JobApplicant."LinkedIn URL");
        ProfileResult.Add('portfolio', JobApplicant."Portfolio URL");
        ProfileResult.Add('status', Format(JobApplicant."Status"));
        ProfileResult.Add('createdDate', Format(JobApplicant."Created Date"));
        ProfileResult.Add('lastLoginDate', Format(JobApplicant."Last Login Date"));

        // Add qualifications
        ApplicantQualification.SetRange("Applicant ID", ApplicantID);
        QualArray := JsonArray.JsonArray();
        if ApplicantQualification.FindSet() then
            repeat
                QualObject := JsonObject.JsonObject();
                QualObject.Add('qualificationId', ApplicantQualification."Qualification ID");
                QualObject.Add('qualificationName', ApplicantQualification."Qualification Name");
                QualObject.Add('yearObtained', ApplicantQualification."Year Obtained");
                QualObject.Add('institution', ApplicantQualification."Institution");
                QualObject.Add('grade', ApplicantQualification."Grade/Score");
                QualArray.Add(QualObject);
            until ApplicantQualification.Next() = 0;
        ProfileResult.Add('qualifications', QualArray);

        // Add applications
        JobApplication.SetRange("Applicant ID", ApplicantID);
        AppArray := JsonArray.JsonArray();
        if JobApplication.FindSet() then
            repeat
                AppObject := JsonObject.JsonObject();
                AppObject.Add('applicationId', JobApplication."Application ID");
                AppObject.Add('jobTitle', JobApplication."Job Title");
                AppObject.Add('department', JobApplication."Department");
                AppObject.Add('status', Format(JobApplication."Status"));
                AppObject.Add('appliedDate', Format(JobApplication."Application Date"));
                AppArray.Add(AppObject);
            until JobApplication.Next() = 0;
        ProfileResult.Add('applications', AppArray);

        catch Error: ErrorInfo
            ProfileResult.Add('success', false);
        ProfileResult.Add('message', 'Error: ' + Error.Message);
    end;
    end;

    procedure UpdateApplicantProfile(
        ApplicantID: Code[20];
        FirstName: Text[100];
        LastName: Text[100];
        PhoneNumber: Text[20];
        CurrentPosition: Text[100];
        YearsOfExperience: Decimal;
        Summary: Text[500]
    ) UpdateResult: JsonObject
    var
        JobApplicant: Record "Job Applicant";
    begin
        UpdateResult := JsonObject.JsonObject();

        try
            if not JobApplicant.Get(ApplicantID) then begin
            UpdateResult.Add('success', false);
            UpdateResult.Add('message', 'Applicant not found');
            exit;
        end;

        // Update fields
        JobApplicant."First Name" := FirstName;
        JobApplicant."Last Name" := LastName;
        JobApplicant."Phone Number" := PhoneNumber;
        JobApplicant."Current Position" := CurrentPosition;
        JobApplicant."Years of Experience" := YearsOfExperience;
        JobApplicant."Summary" := Summary;
        JobApplicant.Modify();

        UpdateResult.Add('success', true);
        UpdateResult.Add('message', 'Profile updated successfully');
        UpdateResult.Add('applicantId', JobApplicant."Applicant ID");

        catch Error: ErrorInfo
            UpdateResult.Add('success', false);
        UpdateResult.Add('message', Error.Message);
    end;
    end;

    procedure ChangePassword(
        ApplicantID: Code[20];
        CurrentPassword: Text;
        NewPassword: Text
    ) ChangeResult: JsonObject
    var
        JobApplicant: Record "Job Applicant";
        PasswordHashHelper: Codeunit "Password Hash Helper";
        ValidationError: Text;
    begin
        ChangeResult := JsonObject.JsonObject();

        try
            // Get applicant
            if not JobApplicant.Get(ApplicantID) then begin
            ChangeResult.Add('success', false);
            ChangeResult.Add('message', 'Applicant not found');
            exit;
        end;

        // Verify current password
        if not JobApplicant.VerifyPassword(CurrentPassword) then begin
            ChangeResult.Add('success', false);
            ChangeResult.Add('message', 'Current password is incorrect');
            exit;
        end;

        // Validate new password strength
        ValidationError := PasswordHashHelper.ValidatePasswordStrength(NewPassword);
        if ValidationError <> '' then begin
            ChangeResult.Add('success', false);
            ChangeResult.Add('message', ValidationError);
            exit;
        end;

        // Don't allow same password
        if JobApplicant.VerifyPassword(NewPassword) then begin
            ChangeResult.Add('success', false);
            ChangeResult.Add('message', 'New password cannot be same as current password');
            exit;
        end;

        // Set new password
        JobApplicant.SetPassword(NewPassword);

        ChangeResult.Add('success', true);
        ChangeResult.Add('message', 'Password changed successfully');

        catch Error: ErrorInfo
            ChangeResult.Add('success', false);
        ChangeResult.Add('message', 'Error: ' + Error.Message);
    end;
    end;

    // ============================================
    // HELPER PROCEDURES
    // ============================================

    local procedure GenerateJWTToken(ApplicantID: Code[20]; Email: Text[100]): Text
    var
        JWTToken: Text;
    begin
        // TODO: Implement proper JWT generation
        // For now, return a simple token
        // In production, use proper JWT library

        JWTToken := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.' +
                    'eyJhcHBsaWNhbnRJZCI6IiIgKyBApplicantID + ' "," email ":"' + Email + '"}.' +
                    'SIGNATURE_HERE';

        exit(JWTToken);
    end;
}
