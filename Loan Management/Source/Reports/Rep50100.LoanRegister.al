namespace BCTRAINING.BCTRAINING;

report 50100 "Loan Register"
{
    ApplicationArea = All;
    Caption = 'Loan Register';
    DefaultLayout = RDLC;
    RDLCLayout = './Reports/LoanRegister.rdl';
    UsageCategory = ReportsAndAnalysis;
    
    dataset
    {
        dataitem(LoanHeader; "Employee Loan Header")
        {
            RequestFilterFields = "Loan No.", "Employee No.", "Status", "Application Date";
            
            column(Loan_No; "Loan No.")
            {
                IncludeCaption = true;
            }
            column(Employee_No; "Employee No.")
            {
                IncludeCaption = true;
            }
            column(Employee_Name; "Employee Name")
            {
                IncludeCaption = true;
            }
            column(Loan_Type; "Loan Type")
            {
                IncludeCaption = true;
            }
            column(Requested_Amount; "Requested Amount")
            {
                IncludeCaption = true;
            }
            column(Approved_Amount; "Approved Amount")
            {
                IncludeCaption = true;
            }
            column(Outstanding_Balance; "Outstanding Balance")
            {
                IncludeCaption = true;
            }
            column(Total_Paid; "Total Paid")
            {
                IncludeCaption = true;
            }
            column(Status; Status)
            {
                IncludeCaption = true;
            }
            column(Application_Date; "Application Date")
            {
                IncludeCaption = true;
            }
            column(Approval_Date; "Approval Date")
            {
                IncludeCaption = true;
            }
            column(Term_Months; "Term Months")
            {
                IncludeCaption = true;
            }
            column(Created_By; "Created By")
            {
                IncludeCaption = true;
            }
            column(Created_Date; "Created Date")
            {
                IncludeCaption = true;
            }
            
            // Summary columns
            column(TotalRequestedAmount; TotalRequestedAmount)
            {
            }
            column(TotalApprovedAmount; TotalApprovedAmount)
            {
            }
            column(TotalOutstandingBalance; TotalOutstandingBalance)
            {
            }
            column(TotalPaidAmount; TotalPaidAmount)
            {
            }
            
            trigger OnPreDataItem()
            begin
                // Sort by loan number
                SetCurrentKey("Loan No.");
                
                // Initialize totals
                TotalRequestedAmount := 0;
                TotalApprovedAmount := 0;
                TotalOutstandingBalance := 0;
                TotalPaidAmount := 0;
            end;
            
            trigger OnAfterGetRecord()
            begin
                // Accumulate totals
                TotalRequestedAmount += "Requested Amount";
                TotalApprovedAmount += "Approved Amount";
                TotalOutstandingBalance += "Outstanding Balance";
                TotalPaidAmount += "Total Paid";
            end;
        }
    }
    
    requestpage
    {
        SaveValues = true;
        
        layout
        {
            area(Content)
            {
                group(Filters)
                {
                    Caption = 'Report Filters';
                    
                    field(StatusFilter; StatusFilterVar)
                    {
                        Caption = 'Status';
                        ApplicationArea = All;
                        ToolTip = 'Leave blank to show all statuses';
                    }
                    
                    field(FromDate; FromDateVar)
                    {
                        Caption = 'From Application Date';
                        ApplicationArea = All;
                        ToolTip = 'Start date for report';
                    }
                    
                    field(ToDate; ToDateVar)
                    {
                        Caption = 'To Application Date';
                        ApplicationArea = All;
                        ToolTip = 'End date for report';
                    }
                }
            }
        }
        
        trigger OnOpenPage()
        begin
            // Set default dates
            FromDateVar := CalcDate('<-1Y>', Today);
            ToDateVar := Today;
        end;
    }
    
    trigger OnPreReport()
    begin
        // Apply filters from request page
        if FromDateVar <> 0D then
            LoanHeader.SetFilter("Application Date", '>=%1', FromDateVar);
        
        if ToDateVar <> 0D then
            LoanHeader.SetFilter("Application Date", '<=%1', ToDateVar);
    end;
    
    var
        LoanHeaders: Record "Employee Loan Header";
        TotalRequestedAmount: Decimal;
        TotalApprovedAmount: Decimal;
        TotalOutstandingBalance: Decimal;
        TotalPaidAmount: Decimal;
        StatusFilterVar: Text;
        FromDateVar: Date;
        ToDateVar: Date;
}