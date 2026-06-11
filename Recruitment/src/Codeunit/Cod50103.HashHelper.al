namespace BCTRAINING.BCTRAINING;

using System.Security.Encryption;
using System.Utilities;

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

    /// <summary>
    /// Calculate SHA256 hash of a Blob using CryptographyManagement
    /// </summary>
    /// <param name="FileContent">The file blob to hash</param>
    /// <returns>SHA256 hash string in hex format</returns>
    procedure CalculateFileSHA256Hash(var FileContent: Blob): Text
    var
        CryptographyMgt: Codeunit "Cryptography Management";
        InStr: InStream;
    begin
        // Blob must be passed by var in AL.
        // GenerateHash requires the HashAlgorithmType enum, not an integer.
        FileContent.CreateInStream(InStr);
        exit(CryptographyMgt.GenerateHash(InStr, Enum::"Hash Algorithm"::SHA256));
    end;

    /// <summary>
    /// Calculate SHA256 hash of text content
    /// </summary>
    /// <param name="TextContent">The text to hash</param>
    /// <returns>SHA256 hash string in hex format</returns>
    procedure CalculateTextSHA256Hash(TextContent: Text): Text
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        // FIX: Removed invalid System.Text.Encoding reference.
        // FIX: ConvertTextToBlob now uses var parameter (Blob cannot be returned by value).
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(TextContent);

        // Reuse CalculateFileSHA256Hash via TempBlob
        exit(CalculateTempBlobSHA256Hash(TempBlob));
    end;

    /// <summary>
    /// Calculate MD5 hash (faster but less secure than SHA256)
    /// </summary>
    /// <param name="FileContent">The file blob to hash</param>
    /// <returns>MD5 hash string in hex format</returns>
    procedure CalculateFileMD5Hash(var FileContent: Blob): Text
    var
        CryptographyMgt: Codeunit "Cryptography Management";
        InStr: InStream;
    begin
        FileContent.CreateInStream(InStr);
#pragma warning disable AL0603
        exit(CryptographyMgt.GenerateHash(InStr, Enum::"Hash Algorithm"::MD5));
#pragma warning restore AL0603
    end;

    /// <summary>
    /// Verify a file hasn't been modified (integrity check)
    /// </summary>
    /// <param name="FileContent">The current file content</param>
    /// <param name="StoredHash">The previously calculated hash</param>
    /// <param name="HashType">Type of hash: SHA256 or MD5</param>
    /// <returns>True if file hasn't changed</returns>
    procedure VerifyFileIntegrity(var FileContent: Blob; StoredHash: Text; HashType: Text): Boolean
    var
        CurrentHash: Text;
    begin
        case HashType of
            'SHA256':
                CurrentHash := CalculateFileSHA256Hash(FileContent);
            'MD5':
                CurrentHash := CalculateFileMD5Hash(FileContent);
            else
                Error('Unknown hash type: %1', HashType);
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
    procedure CheckForDuplicateFile(var FileContent: Blob; ExcludeDocumentID: Code[20]): Code[20]
    var
        ApplicationDoc: Record "Application Document";
        FileHash: Text;
    begin
        FileHash := CalculateFileSHA256Hash(FileContent);

        ApplicationDoc.SetRange("Hash Value", FileHash);

        if ExcludeDocumentID <> '' then
            ApplicationDoc.SetFilter("Document ID", '<>%1', ExcludeDocumentID);

        if ApplicationDoc.FindFirst() then
            exit(ApplicationDoc."Document ID");

        exit('');
    end;

    /// <summary>
    /// Generate hash-based filename to prevent conflicts
    /// </summary>
    /// <param name="OriginalFileName">Original filename</param>
    /// <param name="FileContent">File content</param>
    /// <returns>New unique filename based on hash</returns>
    procedure GenerateHashBasedFileName(OriginalFileName: Text; var FileContent: Blob): Text
    var
        FileHash: Text;
        FileExtension: Text;
        NewFileName: Text;
    begin
        FileHash := CalculateFileSHA256Hash(FileContent);
        FileExtension := ExtractFileExtension(OriginalFileName);

        // First 12 chars of hash + timestamp + extension
        // Example: a1b2c3d4e5f6_20240115_143025.pdf
        NewFileName := CopyStr(FileHash, 1, 12) + '_' +
                       Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2><Seconds,2>') +
                       '.' + FileExtension;

        exit(NewFileName);
    end;

    /// <summary>
    /// Compare two files for equality
    /// </summary>
    /// <param name="File1">First file content</param>
    /// <param name="File2">Second file content</param>
    /// <returns>True if files are identical</returns>
    procedure CompareFiles(var File1: Blob; var File2: Blob): Boolean
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
    begin
        // Placeholder: File system access requires server-side file handling.
        // In OnPrem BC, use File codeunit; in SaaS this is not supported.
        exit('');
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

        if StrLen(HashValue) <> ExpectedLength then
            exit(false);

        for i := 1 to StrLen(HashValue) do begin
            Char := HashValue[i];
            if not (((Char >= '0') and (Char <= '9')) or
                    ((Char >= 'A') and (Char <= 'F')) or
                    ((Char >= 'a') and (Char <= 'f'))) then
                exit(false);
        end;

        exit(true);
    end;

    // ============================================
    // HELPER PROCEDURES (Private)
    // ============================================

    /// <summary>
    /// Internal helper: hash a TempBlob via SHA256
    /// FIX: Blob cannot be returned by value from a procedure in AL.
    /// This avoids that by working directly with TempBlob codeunit.
    /// </summary>
    local procedure CalculateTempBlobSHA256Hash(var TempBlob: Codeunit "Temp Blob"): Text
    var
        CryptographyMgt: Codeunit "Cryptography Management";
        InStr: InStream;
    begin
        TempBlob.CreateInStream(InStr);
        exit(CryptographyMgt.GenerateHash(InStr, 2)); // 2 = SHA256
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
    /// Convert byte array to hex string (left-padded per byte)
    /// FIX: Original used PadStr which pads RIGHT, not left — wrong for hex bytes.
    /// </summary>
    local procedure ByteArrayToHex(ByteArray: array[64] of Byte): Text
    var
        HexString: Text;
        ByteHex: Text;
        i: Integer;
    begin
        HexString := '';
        for i := 1 to ArrayLen(ByteArray) do begin
            ByteHex := Format(ByteArray[i], 0, '<Hex>');
            // Left-pad with '0' if only one character
            if StrLen(ByteHex) = 1 then
                ByteHex := '0' + ByteHex;
            HexString += ByteHex;
        end;
        exit(HexString);
    end;
}
