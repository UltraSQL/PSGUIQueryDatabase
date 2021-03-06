<#
==============================================================================================
  File:     GetConnInfo.ps1
  Author:   Changyong Xu
  Version:  SQL Server 2014, PowerShell V4
  Comment:  Get sql server connection info.
            Run Powershell as Administor,and execute like this:
            .\GetConnInfo.ps1
===============================================================================================
#>

# executes a query and populates the $datatable with the data
function ExecuteSqlQuery ($Server, $Database, $SQLQuery, $UserID, $Pass) {
    $Datatable = New-Object System.Data.DataTable

    $Connection = New-Object System.Data.SQLClient.SQLConnection
    $Connection.ConnectionString = "server='$Server';database='$Database';trusted_connection=true;User ID = '$UserID';Password='$Pass';"
    $Connection.Open()
    $Command = New-Object System.Data.SQLClient.SQLCommand
    $Command.Connection = $Connection
    $Command.CommandText = $SQLQuery
    $Reader = $Command.ExecuteReader()
    $Datatable.Load($Reader)
    $Connection.Close()

    return $Datatable
}

function Add-ListViewItem
{

    Param( 
    [ValidateNotNull()]
    [Parameter(Mandatory=$true)]
    [System.Windows.Forms.ListView]$ListView,
    [ValidateNotNull()]
    [Parameter(Mandatory=$true)]
    $Items,
    [int]$ImageIndex = -1,
    [string[]]$SubItems,
    [System.Windows.Forms.ListViewGroup]$Group,
    [switch]$Clear)
    
    if($Clear)
    {
        $ListView.Items.Clear();
    }
    
    if($Items -is [Array])
    {
        foreach ($item in $Items)
        {        
            $listitem  = $ListView.Items.Add($item.ToString(), $ImageIndex)
            #Store the object in the Tag
            $listitem.Tag = $item
            
            if($SubItems -ne $null)
            {
                $listitem.SubItems.AddRange($SubItems)
            }
            
            if($Group -ne $null)
            {
                $listitem.Group = $Group
            }
        }
    }
    else
    {
        #Add a new item to the ListView
        $listitem  = $ListView.Items.Add($Items.ToString(), $ImageIndex)
        #Store the object in the Tag
        $listitem.Tag = $Items
        
        if($SubItems -ne $null)
        {
            $listitem.SubItems.AddRange($SubItems)
        }
        
        if($Group -ne $null)
        {
            $listitem.Group = $Group
        }
    }
}

# Load assemlby 
Add-Type -AssemblyName System.Windows.Forms 
Add-Type -AssemblyName System.Drawing 


# Define form
$MyForm = New-Object System.Windows.Forms.Form 
$MyForm.Text="用户连接信息查询"
$MyForm.BackColor = [System.Drawing.Color]::FromArgb(255,240,240,240) 
$MyForm.Size = New-Object System.Drawing.Size(440,460) 

     
 # Define label
$mLabel1 = New-Object System.Windows.Forms.Label 
$mLabel1.Text="选择查询的实例" 
$mLabel1.Top="30" 
$mLabel1.Left="20" 
$mLabel1.Anchor="Left,Top" 
$mLabel1.Size = New-Object System.Drawing.Size(100,23) 
$MyForm.Controls.Add($mLabel1) 


# Define CheckedListBox
$mCheckedListBox1 = New-Object System.Windows.Forms.CheckedListBox
$mCheckedListBox1.Text="ComboBoX1" 
$mCheckedListBox1.Top="60" 
$mCheckedListBox1.Left="20" 
$mCheckedListBox1.Anchor="Left,Top" 
$mCheckedListBox1.Size = New-Object System.Drawing.Size(230,320)

# Create an Array for List of Properties which the user sees
 $listItems = @("Select All"
    ,"zbsz1-xxxx-db1"
    ,"zbsz1-xxxx-db2"
    ,"zbbj1-xxxx-db1\zhdbzb"
    ,"xxxxdb\xxxx"
    ,"zbsz1-yyyy-db3\yyyybak"
    ,"zbbj1-yyyy-db1\yyyyzb"
    ,"zbsz1-yyyy-his\yyyyhis"
    ,"zbsz1-yyyy-hisb\yyyyhisbak"
    ,"zbbj1-yyyy-his\yyyyhiszb"
    ,"zzzzdb\zzzz"
    ,"zbsz1-mmmm-db3\mmmmbak"
    ,"zbbj1-mmmm-db1\mmmmzb"
    ,"zbsz1-mmmm-his\mmmmhis"
    ,"zbsz1-mmmm-hisb\mmmmhisbak"
    ,"zbbj1-mmmm-his\mmmmhiszb"
    ,"nnnndb\nnnn"
    ,"zbsz1-rrrr-db3"
    ,"zbbj1-rrrr-db1\rrrr"
 )


# Loading items
$listItems | ForEach-Object { $mCheckedListBox1.Items.Add($_) }
$mCheckedListBox1.ClearSelected()
$mCheckedListBox1.Add_click({
    If($this.selecteditem -eq 'Select All'){
        If ($mCheckedListBox1.checkeditems[0] -eq "Select All"){$checked=$false}Else{$checked=$true}
        For($i=1;$i -lt $mCheckedListBox1.Items.Count; $i++){
            $mCheckedListBox1.SetItemChecked($i,$checked)
        }
    }
})

Foreach ($Item In $listItems) 
{
    $mCheckedListBox1.SetItemChecked($mCheckedListBox1.Items.IndexOf($Item), $true);
}

$MyForm.Controls.Add($mCheckedListBox1) 

         
# Define label
$mLabel2 = New-Object System.Windows.Forms.Label 
$mLabel2.Text="输入查询的用户" 
$mLabel2.Top="30" 
$mLabel2.Left="290" 
$mLabel2.Anchor="Left,Top" 
$mLabel2.Size = New-Object System.Drawing.Size(100,23) 
$MyForm.Controls.Add($mLabel2) 
         
# Define textBox for input
$mTextBox1 = New-Object System.Windows.Forms.TextBox 
$mTextBox1.Text="jzuser" 
$mTextBox1.Top="60" 
$mTextBox1.Left="290" 
$mTextBox1.Anchor="Left,Top" 
$mTextBox1.Size = New-Object System.Drawing.Size(100,23) 
$MyForm.Controls.Add($mTextBox1) 
         
# Define query button
$mButton1 = New-Object System.Windows.Forms.Button 
$mButton1.Text="查询" 
$mButton1.Top="180" 
$mButton1.Left="290" 
$mButton1.Anchor="Left,Top" 
$mButton1.Size = New-Object System.Drawing.Size(100,23)

# Define button event handler
$eventHandlerQuery = [System.EventHandler]{
    $UserName = $mTextBox1.Text
    $total = @()
    Foreach($Server In $mCheckedListBox1.checkeditems)
    {
        If($Server -ne "Select All")
        {
            Try
            {
                [string] $Database = "master"
                [string] $UserSqlQuery= $("SELECT '$($Server)' AS InstanceName
                                        ,a.client_net_address AS ApplicationIP
                                        ,COUNT(*) AS CurrentConnections
                                    FROM sys.dm_exec_connections a
                                        INNER JOIN sys.dm_exec_sessions b
                                            ON a.session_id = b.session_id
                                    WHERE b.login_name = '$($UserName)'
                                    GROUP BY a.client_net_address
                                    ORDER BY a.client_net_address")
                [string] $UserID = "ConnView"
                [string] $Pass = "xxxxxx"
                $resultsDataTable = New-Object System.Data.DataTable
                $resultsDataTable = ExecuteSqlQuery $Server $Database $UserSqlQuery $UserId $Pass
            }
            Catch
            {
                $Error = $_.Exception.Message
                [Windows.Forms.MessageBox]::Show($($Error), "Connect $($item) Error" , [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
            }
        }
        $total += $resultsDataTable
    }

    Write-Host $total
    $rstFrom = New-Object System.Windows.Forms.Form
    $rstFrom.Text="查询结果"
    $rstFrom.Width = 425
    $rstFrom.Height = 465

    $listView = New-Object System.Windows.Forms.ListView
    $listView.View = 'Details'
    $listView.Width = 425
    $listView.Height = 465

    $listView.Columns.Add('InstanceName')
    $listView.Columns.Add('ApplicationIP')
    $listView.Columns.Add('CurrentConnections')

    $listView.Columns[0].Width = 160
    $listView.Columns[1].Width = 130
    $listView.Columns[2].Width = 130

    Foreach($resulttable In $total)
    {
        Foreach ($line In $resulttable) {
        $item = New-Object System.Windows.Forms.ListViewItem($line.InstanceName)
        $item.SubItems.Add($line.ApplicationIP)
        $item.SubItems.Add($line.CurrentConnections)
        $listView.Items.Add($item)
        }
    }

    $rstFrom.Controls.Add($listView)
    [void] $rstFrom.ShowDialog()

}

$mButton1.Add_click($eventHandlerQuery)
$MyForm.Controls.Add($mButton1) 


# Define close button
$mButton2 = New-Object System.Windows.Forms.Button 
$mButton2.Text="关闭" 
$mButton2.Top="250" 
$mButton2.Left="290" 
$mButton2.Anchor="Left,Top" 
$mButton2.Size = New-Object System.Drawing.Size(100,23)
$eventHandlerClose = [System.EventHandler]{
    $MyForm.close()
}
$mButton2.Add_click($eventHandlerClose)
$MyForm.Controls.Add($mButton2)


# Show form      
[void] $MyForm.ShowDialog()
