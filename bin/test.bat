SET INTERMEDIATE_DIR=/depot/certvault/ThreeRingCircus/ImageServer
SET SERVER_NAME=localhost1

CALL openssl ca -config %INTERMEDIATE_DIR%/openssl.cnf -extensions dual_cert ^
    -passin pass:redrover -days 3650 -notext -md sha256 -in %INTERMEDIATE_DIR%/csr/%SERVER_NAME%.csr.pem ^
    -out %INTERMEDIATE_DIR%/certs/%SERVER_NAME%.cert.pem
