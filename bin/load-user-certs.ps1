# Example running 
# .\load-user-certs.ps1
# Example output 
# 
# PSParentPath: Microsoft.PowerShell.Security\Certificate::CurrentUser\Root
# 
# Thumbprint                                Subject
# ----------                                -------
# AEAA36F087732F06A33F92A31D59881C0CD145D7  CN=NGF Root CA, OU=NextGen Federal Systems, O=NextGenFed, L=Morgantown, S=...
# 
# 
#    PSParentPath: Microsoft.PowerShell.Security\Certificate::CurrentUser\CA
# 
# Thumbprint                                Subject
# ----------                                -------
# 213EEB71997E89BEE28B7F8E3CC1D8C1DC272C4C  CN=GLADS, OU=GLADS, O=NextGenFed, S=WV, C=US
# 
# 
#    PSParentPath: Microsoft.PowerShell.Security\Certificate::CurrentUser\My
# 
# Thumbprint                                Subject
# ----------                                -------
# 9F1A626C135131FC4210E37CD41CB3C72C3BEAC8  CN=glads.manager.2020123456, OU=GLADS, O=NextGenFed, L=Morgantown, S=WV, C=US
# D6C65A39EBD58D4212098F0F8DA25F4E3CD5B8B7  CN=glads.mutli.2020000104, OU=GLADS, O=NextGenFed, L=Morgantown, S=WV, C=US
# 5B1B9E775F1997B5A1FFF43A9CFD00F652E535F0  CN=glads.operator.2020000102, OU=GLADS, O=NextGenFed, L=Morgantown, S=WV, ...
# E8B458ACA23CDA2179A72EDFD0066B461428B976  CN=glads.supervisor.2020000101, OU=GLADS, O=NextGenFed, L=Morgantown, S=WV...
# D6C65A39EBD58D4212098F0F8DA25F4E3CD5B8B7  CN=glads.mutli.2020000104, OU=GLADS, O=NextGenFed, L=Morgantown, S=WV, C=US
# 47B3C4997B06FFEE4E12A369FB9C6013E176FDB0  CN=glads.viewer.2020000103, OU=GLADS, O=NextGenFed, L=Morgantown, S=WV, C=US

Import-Certificate -FilePath ..\NGFRootCA\certs\NGFRootCA.cert.pem -CertStoreLocation cert:\CurrentUser\Root
Import-Certificate -FilePath ..\NGFRootCA\GLADS-Intermediate\certs\GLADS-Intermediate.cert.pem -CertStoreLocation cert:\CurrentUser\CA
$pfxPassword = "redrover" | ConvertTo-SecureString -AsPlainText -Force
Import-PfxCertificate -Exportable -Password $pfxPassword -CertStoreLocation Cert:\CurrentUser\My -FilePath ..\NGFRootCA\GLADS-Intermediate\certs\glads.manager.2020123456.pfx
Import-PfxCertificate -Exportable -Password $pfxPassword -CertStoreLocation Cert:\CurrentUser\My -FilePath ..\NGFRootCA\GLADS-Intermediate\certs\glads.multi.2020000104.pfx
Import-PfxCertificate -Exportable -Password $pfxPassword -CertStoreLocation Cert:\CurrentUser\My -FilePath ..\NGFRootCA\GLADS-Intermediate\certs\glads.operator.2020000102.pfx
Import-PfxCertificate -Exportable -Password $pfxPassword -CertStoreLocation Cert:\CurrentUser\My -FilePath ..\NGFRootCA\GLADS-Intermediate\certs\glads.supervisor.2020000101.pfx
Import-PfxCertificate -Exportable -Password $pfxPassword -CertStoreLocation Cert:\CurrentUser\My -FilePath ..\NGFRootCA\GLADS-Intermediate\certs\glads.multi.2020000104.pfx
Import-PfxCertificate -Exportable -Password $pfxPassword -CertStoreLocation Cert:\CurrentUser\My -FilePath ..\NGFRootCA\GLADS-Intermediate\certs\glads.viewer.2020000103.pfx