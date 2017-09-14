Configuration WebServer
{
  Node Web01
  {
    #Install the IIS Role
    WindowsFeature IIS
    {
      Ensure = "Present"
      Name = "Web-Server"
    }

    WindowsFeature WebServerManagementConsole
    {
        Name = "Web-Mgmt-Console"
        Ensure = "Present"
    }

    Script GetHtml
    {
      SetScript = 
      {
        $webclient = New-Object System.Net.WebClient
        $webclient.DownloadFile("https://raw.githubusercontent.com/shawnweisfeld/IaaS-High-Availability-Lab/master/Web01/iisstart.htm","C:\inetpub\wwwroot\iisstart.htm")
      }

      TestScript = { $false }
      GetScript = { @{ Result = (Get-Content C:\inetpub\wwwroot\iisstart.htm) } }            

    }
  }
}