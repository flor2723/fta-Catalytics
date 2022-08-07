param(
    [string]$keyVaultname,
    [string]$keyVaultSecretnameSqlConnString,
    [string]$scriptPath

)
# Installing the SQLServer Module

if (!(Get-Module -Name SQLServer)){
    Write-Output "Installing the SQL Server Module"
    Install-Module -Name SQLServer
    Import-Module SQLServer
}

else{
Write-Output "SQL Server Module is present"
}


# Get the secret of the sql server Module
$sqldbConnString = Get-AzKeyVaultSecret -VaultName $keyVaultname -Name $keyVaultSecretnameSqlConnStringb -AsPlainText

# Run the Scripts
Invoke-SqlCmd -ConnectionString $sqldbConnString  -InputFile $scriptPath