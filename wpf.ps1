$inputXML = @"
<Window x:Class="WpfApp2.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApp2"
        mc:Ignorable="d"
        Title="MainWindow" Height="450" Width="800">
    <Grid>
        <ComboBox x:Name="Folders" HorizontalAlignment="Left" Height="26.159" Margin="165.991,22.075,0,0" VerticalAlignment="Top" Width="173.92"/>
        <ComboBox x:Name="Sub_Folders" HorizontalAlignment="Left" Height="26.159" Margin="165.991,67.323,0,0" VerticalAlignment="Top" Width="173.92"/>
        <ListView x:Name="Files" HorizontalAlignment="Left" Height="255.931" Margin="42.268,121.054,0,0" VerticalAlignment="Top" Width="453.181">
            <ListView.View>
                <GridView>
                    <GridViewColumn Header="Folder" DisplayMemberBinding ="{Binding 'Drive Letter'}" Width="auto"/>
                </GridView>
            </ListView.View>
        </ListView>
        <Button x:Name="Button_Exit" Content="Close" HorizontalAlignment="Left" Height="41.712" Margin="573.218,323.254,0,0" VerticalAlignment="Top" Width="128.673"/>
        <TextBlock HorizontalAlignment="Left" Height="26.159" Margin="73.634,22.075,0,0" TextWrapping="Wrap" Text="Select Folder" VerticalAlignment="Top" Width="87.357"/>
        <TextBlock HorizontalAlignment="Left" Height="23.08" Margin="73.937,70.402,0,0" TextWrapping="Wrap" Text="Select File" VerticalAlignment="Top" Width="71.264"/>
    </Grid>
</Window>
"@ 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Warning "Unable to parse XML, with error: $($Error[0])`n Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes (PowerShell cannot process them)"
    throw}
$xaml.SelectNodes("//*[@Name]") | ForEach-Object{"trying item $($_.Name)";
    try {Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop}
    catch{throw}}
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*}
Get-FormVariables
#=========================================================================
# the preceding code creates the window and parses it 
# using the x:Name= definitions with WPF prefixes as form variables
# the following code uses the WPFvariables to do the processing desired
# see foxdeploy.com for source material 
#=========================================================================

$tr_defaultfolder = "D:\"
$tr_getfolder = Get-ChildItem -Path "D:\" 
$tr_getfolder | ForEach-object {$WPFFolders.AddChild($_)}
$tr_selectedfolder = $WPFFolders.Text

$WPFButton_Exit.Add_Click({$form.Close()})

$WPFFolders.Add_SelectionChanged({
    get-childitem ($tr_defaultfolder + $WPFFolders.SelectedItem.Name) | ForEach-Object {$WPFSub_Folders.AddChild($_)}
})

$Form.ShowDialog() | out-null

Write-Host 'START OF WRITE-HOST DEBUG' -ForegroundColor Cyan
Write-Host 'tr_defaultfolder = '$tr_defaultfolder
Write-Host 'tr_getfolder = '$tr_getfolder
Write-Host 'WPFFolders.Text = '$WPFFolders.Text
Write-Host 'tr_selectedfolder = '$tr_selectedfolder
Write-Host 'Done!'
