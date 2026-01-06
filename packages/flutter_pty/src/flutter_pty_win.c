#include <stdio.h>
#include <Windows.h>

#include "flutter_pty.h"

#include "include/dart_api.h"
#include "include/dart_api_dl.h"
#include "include/dart_native_api.h"

/**
 * Convert UTF-8 string to Wide Character (UTF-16) string.
 * Uses Windows API MultiByteToWideChar for correct multi-byte handling.
 * Caller is responsible for freeing the returned string.
 */
static LPWSTR utf8_to_wide(const char *utf8_str)
{
    if (utf8_str == NULL)
        return NULL;

    // Get required buffer size (including null terminator)
    int wide_len = MultiByteToWideChar(CP_UTF8, 0, utf8_str, -1, NULL, 0);
    if (wide_len == 0)
        return NULL;

    LPWSTR wide_str = malloc(wide_len * sizeof(WCHAR));
    if (wide_str == NULL)
        return NULL;

    // Perform the conversion
    if (MultiByteToWideChar(CP_UTF8, 0, utf8_str, -1, wide_str, wide_len) == 0)
    {
        free(wide_str);
        return NULL;
    }

    return wide_str;
}

static int extra_for_quotes(char *s)
{
    if (s == NULL)
        return 0;
    int len = (int)strlen(s);
    int extra = 2; // for the surrounding quotes
    for (int i = 0; i < len; i++)
    {
        if (s[i] == '"')
            extra++; // escape double quotes
    }
    return extra;
}

static LPWSTR build_command(char *executable, char **arguments)
{
    // Calculate total length needed for the UTF-8 command string
    int command_length = 0;

    // If arguments is provided, we assume arguments[0] is the executable name
    // (as seen in flutter_pty.dart setup) and we just join all arguments.
    if (arguments != NULL && arguments[0] != NULL)
    {
        int i = 0;
        while (arguments[i] != NULL)
        {
            command_length += (int)strlen(arguments[i]) + extra_for_quotes(arguments[i]) + 1;
            i++;
        }

        // Build command in UTF-8 first
        char *command_utf8 = malloc(command_length + 1);
        if (command_utf8 == NULL)
            return NULL;

        int pos = 0;
        int j = 0;
        while (arguments[j] != NULL)
        {
            if (j > 0)
                command_utf8[pos++] = ' ';

            command_utf8[pos++] = '"';
            int k = 0;
            while (arguments[j][k] != 0)
            {
                if (arguments[j][k] == '"')
                    command_utf8[pos++] = '\\';
                command_utf8[pos++] = arguments[j][k++];
            }
            command_utf8[pos++] = '"';
            j++;
        }
        command_utf8[pos] = 0;

        // Convert to wide string using proper UTF-8 handling
        LPWSTR command = utf8_to_wide(command_utf8);
        free(command_utf8);
        return command;
    }
    else if (executable != NULL)
    {
        command_length = (int)strlen(executable) + extra_for_quotes(executable);
        
        // Build command in UTF-8 first
        char *command_utf8 = malloc(command_length + 1);
        if (command_utf8 == NULL)
            return NULL;

        int pos = 0;
        command_utf8[pos++] = '"';
        int j = 0;
        while (executable[j] != 0)
        {
            if (executable[j] == '"')
                command_utf8[pos++] = '\\';
            command_utf8[pos++] = executable[j++];
        }
        command_utf8[pos++] = '"';
        command_utf8[pos] = 0;

        // Convert to wide string using proper UTF-8 handling
        LPWSTR command = utf8_to_wide(command_utf8);
        free(command_utf8);
        return command;
    }

    return NULL;
}

static LPWSTR build_environment(char **environment)
{
    if (environment == NULL)
        return NULL;

    // First pass: calculate total wide character length needed
    int total_wide_len = 0;
    int i = 0;
    while (environment[i] != NULL)
    {
        // Get wide char length for each environment variable
        int wide_len = MultiByteToWideChar(CP_UTF8, 0, environment[i], -1, NULL, 0);
        if (wide_len > 0)
            total_wide_len += wide_len; // includes null terminator for each
        i++;
    }

    if (total_wide_len == 0)
        return NULL;

    // Allocate environment block (+1 for final double-null terminator)
    LPWSTR environment_block = malloc((total_wide_len + 1) * sizeof(WCHAR));
    if (environment_block == NULL)
        return NULL;

    // Second pass: convert and copy each environment variable
    int pos = 0;
    i = 0;
    while (environment[i] != NULL)
    {
        // Calculate remaining space in the buffer
        int remaining = total_wide_len + 1 - pos;
        if (remaining <= 0) break;

        int converted = MultiByteToWideChar(CP_UTF8, 0, environment[i], -1, 
                                             &environment_block[pos], remaining);
        if (converted > 0)
        {
            pos += converted; // includes null terminator
        }
        else
        {
            // If conversion fails, something is wrong with the input.
            // But we must ensure the block remains valid (null terminated).
            // For now, we skip this entry, but stay safe.
        }
        i++;
    }

    // Add final null terminator for double-null terminated block
    if (pos <= total_wide_len)
    {
        environment_block[pos] = 0;
    }
    else
    {
        // Should not happen, but for absolute safety
        environment_block[total_wide_len] = 0;
    }

    return environment_block;
}

static LPWSTR build_working_directory(char *working_directory)
{
    // Use utf8_to_wide for proper UTF-8 to Wide Char conversion
    return utf8_to_wide(working_directory);
}

typedef struct ReadLoopOptions
{
    HANDLE fd;

    Dart_Port port;

    HANDLE hMutex;

    BOOL ackRead;

} ReadLoopOptions;

static DWORD WINAPI read_loop(LPVOID arg)
{
    ReadLoopOptions *options = (ReadLoopOptions *)arg;

    char buffer[1024];

    while (1)
    {
        DWORD readlen = 0;

        if (options->ackRead)
        {
            WaitForSingleObject(options->hMutex, INFINITE);
        }

        BOOL ok = ReadFile(options->fd, buffer, sizeof(buffer), &readlen, NULL);

        if (!ok)
        {
            break;
        }

        if (readlen <= 0)
        {
            break;
        }

        Dart_CObject result;
        result.type = Dart_CObject_kTypedData;
        result.value.as_typed_data.type = Dart_TypedData_kUint8;
        result.value.as_typed_data.length = readlen;
        result.value.as_typed_data.values = (uint8_t *)buffer;

        Dart_PostCObject_DL(options->port, &result);
    }

    return 0;
}

static void start_read_thread(HANDLE fd, Dart_Port port, HANDLE mutex, BOOL ackRead)
{
    ReadLoopOptions *options = malloc(sizeof(ReadLoopOptions));

    options->fd = fd;
    options->port = port;
    options->hMutex = mutex;
    options->ackRead = ackRead;

    DWORD thread_id;

    HANDLE thread = CreateThread(NULL, 0, read_loop, options, 0, &thread_id);

    if (thread == NULL)
    {
        free(options);
    }
}

typedef struct WaitExitOptions
{
    HANDLE pid;

    Dart_Port port;

    HANDLE hMutex;
} WaitExitOptions;

static DWORD WINAPI wait_exit_thread(LPVOID arg)
{
    WaitExitOptions *options = (WaitExitOptions *)arg;

    DWORD exit_code = 0;

    WaitForSingleObject(options->pid, INFINITE);

    GetExitCodeProcess(options->pid, &exit_code);

    CloseHandle(options->pid);
    CloseHandle(options->hMutex);

    Dart_PostInteger_DL(options->port, exit_code);

    return 0;
}

static void start_wait_exit_thread(HANDLE pid, Dart_Port port, HANDLE mutex)
{
    WaitExitOptions *options = malloc(sizeof(WaitExitOptions));

    options->pid = pid;
    options->port = port;
    options->hMutex = mutex;

    DWORD thread_id;

    HANDLE thread = CreateThread(NULL, 0, wait_exit_thread, options, 0, &thread_id);

    if (thread == NULL)
    {
        free(options);
    }
}

typedef struct PtyHandle
{
    PHANDLE inputWriteSide;

    PHANDLE outputReadSide;

    HPCON hPty;

    DWORD dwProcessId;

    BOOL ackRead;

    HANDLE hMutex;

} PtyHandle;

char *error_message = NULL;

FFI_PLUGIN_EXPORT PtyHandle *pty_create(PtyOptions *options)
{
    HANDLE inputReadSide = NULL;
    HANDLE inputWriteSide = NULL;

    HANDLE outputReadSide = NULL;
    HANDLE outputWriteSide = NULL;

    if (!CreatePipe(&inputReadSide, &inputWriteSide, NULL, 0))
    {
        error_message = "Failed to create input pipe";
        return NULL;
    }

    if (!CreatePipe(&outputReadSide, &outputWriteSide, NULL, 0))
    {
        error_message = "Failed to create output pipe";
        return NULL;
    }

    COORD size;

    size.X = options->cols;
    size.Y = options->rows;

    HPCON hPty;

    HRESULT result = CreatePseudoConsole(size, inputReadSide, outputWriteSide, 0, &hPty);

    if (FAILED(result))
    {
        error_message = "Failed to create pseudo console";
        return NULL;
    }

    STARTUPINFOEX startupInfo;

    ZeroMemory(&startupInfo, sizeof(startupInfo));
    startupInfo.StartupInfo.cb = sizeof(startupInfo);

    startupInfo.StartupInfo.dwFlags = STARTF_USESTDHANDLES;
    startupInfo.StartupInfo.hStdInput = NULL;
    startupInfo.StartupInfo.hStdOutput = NULL;
    startupInfo.StartupInfo.hStdError = NULL;

    SIZE_T bytesRequired;
    InitializeProcThreadAttributeList(NULL, 1, 0, &bytesRequired);
    startupInfo.lpAttributeList = (PPROC_THREAD_ATTRIBUTE_LIST)malloc(bytesRequired);

    BOOL ok = InitializeProcThreadAttributeList(startupInfo.lpAttributeList, 1, 0, &bytesRequired);

    if (!ok)
    {
        error_message = "Failed to initialize proc thread attribute list";
        return NULL;
    }

    ok = UpdateProcThreadAttribute(startupInfo.lpAttributeList,
                                   0,
                                   PROC_THREAD_ATTRIBUTE_PSEUDOCONSOLE,
                                   hPty,
                                   sizeof(hPty),
                                   NULL,
                                   NULL);

    if (!ok)
    {
        error_message = "Failed to update proc thread attribute list";
        return NULL;
    }

    LPWSTR command = build_command(options->executable, options->arguments);

    LPWSTR environment_block = build_environment(options->environment);

    LPWSTR working_directory = build_working_directory(options->working_directory);

    PROCESS_INFORMATION processInfo;
    ZeroMemory(&processInfo, sizeof(processInfo));

    Sleep(1000);

    ok = CreateProcessW(NULL,
                        command,
                        NULL,
                        NULL,
                        FALSE,
                        EXTENDED_STARTUPINFO_PRESENT | CREATE_UNICODE_ENVIRONMENT,
                        environment_block,
                        working_directory,
                        &startupInfo.StartupInfo,
                        &processInfo);

    if (command != NULL)
    {
        free(command);
    }

    if (environment_block != NULL)
    {
        free(environment_block);
    }

    if (working_directory != NULL)
    {
        free(working_directory);
    }

    if (!ok)
    {
        error_message = "Failed to create process";
        DWORD error = GetLastError();
        printf("error no: %d\n", error);
        return NULL;
    }

    // free(startupInfo.lpAttributeList);

    // CloseHandle(processInfo.hThread);

    HANDLE mutex = CreateSemaphore(
        NULL, // default security attributes
        1,    // initial count
        1,    // maximum count
        NULL);

    start_read_thread(outputReadSide, options->stdout_port, mutex, options->ackRead);

    start_wait_exit_thread(processInfo.hProcess, options->exit_port, mutex);

    PtyHandle *pty = malloc(sizeof(PtyHandle));

    if (pty == NULL)
    {
        error_message = "Failed to allocate pty handle";
        return NULL;
    }

    pty->inputWriteSide = inputWriteSide;
    pty->outputReadSide = outputReadSide;
    pty->hPty = hPty;
    pty->dwProcessId = processInfo.dwProcessId;
    pty->ackRead = options->ackRead;
    pty->hMutex = mutex;

    return pty;
}

FFI_PLUGIN_EXPORT void pty_write(PtyHandle *handle, char *buffer, int length)
{
    DWORD bytesWritten;

    WriteFile(handle->inputWriteSide, buffer, length, &bytesWritten, NULL);

    FlushFileBuffers(handle->inputWriteSide);

    return;
}

FFI_PLUGIN_EXPORT void pty_ack_read(PtyHandle *handle)
{
    if (handle->ackRead)
    {
        ReleaseSemaphore(handle->hMutex, 1, NULL);
    }
}

FFI_PLUGIN_EXPORT int pty_resize(PtyHandle *handle, int rows, int cols)
{
    COORD size;

    size.X = cols;
    size.Y = rows;

    return ResizePseudoConsole(handle->hPty, size);
}

FFI_PLUGIN_EXPORT int pty_getpid(PtyHandle *handle)
{
    return (int)handle->dwProcessId;
}

FFI_PLUGIN_EXPORT char *pty_error()
{
    return error_message;
}
