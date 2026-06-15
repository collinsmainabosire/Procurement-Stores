namespace BCTRAINING.BCTRAINING;
using Microsoft.HumanResources.Employee;

codeunit 50104 "Loan Management"
{
    /// <summary>
    /// Creates a new loan and validates all data
    /// </summary>
    /// <param name="LoanHeader">The loan header record to create</param>
    /// <returns>True if successful, False otherwise</returns>
    procedure CreateLoan(var LoanHeader: Record "Employee Loan Header"): Boolean
    begin
        // Validate before creating
        if not ValidateLoan(LoanHeader) then
            exit(false);

        // Insert into database
        LoanHeader.Insert(true);

        // Log the activity for audit trail
        LogLoanActivity(LoanHeader."Loan No.", 'Loan created', UserId);

        exit(true);
    end;

    /// <summary>
    /// Validates loan data before processing
    /// Checks business rules and constraints
    /// </summary>
    procedure ValidateLoan(var LoanHeader: Record "Employee Loan Header"): Boolean
    var
        Employee: Record Employee;
        LoanType: Record "Employee Loan Type";
        ExistingLoan: Record "Employee Loan Header";
        LoanSetup: Record "Employee Loan Setup";
        LoanCount: Integer;
    begin
        // Step 1: Check if employee exists
        if not Employee.Get(LoanHeader."Employee No.") then begin
            Error('Employee %1 does not exist.', LoanHeader."Employee No.");
            exit(false);
        end;

        // Step 2: Check if loan type exists
        if not LoanType.Get(LoanHeader."Loan Type") then begin
            Error('Loan Type %1 does not exist.', LoanHeader."Loan Type");
            exit(false);
        end;

        // Step 3: Check if loan type is active
        if not LoanType.Active then begin
            Error('Loan type %1 is inactive.', LoanHeader."Loan Type");
            exit(false);
        end;

        // Step 4: Validate requested amount
        if LoanHeader."Requested Amount" <= 0 then begin
            Error('Requested amount must be greater than zero.');
            exit(false);
        end;

        if LoanHeader."Requested Amount" > LoanType."Maximum Amount" then begin
            Error('Requested amount %1 exceeds maximum amount %2 for loan type %3',
                LoanHeader."Requested Amount", LoanType."Maximum Amount", LoanHeader."Loan Type");
            exit(false);
        end;

        // Step 5: Validate term
        if LoanHeader."Term Months" <= 0 then begin
            Error('Term must be greater than zero.');
            exit(false);
        end;

        if LoanHeader."Term Months" > LoanType."Maximum Term Months" then begin
            Error('Requested term %1 months exceeds maximum term %2 months for loan type %3',
                LoanHeader."Term Months", LoanType."Maximum Term Months", LoanHeader."Loan Type");
            exit(false);
        end;

        // Step 6: Check max loans per employee
        LoanSetup.Get();
        ExistingLoan.SetRange("Employee No.", LoanHeader."Employee No.");
        // Count only active loans (not rejected or closed)
        ExistingLoan.SetFilter("Status", '<>%1&<>%2',
            LoanHeader."Status"::Rejected, LoanHeader."Status"::Closed);
        LoanCount := ExistingLoan.Count();

        if LoanCount >= LoanSetup."Max Loans Per Employee" then begin
            Error('Employee %1 has reached maximum number of active loans (%2).',
                LoanHeader."Employee No.", LoanSetup."Max Loans Per Employee");
            exit(false);
        end;

        // All validations passed
        exit(true);
    end;

    /// <summary>
    /// Generates repayment schedule for approved loan
    /// Creates monthly installment records
    /// </summary>
    procedure GenerateSchedule(LoanNo: Code[20]): Boolean
    var
        LoanHeader: Record "Employee Loan Header";
        LoanSchedule: Record "Employee Loan Schedule";
        PrincipalPerInstallment: Decimal;
        InterestPerInstallment: Decimal;
        RemainingBalance: Decimal;
        DueDate: Date;
        i: Integer;
    begin
        // Get the loan header
        if not LoanHeader.Get(LoanNo) then begin
            Error('Loan %1 not found.', LoanNo);
            exit(false);
        end;

        // Delete existing schedule (in case regenerating)
        LoanSchedule.SetRange("Loan No.", LoanNo);
        LoanSchedule.DeleteAll();

        // Calculate per-installment amounts
        // Total Principal / Number of Months = Monthly Principal
        PrincipalPerInstallment := LoanHeader."Approved Amount" / LoanHeader."Term Months";

        // Total Interest / Number of Months = Monthly Interest
        // Interest = (Principal * Rate) / 100 / Term
        InterestPerInstallment := (LoanHeader."Approved Amount" * LoanHeader."Interest Rate") / 100 / LoanHeader."Term Months";

        // Start with full approved amount as balance
        RemainingBalance := LoanHeader."Approved Amount";

        // Start from disbursement date
        DueDate := LoanHeader."Disbursement Date";

        // Create installment records (Loop 1 to Term Months)
        for i := 1 to LoanHeader."Term Months" do begin
            // Add one month to due date
            DueDate := CalcDate('<1M>', DueDate);

            // Initialize new schedule record
            LoanSchedule.Init();
            LoanSchedule."Loan No." := LoanNo;
            LoanSchedule."Installment No." := i;
            LoanSchedule."Due Date" := DueDate;
            LoanSchedule."Principal Amount" := PrincipalPerInstallment;
            LoanSchedule."Interest Amount" := InterestPerInstallment;
            LoanSchedule."Total Amount" := PrincipalPerInstallment + InterestPerInstallment;

            // Remaining balance decreases each month
            LoanSchedule."Remaining Balance" := RemainingBalance - PrincipalPerInstallment;

            // New installments are always "Pending"
            LoanSchedule."Payment Status" := "Payment Status"::Pending;

            // Insert into database
            LoanSchedule.Insert(true);

            // Reduce remaining balance for next iteration
            RemainingBalance -= PrincipalPerInstallment;
        end;

        // Log this action
        LogLoanActivity(LoanNo, 'Repayment schedule generated', UserId);

        exit(true);
    end;

    /// <summary>
    /// Calculates current outstanding balance for a loan
    /// Outstanding = Total Amount - Total Paid
    /// </summary>
    procedure CalculateBalance(LoanNo: Code[20]): Decimal
    var
        LoanSchedule: Record "Employee Loan Schedule";
        TotalPaid: Decimal;
        TotalAmount: Decimal;
    begin
        // Get all installments for this loan
        LoanSchedule.SetRange("Loan No.", LoanNo);

        // Sum up all total amounts
        LoanSchedule.CalcSums("Total Amount");
        TotalAmount := LoanSchedule."Total Amount";

        // Sum up all paid amounts
        LoanSchedule.CalcSums("Paid Amount");
        TotalPaid := LoanSchedule."Paid Amount";

        // Return the difference
        exit(TotalAmount - TotalPaid);
    end;

    /// <summary>
    /// Processes monthly loan deductions
    /// Called by job queue on monthly processing day
    /// </summary>
    procedure ProcessMonthlyDeductions(): Boolean
    var
        LoanSchedule: Record "Employee Loan Schedule";
        LoanHeader: Record "Employee Loan Header";
        MonthStart: Date;
        MonthEnd: Date;
    begin
        // Get first and last day of current month
        MonthStart := CalcDate('<-CM>', Today);
        MonthEnd := CalcDate('<CM>', Today);

        // Find all pending installments due this month
        LoanSchedule.SetRange("Payment Status", "Payment Status"::Pending);
        LoanSchedule.SetRange("Due Date", MonthStart, MonthEnd);

        // Process each due installment
        if LoanSchedule.FindSet() then begin
            repeat
                // Mark as paid
                LoanSchedule."Payment Status" := "Payment Status"::Paid;
                LoanSchedule."Payment Date" := Today;
                LoanSchedule."Paid Amount" := LoanSchedule."Total Amount";
                LoanSchedule.Modify(true);

                // Update the parent loan header
                if LoanHeader.Get(LoanSchedule."Loan No.") then begin
                    // Recalculate outstanding balance
                    LoanHeader."Outstanding Balance" := CalculateBalance(LoanSchedule."Loan No.");

                    // Add to total paid
                    LoanHeader."Total Paid" += LoanSchedule."Total Amount";

                    // Check if loan is fully paid
                    if LoanHeader."Outstanding Balance" <= 0 then begin
                        CloseLoan(LoanHeader."Loan No.");
                    end;

                    // Save changes
                    LoanHeader.Modify(true);
                end;

                // Create ledger entry for audit
                CreateLedgerEntry(
                    LoanSchedule."Loan No.",
                    "Loan Ledger Document Type"::Payment,
                    'Monthly installment payment',
                    LoanSchedule."Total Amount"
                );
            until LoanSchedule.Next() = 0;
        end;

        exit(true);
    end;

    /// <summary>
    /// Closes a loan when fully repaid
    /// </summary>
    procedure CloseLoan(LoanNo: Code[20]): Boolean
    var
        LoanHeader: Record "Employee Loan Header";
    begin
        // Get the loan
        if not LoanHeader.Get(LoanNo) then begin
            Error('Loan %1 not found.', LoanNo);
            exit(false);
        end;

        // Can't close if still has outstanding balance
        if LoanHeader."Outstanding Balance" > 0 then begin
            Error('Cannot close loan with outstanding balance.');
            exit(false);
        end;

        // Update status to Closed
        LoanHeader."Status" := "Loan Status"::Closed;
        LoanHeader."Closed Date" := Today;
        LoanHeader.Modify(true);

        // Log closure
        LogLoanActivity(LoanNo, 'Loan closed - fully repaid', UserId);

        exit(true);
    end;

    /// <summary>
    /// Processes loan disbursement
    /// Marks loan as disbursed and generates schedule
    /// </summary>
    procedure DisburseLoan(LoanNo: Code[20]; DisbursementDate: Date): Boolean
    var
        LoanHeader: Record "Employee Loan Header";
    begin
        // Get the loan
        if not LoanHeader.Get(LoanNo) then begin
            Error('Loan %1 not found.', LoanNo);
            exit(false);
        end;

        // Can only disburse approved loans
        if LoanHeader."Status" <> "Loan Status"::Approved then begin
            Error('Only approved loans can be disbursed.');
            exit(false);
        end;

        // Update loan with disbursement details
        LoanHeader."Disbursement Date" := DisbursementDate;
        LoanHeader."Disbursed Amount" := LoanHeader."Approved Amount";
        LoanHeader."Outstanding Balance" := LoanHeader."Approved Amount";
        LoanHeader."Status" := "Loan Status"::Disbursed;
        LoanHeader.Modify(true);

        // Generate payment schedule
        GenerateSchedule(LoanNo);

        // Create ledger entry
        CreateLedgerEntry(
            LoanNo,
            "Loan Ledger Document Type"::Disbursement,
            'Loan disbursed',
            LoanHeader."Approved Amount"
        );

        // Log activity
        LogLoanActivity(LoanNo, 'Loan disbursed', UserId);

        exit(true);
    end;

    /// <summary>
    /// Creates a ledger entry for audit trail
    /// Records all loan transactions
    /// </summary>
    local procedure CreateLedgerEntry(
        LoanNo: Code[20];
        DocumentType: Enum "Loan Ledger Document Type";
        Description: Text[250];
        Amount: Decimal
    )
    var
        LoanLedger: Record "Employee Loan Ledger Entry";
        LoanHeader: Record "Employee Loan Header";
    begin
        // Get the loan to access employee number
        if LoanHeader.Get(LoanNo) then begin
            // Create new ledger entry
            LoanLedger.Init();
            LoanLedger."Loan No." := LoanNo;
            LoanLedger."Employee No." := LoanHeader."Employee No.";
            LoanLedger."Posting Date" := Today;
            LoanLedger."Document Type" := DocumentType;
            LoanLedger."Description" := Description;
            LoanLedger."Amount" := Amount;
            LoanLedger."Balance" := CalculateBalance(LoanNo);

            // Insert into database
            LoanLedger.Insert(true);
        end;
    end;

    /// <summary>
    /// Logs loan activity for audit trail
    /// </summary>
    local procedure LogLoanActivity(LoanNo: Code[20]; Activity: Text[250]; UserIdParam: Code[50])
    var
        LoanLedger: Record "Employee Loan Ledger Entry";
        LoanHeader: Record "Employee Loan Header";
    begin
        // Get the loan
        if LoanHeader.Get(LoanNo) then begin
            // Create audit log entry
            LoanLedger.Init();
            LoanLedger."Loan No." := LoanNo;
            LoanLedger."Employee No." := LoanHeader."Employee No.";
            LoanLedger."Posting Date" := Today;
            // Using Interest as activity log type
            LoanLedger."Document Type" := "Loan Ledger Document Type"::Interest;
            LoanLedger."Description" := Activity;
            LoanLedger."Amount" := 0;
            LoanLedger."Created By" := UserIdParam;

            // Insert into database
            LoanLedger.Insert(true);
        end;
    end;
}