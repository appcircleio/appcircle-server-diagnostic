
# Appcircle _Server Diagnostic_ Component

You can use the Server Diagnostic component to diagnose the upload speed and server timeout for Appcircle server and runner communication. It is only available in **self-hosted** deployments.

It performs the following steps:

1. Creates a dummy file with the specified size in megabytes (MB).
2. Uploads the dummy file to a temporary location to test the upload speed.
3. Sends a test request to the build server API to detect whether the server times out for the specified timeout input in minutes.

## Required Inputs

To use the Server Diagnostic component, provide the following inputs:

- `AC_DIAGNOSTIC_UPLOAD_FILE_SIZE_MB`: Specifies the size of the file to be uploaded in MB. Available options are 1, 5, 10, 15, 20, 30, 50, 100, 250, 500, and 1000 MB. The default value selected is 5 MB.
- `AC_DIAGNOSTIC_SERVER_TIMEOUT_MINUTES`: Specifies the timeout value in minutes to test server timeouts. Available options are 1, 5, 10, 15, 20, and 30 minutes. The default value selected is 1 minute.
