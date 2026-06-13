namespace BCTRAINING.BCTRAINING;

page 50111 "Employees Loan Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Employee Loan Header";
    Caption = 'Employee Loan';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Status" = Rec."Status"::Open;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = All;
                    Editable = Rec."Status" = Rec."Status"::Open;
                }
            }

            group(LoanDetails)
            {
                Caption = 'Loan Details';

                field("Loan Type"; Rec."Loan Type")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Status" = Rec."Status"::Open;
                }
                field("Requested Amount"; Rec."Requested Amount")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Status" = Rec."Status"::Open;
                }
                field("Approved Amount"; Rec."Approved Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Term Months"; Rec."Term Months")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Status" = Rec."Status"::Open;
                }
                field("Interest Rate"; Rec."Interest Rate")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Purpose"; Rec."Purpose")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Status" = Rec."Status"::Open;
                }
            }

            group(State)
            {
                Caption = 'Status';

                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Approval Status"; Rec."Approval Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Approval Date"; Rec."Approval Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Rejection Reason"; Rec."Rejection Reason")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }

            group(Disbursement)
            {
                Caption = 'Disbursement';

                field("Disbursement Date"; Rec."Disbursement Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Disbursed Amount"; Rec."Disbursed Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }

            group(Balance)
            {
                Caption = 'Balance Information';

                field("Outstanding Balance"; Rec."Outstanding Balance")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Paid"; Rec."Total Paid")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }

            group(Closure)
            {
                Caption = 'Closure';

                field("Closed Date"; Rec."Closed Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }

            group(AuditTrail)
            {
                Caption = 'Audit Trail';

                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Last Modified By"; Rec."Last Modified By")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Last Modified Date"; Rec."Last Modified Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }

        area(FactBoxes)
        {
            part(RepaymentSchedule; "Loan Schedule FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Loan No." = field("Loan No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewSchedule)
            {
                Caption = 'View Repayment Schedule';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = Rec."Status" = Rec."Status"::Disbursed;

                trigger OnAction()
                var
                    LoanSchedule: Record "Employee Loan Schedule";
                begin
                    LoanSchedule.SetRange("Loan No.", Rec."Loan No.");
                    Page.Run(Page::"Loan Schedule List", LoanSchedule);
                end;
            }

            action(ApproveLoan)
            {
                Caption = 'Approve';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                Visible = Rec."Status" = Rec."Status"::"Pending Approval";

                trigger OnAction()
                var
                    LoanApprovalMgmt: Codeunit "Loan Approval Management";
                begin
                    if LoanApprovalMgmt.ApproveLoan(Rec."Loan No.", UserId, '') then begin
                        Rec.Get(Rec."Loan No.");
CurrPage.Update(false);
                        Message('Loan approved successfully.');
                    end;
                end;
            }

            action(RejectLoan)
            {
                Caption = 'Reject';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Process;
                Visible = Rec."Status" = Rec."Status"::"Pending Approval";

                trigger OnAction()
                var
                    LoanApprovalMgmt: Codeunit "Loan Approval Management";
                    RejectionReason: Text[500];
                begin
                    if Confirm('Are you sure you want to reject this loan?', false) then begin
                        RejectionReason := 'Reason: ' + '';
                        if LoanApprovalMgmt.RejectLoan(Rec."Loan No.", UserId, RejectionReason) then begin
                            Rec.Get(Rec."Loan No.");
                            CurrPage.Update(false);
                            Message('Loan rejected.');
                        end;
                    end;
                end;
            }

            action(DisburseAmount)
            {
                Caption = 'Disburse Loan';
                Image = Payment;
                Promoted = true;
                PromotedCategory = Process;
                Visible = Rec."Status" = Rec."Status"::Approved;

                /*trigger OnAction()
              var
                   LoanManagement: Codeunit "Loan Management";
                begin
                    if Confirm('Are you sure you want to disburse this loan?', false) then begin
                        if LoanManagement.DisburseLoan(Rec."Loan No.", Today) then begin
                            Rec.Get(Rec."Loan No.");
                            CurrPage.Update(false);
                            Message('Loan disbursed successfully.');
                        end;
                    end;
                end;*/
            }
        }
    }
}