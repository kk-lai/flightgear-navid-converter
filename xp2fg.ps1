#
# Wrote by Kevin King 9 Apr 2022
#

if ($args.Length -lt 3) {    
    Write-Host "xp2fs.ps1 <nav/fix> <xplane ip file> <fg output file>"    
    exit
}

$dtype=$args[0]
$ifile=$args[1]
$ofile=$args[2]

#$dtype="fix"
#$ifile="D:\X-Plane 11\Resources\default data\earth_fix.dat"
#$ofile="D:\Temp\fix.dat"

$stream_reader = New-Object System.IO.StreamReader($ifile)
$dstFileStream = New-Object System.IO.FileStream($ofile,([IO.FileMode]::Create),([IO.FileAccess]::Write),([IO.FileShare]::None))
$gzipStream = New-Object System.IO.Compression.GzipStream $dstFileStream, ([IO.Compression.CompressionMode]::Compress)
$stream_writer = New-Object System.IO.StreamWriter($gzipStream)
$lineNo = 1

$dataCycle=Get-Date -Format "yyyy.MM"
$build=Get-Date -Format "yyyyMMdd"

if ($dtype -eq "nav") {
    $meta="NAVXP810"
    $version="810"
} else {
    $meta="FixXP700"
    $version="600"
}

$stream_writer.WriteLine("I")
$stream_writer.WriteLine("$version Version - data cycle $dataCycle, build $build, meta $meta. Data convert from x-plane")
$stream_writer.WriteLine("")

while (-not $stream_reader.EndOfStream)
{
    $iline=$stream_reader.ReadLine()
    $lineNo++
    if (($lineNo % 1000) -eq 0) {
        Write-Host "$lineNo"    
    }
    $iline=$iline.Trim()
    if ($iline.length -gt 0) {
        $cols=-split($iline)
        if ($cols[0].equals("I")) {
            continue
        }
        if ($cols[0].equals("99")) {
            break;
        }
        if ($dtype -eq "nav") {
            $navType=[int]$cols[0]        
            if ($navType -ge 2 -and $navType -le 13) {
                $oline=""
                switch($navType) {
                    { 2,3,12,13 -contains $_ } {
                        $pattern=0,1,2,3,4,5,6,7,10
                    }
                    { 4,5 -contains $_ } {
                        # correct bearing
                        $bearing=$cols[6] -as [double]
                        $bearing=$bearing % 360.
                        $cols[6]=$bearing.toString("0.000")
                        $pattern=0,1,2,3,4,5,6,7,8,10,11
                    }
                    6 {
                        $pattern=0,1,2,3,4,5,6,7,8,10,11
                    }
                    { 7,8,9 -contains $_ } {
                        $pattern=0,1,2,3,4,5,6,7,8,10
                    }
                }
                $oline=""
                foreach($colNum in $pattern) {
                    if ($oline.length -gt 0) {
                        $oline=$oline+" "
                    }
                    $oline=$oline+ $cols[$colNum]
                    if ($pattern.indexOf($colNum) -eq $pattern.Length-1) {
                        for($j=$colNum+1;$j -lt $cols.Length;$j++) {
                            $oline=$oline+" " + $cols[$j]
                        }
                    }
                }
                $stream_writer.WriteLine($oline)
            }
            if ($navType -eq 99) {
                break
            }
        } else {
            if ($cols[0] -eq "1101") {
                continue;
            }
            $oline=""
            for($j=0;$j -lt 3;$j++) {
                if ($j -ne 0) {
                    $oline=$oline+" "
                }
                $oline=$oline+$cols[$j]
            }
            $stream_writer.WriteLine($oline)
        }

    }
}
$stream_writer.WriteLine("99")
$stream_writer.Close()
$stream_reader.Close()


