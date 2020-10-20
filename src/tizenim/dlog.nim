
########################### dlog

type
  log_priority* = enum
    DLOG_UNKNOWN = 0,           ## *< Keep this always at the start
    DLOG_DEFAULT,             ## *< Default
    DLOG_VERBOSE,             ## *< Verbose
    DLOG_DEBUG,               ## *< Debug
    DLOG_INFO,                ## *< Info
    DLOG_WARN,                ## *< Warning
    DLOG_ERROR,               ## *< Error
    DLOG_FATAL,               ## *< Fatal
    DLOG_SILENT,              ## *< Silent
    DLOG_PRIO_MAX             ## *< Keep this always at the end.

proc dlog_print*(prio: log_priority; tag: cstring; fmt: cstring): cint {. varargs, header: "dlog.h" .}


# Helper log functions
proc dlog*(txt: string) = discard dlog_print(DLOG_INFO, "TizenApp", txt)