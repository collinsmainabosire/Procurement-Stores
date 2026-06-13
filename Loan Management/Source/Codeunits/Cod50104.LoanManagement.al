namespace BCTRAINING.BCTRAINING;

codeunit 50104 " Loan Management"
{
    trigger OnRun()
    begin
    end;

    /// <summary>
    /// Creates a new loan based on employee loan header details
    /// </summary>
    procedure CreateLoan(var LoanHeader: Record "Employee Loan Header"): Boolean
    begin
        // Validations
        if not ValidateLoan(LoanHeader) then
            exit(false);

        // Insert the loan
        LoanHeader.Insert(true);

        // Create audit log entry
        LogLoanActivity(LoanHeader."Loan No.", 'Loan created', LoanUserId);

        exit(true);
    end;

    /// <summary>
    /// Validates loan before processing
    /// </summary>
    procedure ValidateLoan(var LoanHeader: Record "Employee Loan Header"): Boolean
    var
        Employee: Record Employee;
        LoanType: Record "Employee Loan Type";
        ExistingLoan: Record "Employee Loan Header";
        LoanSetup: Record "Employee Loan Setup";
        LoanCount: Integer;
    begin
        // Validate employee
        if not Employee.Get(LoanHeader."Employee No.") then begin
            Error('Employee %1 does not exist.', LoanHeader."Employee No.");
            exit(false);
        end;

        // Validate loan type
        if not LoanType.Get(LoanHeader."Loan Type") then begin
            Error('Loan Type %1 does not exist.', LoanHeader."Loan Type");
            exit(false);
        end;

        if not LoanType.Active then begin
            Error('Loan Type %1 is inactive.', LoanHeader."Loan Type");
            exit(false);
        end;

        // Validate amount
        if LoanHeader."Requested Amount" <= 0 then begin
            Error('Requested amount must be greater than zero.');
            exit(false);
        end;

        if LoanHeader."Requested Amount" > LoanType."Maximum Amount" then begin
            Error('Requested amount %1 exceeds maximum amount %2 for loan type %3',
                LoanHeader."Requested Amount", LoanType."Maximum Amount", LoanHeader."Loan Type");
            exit(false);
        end;

        // Validate term
        if LoanHeader."Term Months" <= 0 then begin
            Error('Term must be greater than zero.');
            exit(false);
        end;

        if LoanHeader."Term Months" > LoanType."Maximum Term Months" then begin
            Error('Requested term %1 months exceeds maximum term %2 months for loan type %3',
                LoanHeader."Term Months", LoanType."Maximum Term Months", LoanHeader."Loan Type");
            exit(false);
        end;

        // Check max loans per employee
        LoanSetup.Get();
        ExistingLoan.SetRange("Employee No.", LoanHeader."Employee No.");
        ExistingLoan.SetFilter("Status", '<>%1&<>%2', LoanHeader."Status"::Rejected, LoanHeader."Status"::Closed);
        LoanCount := ExistingLoan.Count();

        if LoanCount >= LoanSetup."Max Loans Per Employee" then begin
            Error('Employee %1 has reached maximum number of active loans (%2).',
                LoanHeader."Employee No.", LoanSetup."Max Loans Per Employee");
            exit(false);
        end;

        exit(true);
    end;

    /// <summary>
    /// Generates repayment schedule for approved loan
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
        if not LoanHeader.Get(LoanNo) then begin
            Error('Loan %1 not found.', LoanNo);
            exit(false);
        end;

        // Delete existing schedule
        LoanSchedule.SetRange("Loan No.", LoanNo);
        LoanSchedule.DeleteAll();

        // Calculate installment amounts
        PrincipalPerInstallment := LoanHeader."Approved Amount" / LoanHeader."Term Months";
        InterestPerInstallment := (LoanHeader."Approved Amount" * LoanHeader."Interest Rate") / 100 / LoanHeader."Term Months";

        RemainingBalance := LoanHeader."Approved Amount";
        DueDate := LoanHeader."Disbursement Date";

        // Generate schedule
        for i := 1 to LoanHeader."Term Months" do begin
            DueDate := CalcDate('<1M>', DueDate);

            LoanSchedule.Init();
            LoanSchedule."Loan No." := LoanNo;
            LoanSchedule."Installment No." := i;
            LoanSchedule."Due Date" := DueDate;
            LoanSchedule."Principal Amount" := PrincipalPerInstallment;
            LoanSchedule."Interest Amount" := InterestPerInstallment;
            LoanSchedule."Total Amount" := PrincipalPerInstallment + InterestPerInstallment;
            LoanSchedule."Remaining Balance" := RemainingBalance - PrincipalPerInstallment;
            LoanSchedule."Payment Status" := "Payment Status"::Pending;

            LoanSchedule.Insert(true);

            RemainingBalance -= PrincipalPerInstallment;
        end;

        LogLoanActivity(LoanNo, 'Repayment schedule generated', UserId);
        exit(true);
    end;

    /// <summary>
    /// Calculates current loan balance
    /// </summary>
    procedure CalculateBalance(LoanNo: Code[20]): Decimal
    var
        LoanSchedule: Record "Employee Loan Schedule";
        TotalPaid: Decimal;
        TotalAmount: Decimal;
    begin
        LoanSchedule.SetRange("Loan No.", LoanNo);

        // Calculate total amount
        LoanSchedule.CalcSums("Total Amount");
        TotalAmount := LoanSchedule."Total Amount";

        // Calculate total paid
        LoanSchedule.CalcSums("Paid Amount");
        TotalPaid := LoanSchedule."Paid Amount";

        exit(TotalAmount - TotalPaid);
    end;

    /// <summary>
    /// Processes monthly loan deductions
    /// </summary>
    procedure ProcessMonthlyDeductions(): Boolean
    var
        LoanSchedule: Record "Employee Loan Schedule";
        LoanHeader: Record "Employee Loan Header";
        MonthStart: Date;
        MonthEnd: Date;
    begin
        MonthStart := CalcDate('<-CM>', Today);
        MonthEnd := CalcDate('<CM>', Today);

        // Get all pending installments due this month
        LoanSchedule.SetRange("Payment Status", "Payment Status"::Pending);
        LoanSchedule.SetRange("Due Date", MonthStart, MonthEnd);

        if LoanSchedule.FindSet() then begin
            repeat
                // Mark as paid
                LoanSchedule."Payment Status" := "Payment Status"::Paid;
                LoanSchedule."Payment Date" := Today;
                LoanSchedule."Paid Amount" := LoanSchedule."Total Amount";
                LoanSchedule.Modify(true);

                // Update loan header balance
                if LoanHeader.Get(LoanSchedule."Loan No.") then begin
                    LoanHeader."Outstanding Balance" := CalculateBalance(LoanSchedule."Loan No.");
                    LoanHeader."Total Paid" += LoanSchedule."Total Amount";

                    // Close loan if fully paid
                    if LoanHeader."Outstanding Balance" <= 0 then begin
                        CloseLoan(LoanHeader."Loan No.");
                    end;

                    LoanHeader.Modify(true);
                end;

                // Create ledger entry
                CreateLedgerEntry(LoanSchedule."Loan No.", "Loan Ledger Document Type"::Payment,
                    'Monthly installment payment', LoanSchedule."Total Amount");
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
        if not LoanHeader.Get(LoanNo) then begin
            Error('Loan %1 not found.', LoanNo);
            exit(false);
        end;

        if LoanHeader."Outstanding Balance" > 0 then begin
            Error('Cannot close loan with outstanding balance.');
            exit(false);
        end;

        LoanHeader."Status" := "Loan Status"::Closed;
        LoanHeader."Closed Date" := Today;
        LoanHeader.Modify(true);

        LogLoanActivity(LoanNo, 'Loan closed - fully repaid', UserId);
        exit(true);
    end;

    /// <summary>
    /// Processes loan disbursement
    /// </summary>
    procedure DisburseLoan(LoanNo: Code[20]; DisbursementDate: Date): Boolean
    var
        LoanHeader: Record "Employee Loan Header";
    begin
        if not LoanHeader.Get(LoanNo) then begin
            Error('Loan %1 not found.', LoanNo);
            exit(false);
        end;

        if LoanHeader."Status" <> "Loan Status"::Approved then begin
            Error('Only approved loans can be disbursed.');
            exit(false);
        end;

        // Update loan header
        LoanHeader."Disbursement Date" := DisbursementDate;
        LoanHeader."Disbursed Amount" := LoanHeader."Approved Amount";
        LoanHeader."Outstanding Balance" := LoanHeader."Approved Amount";
        LoanHeader."Status" := "Loan Status"::Disbursed;
        LoanHeader.Modify(true);

        // Generate schedule
        GenerateSchedule(LoanNo);

        // Create ledger entry
        CreateLedgerEntry(LoanNo, "Loan Ledger Document Type"::Disbursement,
            'Loan disbursed', LoanHeader."Approved Amount");

        LogLoanActivity(LoanNo, 'Loan disbursed', UserId);
        exit(true);
    end;

    /// <summary>
    /// Creates a ledger entry for loan transactions
    /// </summary>
    local procedure CreateLedgerEntry(LoanNo: Code[20]; DocumentType: Enum "Loan Ledger Document Type";
        Description: Text[250]; Amount: Decimal)
    var
        LoanLedger: Record "Employee Loan Ledger Entry";
        LoanHeader: Record "Employee Loan Header";
    begin
        if LoanHeader.Get(LoanNo) then begin
            LoanLedger.Init();
            LoanLedger."Loan No." := LoanNo;
            LoanLedger."Employee No." := LoanHeader."Employee No.";
            LoanLedger."Posting Date" := Today;
            LoanLedger."Document Type" := DocumentType;
            LoanLedger."Description" := Description;
            LoanLedger."Amount" := Amount;
            LoanLedger."Balance" := CalculateBalance(LoanNo);
            LoanLedger.Insert(true);
        end;
    end;

    /// <summary>
    /// Logs loan activity
    /// </summary>
    local procedure LogLoanActivity(LoanNo: Code[20]; Activity: Text[250]; UserId: Code[50])
    var
        LoanLedger: Record "Employee Loan Ledger Entry";
        LoanHeader: Record "Employee Loan Header";
    begin
        if LoanHeader.Get(LoanNo) then begin
            LoanLedger.Init();
            LoanLedger."Loan No." := LoanNo;
            LoanLedger."Employee No." := LoanHeader."Employee No.";
            LoanLedger."Posting Date" := Today;
            LoanLedger."Document Type" := "Loan Ledger Document Type"::Interest;
            LoanLedger."Description" := Activity;
            LoanLedger."Amount" := 0;
            LoanLedger.Insert(true);
        end;
    end;
}