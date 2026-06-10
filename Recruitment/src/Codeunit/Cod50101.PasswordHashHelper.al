namespace BCTRAINING.BCTRAINING;

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
        HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA512;
        Salt: Text;
        Iterations: Integer;
        HashedPassword: Text;
    begin
        // Validate input
        if PlainPassword = '' then
            Error('Password cannot be empty');
        
        if StrLen(PlainPassword) < 8 then
            Error('Password must be at least 8 characters long');
        
        // Generate a random salt (BC 270 supports this)
        Salt := GenerateSalt();
        
        // Use PBKDF2 for hashing (industry standard)
        // 100,000 iterations = slow enough to prevent brute force
        Iterations := 100000;
        
        // Hash the password + salt
        HashedPassword := HashPasswordWithSalt(PlainPassword, Salt, Iterations);
        
        // Return format: salt|iterations|hash
        exit(Salt + '|' + Format(Iterations) + '|' + HashedPassword);
    end;

    /// <summary>
    /// Verify a password against stored hash
    /// </summary>
    /// <param name="PlainPassword">Password user entered</param>
    /// <param name="StoredHash">Hash stored in database</param>
    /// <returns>True if password matches</returns>
    procedure VerifyPassword(PlainPassword: Text; StoredHash: Text): Boolean
    var
        SaltParts: List of [Text];
        Salt: Text;
        Iterations: Integer;
        StoredHashValue: Text;
        ComputedHash: Text;
    begin
        // Validate inputs
        if (PlainPassword = '') or (StoredHash = '') then
            exit(false);
        
        // Parse the stored hash format: salt|iterations|hash
        SaltParts := StoredHash.Split('|');
        
        if SaltParts.Count() <> 3 then begin
            LogSecurityEvent('Invalid hash format detected', StoredHash);
            exit(false);
        end;

        Salt := SaltParts.Get(1);
        if not Evaluate(Iterations, SaltParts.Get(2)) then begin
            LogSecurityEvent('Invalid iteration count', StoredHash);
            exit(false);
        end;
        StoredHashValue := SaltParts.Get(3);
        
        // Hash the entered password with same salt and iterations
        ComputedHash := HashPasswordWithSalt(PlainPassword, Salt, Iterations);
        
        // Compare hashes (constant-time comparison to prevent timing attacks)
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
    local procedure HashPasswordWithSalt(PlainPassword: Text; Salt: Text; Iterations: Integer): Text
    var
        HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA512;
        HashedBytes: Text;
    begin
        // BC 270 supports PBKDF2 through System.Security.Cryptography
        // We use HMACSHA256 for the underlying algorithm
        
        // This is where BC's native cryptography function would be called
        // For BC 270, you would use:
        HashedBytes := System.Text.Encoding.UTF8.GetString(System.Security.Cryptography.Rfc2898DeriveBytes.new(
                PlainPassword, System.Text.Encoding.UTF8.GetBytes(Salt), Iterations, HashAlgorithmType::HMACSHA256 ).GetBytes(32) );
        exit(HashedBytes);
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
        SecurityLog."Timestamp" := CurrentDateTime;
        SecurityLog."User ID" := UserId;
        SecurityLog.Insert();
    end;
}