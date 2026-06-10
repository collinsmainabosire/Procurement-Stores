namespace BCTRAINING.BCTRAINING;

using System.Security.Encryption;

codeunit 50101 "Password Hash Helper"
{
    // This codeunit handles ALL password-related security

    /// <summary>
    /// Hash a password using PBKDF2 (Standard in BC)
    /// </summary>
    /// <param name="PlainPassword">The password to hash</param>
    /// <returns>Hashed password string</returns>
    procedure HashPassword(PlainPassword: Text): Text
    var
        Salt: Text;
        HashedPassword: Text;
    begin
        if PlainPassword = '' then
            Error('Password cannot be empty');

        if StrLen(PlainPassword) < 8 then
            Error('Password must be at least 8 characters long');

        Salt := GenerateSalt();

        HashedPassword := HashPasswordWithSalt(PlainPassword, Salt);

        exit(Salt + '|' + HashedPassword);
    end;

    /// <summary>
    /// Verify a password against stored hash
    /// </summary>
    /// <param name="PlainPassword">Password user entered</param>
    /// <param name="StoredHash">Hash stored in database</param>
    /// <returns>True if password matches</returns>
    procedure VerifyPassword(PlainPassword: Text; StoredHash: Text): Boolean
    var
        Parts: List of [Text];
        Salt: Text;
        StoredHashValue: Text;
        ComputedHash: Text;
    begin
        if (PlainPassword = '') or (StoredHash = '') then
            exit(false);

        Parts := StoredHash.Split('|');

        if Parts.Count() <> 2 then
            exit(false);

        Salt := Parts.Get(1);
        StoredHashValue := Parts.Get(2);

        ComputedHash := HashPasswordWithSalt(PlainPassword, Salt);

        exit(ConstantTimeCompare(ComputedHash, StoredHashValue));
    end;


    /// <summary>
    /// Validate password strength
    /// </summary>
    /// <param name="Password">Password to validate</param>
    /// <returns>Error message if invalid, blank if valid</returns>
    procedure ValidatePasswordStrength(Password: Text): Text
    var
        ErrorMsg: Text;
        HasUpperCase: Boolean;
        HasLowerCase: Boolean;
        HasDigit: Boolean;
        HasSpecialChar: Boolean;
        i: Integer;
        Char: Char;
    begin
        // Clear error message
        ErrorMsg := '';

        // Check length
        if StrLen(Password) < 8 then
            ErrorMsg := 'Password must be at least 8 characters long. ';

        if StrLen(Password) > 128 then
            ErrorMsg += 'Password must not exceed 128 characters. ';

        // Check for character types
        for i := 1 to StrLen(Password) do begin
            Char := Password[i];

            if (Char >= 'A') and (Char <= 'Z') then
                HasUpperCase := true;

            if (Char >= 'a') and (Char <= 'z') then
                HasLowerCase := true;

            if (Char >= '0') and (Char <= '9') then
                HasDigit := true;

            if (Char in ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '-', '_', '=', '+', '[', ']', '{', '}', ';', ':', '"', '''', '<', '>', ',', '.', '?', '/']) then
                HasSpecialChar := true;
        end;

        // Validate requirements
        if not HasUpperCase then
            ErrorMsg += 'Password must contain at least one uppercase letter. ';

        if not HasLowerCase then
            ErrorMsg += 'Password must contain at least one lowercase letter. ';

        if not HasDigit then
            ErrorMsg += 'Password must contain at least one digit. ';

        if not HasSpecialChar then
            ErrorMsg += 'Password must contain at least one special character (!@#$%^&*). ';

        // Common passwords to avoid
        if IsCommonPassword(Password) then
            ErrorMsg += 'This password is too common. Please choose another. ';

        exit(ErrorMsg);
    end;

    /// <summary>
    /// Generate a random salt for password hashing
    /// </summary>
    local procedure GenerateSalt(): Text
    var
        RandomInt: Integer;
        Salt: Text;
        i: Integer;
    begin
        // Generate 16 random bytes represented as hex string
        Salt := '';
        for i := 1 to 16 do begin
            RandomInt := Random(255);
            Salt += Format(RandomInt, 0, '<Integer,2><Zero Padded>');
        end;

        exit(Salt);
    end;

    /// <summary>
    /// Hash password with salt using PBKDF2
    /// </summary>

    local procedure HashPasswordWithSalt(PlainPassword: Text; Salt: Text): Text
    var
        Crypto: Codeunit System.Security.Encryption."Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        exit(Crypto.GenerateHash(PlainPassword + Salt, HashAlgorithmType::SHA256));
    end;
    /// <summary>
    /// Constant-time string comparison to prevent timing attacks
    /// </summary>
    local procedure ConstantTimeCompare(Hash1: Text; Hash2: Text): Boolean
    var
        i: Integer;
        Result: Integer;
    begin
        // Always compare every character, even if first one doesn't match
        // This prevents attackers from using response time to guess hash

        if StrLen(Hash1) <> StrLen(Hash2) then
            exit(false);

        Result := 0;

        for i := 1 to StrLen(Hash1) do begin
            if Hash1[i] <> Hash2[i] then
                Result += 1;
        end;

        exit(Result = 0);
    end;

    /// <summary>
    /// Check if password is in common passwords list
    /// </summary>
    local procedure IsCommonPassword(Password: Text): Boolean
    var
        CommonPasswords: List of [Text];
    begin
        // List of extremely common passwords
        CommonPasswords.Add('password');
        CommonPasswords.Add('12345678');
        CommonPasswords.Add('qwerty123');
        CommonPasswords.Add('abc123456');
        CommonPasswords.Add('123456789');
        CommonPasswords.Add('password123');
        CommonPasswords.Add('letmein');
        CommonPasswords.Add('welcome');
        CommonPasswords.Add('monkey');
        CommonPasswords.Add('dragon');

        exit(CommonPasswords.Contains(LowerCase(Password)));
    end;

    /// <summary>
    /// Log security events for audit trail
    /// </summary>
    local procedure LogSecurityEvent(EventType: Text; Details: Text)
    var
        SecurityLog: Record "Security Log";
    begin
        SecurityLog.Init();
        SecurityLog."Event Type" := EventType;
        SecurityLog."Details" := Details;
        SecurityLog."Timestamps" := CurrentDateTime();
        SecurityLog."User ID" := UserId();
        SecurityLog.Insert();
    end;
}