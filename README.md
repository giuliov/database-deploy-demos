# Database Deploy demo code

## Migration-based: DbUp

The first attemp should raise an error
```ps1
pushd dbup-sample
osql -E -S '(localdb)\ProjectsV13' -d "dbup-sample" -i demo/reset.sql
./PowerShell/upgrade.ps1 -DatabaseName 'dbup-sample'  -DatabaseServer '(localdb)\ProjectsV13'
```

Now swap the order
```ps1
ren '0003 - devB.sql' temp.sql
ren '0004 - devA.sql' '0003 - devA.sql'
ren temp.sql '0004 - devB.sql'
```

No error this time, but the result is wrong.
```ps1
dotnet run --project Csharp/dbup-sample.csproj "Server=(localdb)\ProjectsV13;Database=dbup-sample;Trusted_connection=true;Connect Timeout=10;"
# and revert back
ren '0004 - devB.sql' temp.sql
ren '0003 - devA.sql' '0004 - devA.sql'
ren temp.sql '0003 - devB.sql'
popd
```

## State-based: SQL Server dacpac

```ps1
Set-Alias sqlpackage 'C:\Program Files\Microsoft SQL Server\150\DAC\bin\sqlpackage.exe'

pushd dacpac-sample

osql -E -S '(localdb)\ProjectsV13' -Q "DROP DATABASE [dacpac-sample]"
msbuild dacpac-sample.sqlproj
sqlpackage  /Action:Publish  /SourceFile:bin/Debug/dacpac-sample.dacpac  /Profile:dacpac-sample.publish.xml
```

Change line 4 of `table_foobar.sql` to

`    [baz] NVARCHAR(MAX) NULL`


```ps1
msbuild dacpac-sample.sqlproj
# show the planned change (can be a step in a pipeline followed by a manual review)
sqlpackage  /Action:Script  /SourceFile:bin/Debug/dacpac-sample.dacpac  /Profile:dacpac-sample.publish.xml  /DeployScriptPath:changes.sql
# apply the change
sqlpackage  /Action:Publish  /SourceFile:bin/Debug/dacpac-sample.dacpac  /Profile:dacpac-sample.publish.xml

popd
```