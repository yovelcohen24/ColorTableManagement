Imports System.Data.SqlClient
Imports System.Web.Services

Public Class WebForm1
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
        If Not IsPostBack Then
            BindGridView()
        End If
    End Sub

    ' Function to bind the GridView with data from the database
    Protected Sub BindGridView()
        Dim connString As String = ConfigurationManager.ConnectionStrings("ColorsDB").ConnectionString
        Using conn As New SqlConnection(connString)
            Dim query As String = "SELECT * FROM Colors ORDER BY DisplayOrder"
            Dim cmd As New SqlCommand(query, conn)
            Dim adapter As New SqlDataAdapter(cmd)
            Dim dt As New DataTable()
            adapter.Fill(dt)
            GridView1.DataSource = dt
            GridView1.DataBind()
        End Using
    End Sub

    ' Adding a new record to the database
    Protected Sub btnAdd_Click(sender As Object, e As EventArgs)
        ' Validate user input
        If String.IsNullOrWhiteSpace(txtColorName.Text) OrElse String.IsNullOrWhiteSpace(txtPrice.Text) OrElse String.IsNullOrWhiteSpace(txtDisplayOrder.Text) Then
            lblMessage.Text = "All fields are required."
            lblMessage.CssClass = "text-danger"
            Return
        End If

        Try
            Dim connString As String = ConfigurationManager.ConnectionStrings("ColorsDB").ConnectionString
            Using conn As New SqlConnection(connString)
                Dim query As String = "INSERT INTO Colors (ColorName, Price, DisplayOrder, InStock) VALUES (@ColorName, @Price, @DisplayOrder, @InStock)"
                Dim cmd As New SqlCommand(query, conn)
                cmd.Parameters.AddWithValue("@ColorName", txtColorName.Text)
                cmd.Parameters.AddWithValue("@Price", Convert.ToDecimal(txtPrice.Text))
                cmd.Parameters.AddWithValue("@DisplayOrder", Convert.ToInt32(txtDisplayOrder.Text))
                cmd.Parameters.AddWithValue("@InStock", chkInStock.Checked)
                conn.Open()
                cmd.ExecuteNonQuery()
            End Using
            lblMessage.Text = "Color added successfully!"
            lblMessage.CssClass = "text-success"
        Catch ex As Exception
            lblMessage.Text = "Error: " & ex.Message
            lblMessage.CssClass = "text-danger"
        End Try

        BindGridView()
    End Sub

    ' Deleting a record from the database
    Protected Sub GridView1_RowDeleting(sender As Object, e As GridViewDeleteEventArgs)
        Dim id As Integer = Convert.ToInt32(GridView1.DataKeys(e.RowIndex).Value)
        Dim connString As String = ConfigurationManager.ConnectionStrings("ColorsDB").ConnectionString
        Try
            Using conn As New SqlConnection(connString)
                Dim query As String = "DELETE FROM Colors WHERE Id = @Id"
                Dim cmd As New SqlCommand(query, conn)
                cmd.Parameters.AddWithValue("@Id", id)
                conn.Open()
                cmd.ExecuteNonQuery()
            End Using
            lblMessage.Text = "Record deleted successfully."
            lblMessage.CssClass = "text-success"
        Catch ex As Exception
            lblMessage.Text = "Error deleting record: " & ex.Message
            lblMessage.CssClass = "text-danger"
        End Try

        BindGridView()
    End Sub

    ' Editing a record in the GridView
    Protected Sub GridView1_RowEditing(sender As Object, e As GridViewEditEventArgs)
        GridView1.EditIndex = e.NewEditIndex
        BindGridView()
    End Sub

    ' Canceling the edit operation
    Protected Sub GridView1_RowCancelingEdit(sender As Object, e As GridViewCancelEditEventArgs)
        GridView1.EditIndex = -1
        BindGridView()
    End Sub

    ' Updating a record in the database
    Protected Sub GridView1_RowUpdating(sender As Object, e As GridViewUpdateEventArgs)
        Try
            ' Get the ID of the record being edited
            Dim id As Integer = Convert.ToInt32(GridView1.DataKeys(e.RowIndex).Value)

            ' Get the row being edited
            Dim row As GridViewRow = GridView1.Rows(e.RowIndex)

            ' Retrieve data from fields in the row
            Dim colorName As String = CType(row.FindControl("txtEditColorName"), TextBox).Text
            Dim price As Decimal = Convert.ToDecimal(CType(row.FindControl("txtEditPrice"), TextBox).Text)
            Dim displayOrder As Integer = Convert.ToInt32(CType(row.FindControl("txtEditDisplayOrder"), TextBox).Text)
            Dim inStock As Boolean = CType(row.FindControl("chkEditInStock"), CheckBox).Checked

            ' Update the database
            Dim connString As String = ConfigurationManager.ConnectionStrings("ColorsDB").ConnectionString
            Using conn As New SqlConnection(connString)
                Dim query As String = "UPDATE Colors SET ColorName = @ColorName, Price = @Price, DisplayOrder = @DisplayOrder, InStock = @InStock WHERE Id = @Id"
                Dim cmd As New SqlCommand(query, conn)
                cmd.Parameters.AddWithValue("@ColorName", colorName)
                cmd.Parameters.AddWithValue("@Price", price)
                cmd.Parameters.AddWithValue("@DisplayOrder", displayOrder)
                cmd.Parameters.AddWithValue("@InStock", inStock)
                cmd.Parameters.AddWithValue("@Id", id)
                conn.Open()
                cmd.ExecuteNonQuery()
            End Using

            lblMessage.Text = "Record updated successfully."
            lblMessage.CssClass = "text-success"
        Catch ex As Exception
            lblMessage.Text = "Error updating record: " & ex.Message
            lblMessage.CssClass = "text-danger"
        End Try

        ' Exit edit mode and refresh the GridView
        GridView1.EditIndex = -1
        BindGridView()
    End Sub

    ' WebMethod for updating the order after drag-and-drop
    <WebMethod()>
    Public Shared Sub UpdateOrder(sortedIDs As List(Of Integer))
        Dim connString As String = ConfigurationManager.ConnectionStrings("ColorsDB").ConnectionString
        Using conn As New SqlConnection(connString)
            conn.Open()
            For i As Integer = 0 To sortedIDs.Count - 1
                Dim query As String = "UPDATE Colors SET DisplayOrder = @DisplayOrder WHERE Id = @Id"
                Using cmd As New SqlCommand(query, conn)
                    cmd.Parameters.AddWithValue("@DisplayOrder", i + 1)
                    cmd.Parameters.AddWithValue("@Id", sortedIDs(i))
                    cmd.ExecuteNonQuery()
                End Using
            Next
        End Using
    End Sub

    Public Function GetColorCode(colorName As String) As String
        Select Case colorName
            Case "אדום"
                Return "#FF0000"
            Case "ירוק"
                Return "#00FF00"
            Case "כחול"
                Return "#0000FF"
            Case "צהוב"
                Return "#FFFF00"
            Case "ורוד"
                Return "#FFC0CB"
            Case "כתום"
                Return "#FFA500"
            Case "סגול"
                Return "#800080"
            Case "שחור"
                Return "#000000"
            Case "לבן"
                Return "#FFFFFF"
            Case "אפור"
                Return "#808080"
            Case Else
                Return "#ffffff"
        End Select
    End Function


End Class
