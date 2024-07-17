# CertVault

## Purpose

The purpose of this project is to codify working with openssl to create self signed certificates for testing and development.  The certificates created here should never be installed in a production environment, nor should the certificate chains be use for anything other than testing.

### Warning

Many of the command files here have a password hard coded.  This is highly unsecure and makes any certificat created vulnerable to an attack.  **These scripts are provided simply as a tool for use in a development environment** You will need to submit a CSR
(Certificate Signing Request) to an appropriate CA (Certificate Authority) to get production ready secure certificates.

## Usage

Several command scripts for windows is provided in the bin/windows directory.  To use these scripts make the home directory of this project your current working directory:

    D:\> cd \depot\certvault
    D:\depot\certvault> .\bin\windows\create-root-ca.bat myrootca

On my D: disk is a folder called depot which contains, among other projects, is the git repository for certvault.

### Create Root

To create a root certificate run the create-root-ca.bat script.  The script takes one parameter which is the name you wish to use for your root CA.

## Versions

|Tool          |Version     |Vendor/Supplier           |
|--------------|------------|--------------------------|
|openssl       |3.0.1.14    |[Shining Light Productions](https://slproweb.com/products/Win32OpenSSL.html) |
|dos2unix      |7.4.2-win64 |[Source Forge](https://dos2unix.sourceforge.io/) |

