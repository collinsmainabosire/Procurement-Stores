namespace BCTRAINING.BCTRAINING;

codeunit 50103 "Hash Helper"
{
    // This codeunit handles file hashing and integrity verification
    // Used for:
    // 1. Detecting duplicate file uploads
    // 2. Verifying file hasn't been tampered with
    // 3. Secure file comparison

    // ============================================
    // MAIN PROCEDURES
    // ============================================

    local procedure ReadStreamAsBase64(InS: InStream): Text
    var
        TempBlob: Codeunit "Temp Blob";
        OutS: OutStream;
        Result: Text;
    begin
        TempBlob.CreateOutStream(OutS);
        CopyStream(OutS, InS);

        TempBlob.CreateInStream(InS);
        InS.ReadText(Result);

        exit(Result);
    end;

    /// <summary>
    /// Calculate SHA256 hash of text content
    /// </summary>
    /// <param name="TextContent">The text to hash</param>
    /// <returns>SHA256 hash string in hex format</returns>
    procedure CalculateTextSHA256Hash(TextContent: Text): Text
    var
        Encoding: System.Text.Encoding;
        FileBlob: Blob;
    begin
        // Convert text to blob
        Encoding := System.Text.Encoding.UTF8;

        FileBlob := ConvertTextToBlob(TextContent);

        // Calculate hash
        exit(CalculateFileSHA256Hash(FileBlob));
    end;

    /// <summary>
    /// Calculate MD5 hash (faster but less secure than SHA256)
    /// </summary>
    /// <param name="FileContent">The file blob to hash</param>
    /// <returns>MD5 hash string in hex format</returns>
    procedure CalculateFileMD5Hash(FileContent: Blob): Text
    var
        HashAlgorithm: System.Security.Cryptography.HashAlgorithm;
        HashBytes: array of Byte;
        HashHex: Text;
        i: Integer;
    begin
        // Create MD5 hash algorithm
        HashAlgorithm := System.Security.Cryptography.MD5.Create();

        // Get bytes from blob
        HashBytes := FileContent.GetByteArray();

        // Calculate hash
        HashBytes := HashAlgorithm.ComputeHash(HashBytes);

        // Convert to hex string
        HashHex := '';
        for i := 1 to ArrayLen(HashBytes) do begin
            HashHex += PadStr(Format(HashBytes[i], 0, '<Hex>'), 2, '0');
        end;

        exit(HashHex);
    end;

    /// <summary>
    /// Verify a file hasn't been modified (integrity check)
    /// </summary>
    /// <param name="FileContent">The current file content</param>
    /// <param name="StoredHash">The previously calculated hash</param>
    /// <param name="HashType">Type of hash: SHA256 or MD5</param>
    /// <returns>True if file hasn't changed</returns>
    procedure VerifyFileIntegrity(FileContent: Blob; StoredHash: Text; HashType: Text): Boolean
    var
        CurrentHash: Text;
    begin
        case HashType of
            'SHA256':
                CurrentHash := CalculateFileSHA256Hash(FileContent);
            'MD5':
                CurrentHash := CalculateFileMD5Hash(FileContent);
            else
                Error('Unknown hash type: ' + HashType);
        end;

        // Compare hashes (case-insensitive)
        exit(UpperCase(CurrentHash) = UpperCase(StoredHash));
    end;

    /// <summary>
    /// Check if file already exists (by hash comparison)
    /// </summary>
    /// <param name="FileContent">The file content to check</param>
    /// <param name="ExcludeDocumentID">Document ID to exclude from search (optional)</param>
    /// <returns>Document ID of duplicate, or blank if not found</returns>
    procedure CheckForDuplicateFile(FileContent: Blob; ExcludeDocumentID: Code[20]): Code[20]
    var
        ApplicationDoc: Record "Application Document";
        FileHash: Text;
    begin
        // Calculate hash of file
        FileHash := CalculateFileSHA256Hash(FileContent);

        // Search for existing file with same hash
        ApplicationDoc.SetFilter("Hash Value", FileHash);

        if ExcludeDocumentID <> '' then
            ApplicationDoc.SetFilter("Document ID", '<>%1', ExcludeDocumentID);

        if ApplicationDoc.FindFirst() then begin
            // Duplicate found!
            exit(ApplicationDoc."Document ID");
        end;

        // No duplicate
        exit('');
    end;

    /// <summary>
    /// Generate hash-based filename to prevent conflicts
    /// </summary>
    /// <param name="OriginalFileName">Original filename</param>
    /// <param name="FileContent">File content</param>
    /// <returns>New unique filename based on hash</returns>
    procedure GenerateHashBasedFileName(OriginalFileName: Text; FileContent: Blob): Text
    var
        FileHash: Text;
        FileExtension: Text;
        NewFileName: Text;
    begin
        // Calculate hash
        FileHash := CalculateFileSHA256Hash(FileContent);

        // Get file extension
        FileExtension := ExtractFileExtension(OriginalFileName);

        // Generate new name: first 12 chars of hash + timestamp + extension
        // Example: a1b2c3d4e5f6_20240115_143025.pdf
        NewFileName := CopyStr(FileHash, 1, 12) + '_' +
                       Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2>_<Hour24,2><Minute,2><Second,2>') +
                       '.' + FileExtension;

        exit(NewFileName);
    end;

    /// <summary>
    /// Compare two files for equality
    /// </summary>
    /// <param name="File1">First file content</param>
    /// <param name="File2">Second file content</param>
    /// <returns>True if files are identical</returns>
    procedure CompareFiles(File1: Blob; File2: Blob): Boolean
    var
        Hash1: Text;
        Hash2: Text;
    begin
        Hash1 := CalculateFileSHA256Hash(File1);
        Hash2 := CalculateFileSHA256Hash(File2);

        exit(Hash1 = Hash2);
    end;

    /// <summary>
    /// Get hash of file at specific path
    /// </summary>
    /// <param name="FilePath">Full file path</param>
    /// <returns>SHA256 hash of file</returns>
    procedure GetFileHashFromPath(FilePath: Text): Text
    var
        FileContent: Blob;
        InStream: InStream;
    begin
        // Read file into blob
        // Note: This requires file system access
        // In real BC, you'd use File.ReadAsBlob() or similar

        exit(''); // Placeholder
    end;

    /// <summary>
    /// Validate hash format (32 hex chars for MD5, 64 for SHA256)
    /// </summary>
    /// <param name="HashValue">Hash to validate</param>
    /// <param name="HashType">Type: SHA256 or MD5</param>
    /// <returns>True if valid format</returns>
    procedure IsValidHashFormat(HashValue: Text; HashType: Text): Boolean
    var
        ExpectedLength: Integer;
        i: Integer;
        Char: Char;
    begin
        case HashType of
            'SHA256':
                ExpectedLength := 64;
            'MD5':
                ExpectedLength := 32;
            else
                exit(false);
        end;

        // Check length
        if StrLen(HashValue) <> ExpectedLength then
            exit(false);

        // Check all characters are hex (0-9, A-F)
        for i := 1 to StrLen(HashValue) do begin
            Char := HashValue[i];
            if not ((Char >= '0' and Char <= '9') or
                    (Char >= 'A' and Char <= 'F') or
                    (Char >= 'a' and Char <= 'f')) then
                exit(false);
        end;

        exit(true);
    end;

    // ============================================
    // HELPER PROCEDURES (Private)
    // ============================================

    /// <summary>
    /// Convert text to blob
    /// </summary>
    local procedure ConvertTextToBlob(TextContent: Text): Blob
    var
        FileBlob: Blob;
        OutStream: OutStream;
    begin
        FileBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(TextContent);
        exit(FileBlob);
    end;

    /// <summary>
    /// Extract file extension from filename
    /// </summary>
    local procedure ExtractFileExtension(FileName: Text): Text
    var
        Parts: List of [Text];
    begin
        Parts := FileName.Split('.');
        if Parts.Count() > 1 then
            exit(Parts.Get(Parts.Count()))
        else
            exit('');
    end;

    /// <summary>
    /// Convert byte array to hex string
    /// </summary>
    local procedure ByteArrayToHex(ByteArray: array of Byte): Text
    var
        HexString: Text;
        i: Integer;
    begin
        HexString := '';
        for i := 1 to ArrayLen(ByteArray) do begin
            HexString += PadStr(Format(ByteArray[i], 0, '<Hex>'), 2, '0');
        end;
        exit(HexString);
    end;

    /// <summary>
    /// Convert hex string to byte array
    /// </summary>
    local procedure HexToByteArray(HexString: Text): array of Byte
    var
        ByteArray: array of Byte;
        i: Integer;
        HexPair: Text;
        ByteValue: Integer;
    begin
        if StrLen(HexString) mod 2 <> 0 then
            Error('Invalid hex string length');

        for i := 1 to StrLen(HexString) / 2 do begin
            HexPair := CopyStr(HexString, (i - 1) * 2 + 1, 2);
            if Evaluate(ByteValue, HexPair, 16) then begin
                ArrayLen(ByteArray, i);
                ByteArray[i] := ByteValue;
            end;
        end;

        exit(ByteArray);
    end;
}
