

# Appcircle Server Diagnostic Component

The Server Diagnostic Component is responsible for diagnosing the upload speed and server timeout. It is only available in SELF-HOSTED deployments. 
It performs the following steps:

1. Creates a dummy file with the specified size in megabytes (MB).
2. Uploads the dummy file to a temporary location to test the upload speed.
3. Sends a test request to the build server API to detect whether the server times out for the specified timeout input in minutes.

 ## Required Inputs

To use the Server Diagnostic Component, provide the following inputs:

- `AC_DIAGNOSTIC_UPLOAD_FILE_SIZE_MB`: Specifies the size of the file to be uploaded in MB. Available options: 1, 5, 10, 15, 20, 30, 50, 100, 250, 500, 1000. Default value: 5.
- `AC_DIAGNOSTIC_SERVER_TIMEOUT_MINUTES`: Specifies the timeout value in minutes to test server timeouts. Available options: 1, 5, 10, 15, 20. Default value: 1.

