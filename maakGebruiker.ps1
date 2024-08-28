# Vaste gegevens
$pad = "gebruiker.txt"
$domein = "@domein.nl"
$basisOU = "OU=,OU=,OU=,DC=,DC="
$wachtwoord = "test"
$department = "test"

# Gegevens ophalen uit .txt bestand
$gebruikersGegevens = Import-Csv -Path $pad

function PakLocatie{ 
    param($locatie)

    if ($locatie -match '^Haa|^haa'){
        return "OU=Locatie Haarlem,"+$basisOU 
    }
    elseif ($locatie -match '^Lei|^lei') {
        return "OU=Locatie Leiden,"+$basisOU
    }
    elseif ($locatie -match '^Hee|^hee') {
        return "OU=Locatie Heerhugowaard,"+$basisOU
    }
    else{
        default { return $basisOU }
    }
}

ForEach ($gebruiker in $gebruikersGegevens){
    # Pak de eerste letter uit de voornaam
    $eersteLetter = $gebruiker.voornaam.ToCharArray().Get(0)

    #Schrijf gegevens naar de terminal
    Write-Host "Beginnen met het maken van account"
    Write-Host "Voornaam:"$gebruiker.voornaam
    Write-Host "Achternaam:"$gebruiker.achternaam
    Write-Host "Email:"($eersteletter+"."+($gebruiker.achternaam -replace '\s','')+$domein).ToLower()
    Write-Host "Department:"$department
    Write-Host "Plaatsen in OU:"(PakLocatie($gebruiker.locatie))
    Write-Host "- - - - - - - -"

    # Maak gegevens klaar voor New-ADUser
    $gebruikerDetails = @{
        GivenName = $gebruiker.voornaam
        Surname = $gebruiker.achternaam
        DisplayName = $gebruiker.voornaam + " " + $gebruiker.achternaam
        Name = $gebruiker.voornaam + " " + $gebruiker.achternaam
        EmailAddres = ($eersteletter+"."+($gebruiker.achternaam -replace '\s','')+$domein).ToLower()
        UserPrincipalName = ($eersteletter+"."+($gebruiker.achternaam -replace '\s','')+$domein).ToLower()
        SamAccountName = ($eersteletter+"."+($gebruiker.achternaam -replace '\s','')).ToLower()
        Department = $department
        Path = PakLocatie($gebruiker.locatie)
        AccountPassword = (ConvertTo-SecureString -AsPlainText $wachtwoord -Force)
        ChangePasswordAtLogon  = $true
        Enabled = $true
    }

    # Maak de gebruiker
    New-ADUser @gebruikerDetails
}