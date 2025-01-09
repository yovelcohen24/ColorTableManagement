<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ManageColors.aspx.vb" Inherits="ColorTableManagement.WebForm1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css" rel="stylesheet" />
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function confirmDelete() {
            return confirm("האם אתה בטוח שברצונך למחוק?");
        }

        $(document).ready(function () {
            // Make the table rows sortable
            $("#<%= GridView1.ClientID %> tbody").sortable({
                update: function (event, ui) {
                    
                    var sortedIDs = $("#<%= GridView1.ClientID %> tbody tr").map(function () {
                        return $(this).attr("data-id");
                    }).get();

                    // Send the sorted order to the server via AJAX
                    $.ajax({
                        type: "POST",
                        url: "ManageColors.aspx/UpdateOrder",
                        data: JSON.stringify({ sortedIDs: sortedIDs }),
                        contentType: "application/json; charset=utf-8",
                        success: function () {
                            alert("סדר ההצגה עודכן בהצלחה!");
                        },
                        error: function () {
                            alert("אירעה שגיאה בעדכון סדר ההצגה.");
                        }
                    });
                }
            }).disableSelection();
        });
    </script>
    <style>
       
        input[type="checkbox"] {
            width: 1.5rem;
            height: 1.5rem;
            accent-color: #0d6efd; 
            cursor: pointer;
             margin-right: 0.5rem;
        }
        .form-check-label {
        margin-left: 0.5rem; 
        }

        .form-section {
            margin-top: 20px;
        }
        .form-label {
            font-weight: bold;
        }
        .form-check {
            margin-top: 10px;
        }
        .btn {
            margin-top: 15px;
        }
        .table th, .table td {
            vertical-align: middle;
            text-align: center;
        }
        .action-buttons {
            display: flex;
            justify-content: center;
            gap: 10px;
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <div class="container mt-4">
            <h2 class="text-center">טבלת צבעים</h2>

            <!-- Label for messages -->
            <div class="text-center">
                <asp:Label ID="lblMessage" runat="server" CssClass="mt-2 text-danger"></asp:Label>
            </div>

            <!-- GridView Section -->
            <div class="mt-4">
                <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" 
                    CssClass="table table-striped table-bordered" 
                    DataKeyNames="Id" 
                    OnRowDeleting="GridView1_RowDeleting" 
                    OnRowEditing="GridView1_RowEditing" 
                    OnRowUpdating="GridView1_RowUpdating"
                    OnRowCancelingEdit="GridView1_RowCancelingEdit"
                    RowDataBound="GridView1_RowDataBound">
                    <Columns>
                        
                        <asp:TemplateField HeaderText="תיאור">
                            <ItemTemplate>
                                <asp:Label ID="lblColorName" runat="server" Text='<%# Bind("ColorName") %>'></asp:Label>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditColorName" runat="server" Text='<%# Bind("ColorName") %>' CssClass="form-control"></asp:TextBox>
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="צבע">
                            <ItemTemplate>
                                  <div style="width: 30px; height: 20px; background-color: <%# GetColorCode(Eval("ColorName").ToString()) %>; border: 1px solid #000;"></div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="מחיר">
                            <ItemTemplate>
                                <asp:Label ID="lblPrice" runat="server" Text='<%# Bind("Price") %>'></asp:Label>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditPrice" runat="server" Text='<%# Bind("Price") %>' CssClass="form-control"></asp:TextBox>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="סדר">
                            <ItemTemplate>
                                <asp:Label ID="lblDisplayOrder" runat="server" Text='<%# Bind("DisplayOrder") %>'></asp:Label>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditDisplayOrder" runat="server" Text='<%# Bind("DisplayOrder") %>' CssClass="form-control"></asp:TextBox>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="במלאי">
                            <ItemTemplate>
                                <asp:CheckBox ID="chkInStock" runat="server" Checked='<%# Bind("InStock") %>' Enabled="False" />
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:CheckBox ID="chkEditInStock" runat="server" Checked='<%# Bind("InStock") %>' CssClass="form-check-input" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField>
                            <HeaderTemplate>פעולות</HeaderTemplate>
                            <ItemTemplate>
                                <div class="action-buttons">
                                    <asp:Button ID="btnEdit" runat="server" Text="✏️" CommandName="Edit" CssClass="btn btn-warning btn-sm" />
                                    <asp:Button ID="btnDelete" runat="server" Text="🗑️" CommandName="Delete" CssClass="btn btn-danger btn-sm" OnClientClick="return confirmDelete();" />
                                </div>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:Button ID="btnUpdate" runat="server" Text="שמור" CommandName="Update" CssClass="btn btn-success btn-sm" />
                                <asp:Button ID="btnCancel" runat="server" Text="ביטול" CommandName="Cancel" CssClass="btn btn-secondary btn-sm" />
                            </EditItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <!-- Form Section -->
            <div class="form-section">
                <div class="row">
                    <div class="col-md-6">
                        <label for="txtColorName" class="form-label">שם הצבע:</label>
                        <asp:TextBox ID="txtColorName" runat="server" CssClass="form-control" Placeholder="שם הצבע"></asp:TextBox>
                    </div>
                    <div class="col-md-6">
                        <label for="txtPrice" class="form-label">מחיר:</label>
                        <asp:TextBox ID="txtPrice" runat="server" CssClass="form-control" Placeholder="מחיר"></asp:TextBox>
                    </div>
                </div>
                <div class="row mt-3">
                    <div class="col-md-6">
                        <label for="txtDisplayOrder" class="form-label">סדר הצגה:</label>
                        <asp:TextBox ID="txtDisplayOrder" runat="server" CssClass="form-control" Placeholder="סדר הצגה"></asp:TextBox>
                    </div>
                    <div class="col-md-6 form-check">
                        <asp:CheckBox ID="chkInStock" runat="server" CssClass="form-check-input" />
                        <label for="chkInStock" class="form-check-label"> במלאי </label>
                    </div>
                </div>
                <div class="text-center mt-3">
                    <asp:Button ID="btnAdd" runat="server" Text="הוסף" CssClass="btn btn-primary" OnClick="btnAdd_Click" />
                </div>
            </div>
        </div>
    </form>
</body>
</html>
