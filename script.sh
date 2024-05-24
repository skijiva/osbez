#!/bin/bash

# Функция для вывода справки
usage() {
    echo "Usage: $0 [options]
Options:
    -u, --users           Display a list of users and their home directories
    -p, --processes       Display a list of running processes
    -h, --help            Display this help message
    -l PATH, --log PATH   Redirect output to the specified file
    -e PATH, --errors PATH  Redirect errors to the specified file"
}

# Функция для вывода списка пользователей и их домашних директорий
list_users() {
    cut -d: -f1,6 /etc/passwd | sort
}

# Функция для вывода списка запущенных процессов
list_processes() {
    ps -e --format pid,comm --sort pid
}

# Переменные для хранения путей логов и ошибок
log_file=""
error_file=""

# Парсинг аргументов командной строки
while [[ $# -gt 0 ]]; do
    case "$1" in
        -u|--users)
            action="users"
            shift
            ;;
        -p|--processes)
            action="processes"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -l|--log)
            log_file="$2"
            shift 2
            ;;
        -e|--errors)
            error_file="$2"
            shift 2
            ;;
        *)
            echo "Invalid argument: $1"
            usage
            exit 1
            ;;
    esac
done

# Проверка доступности лог файла
if [[ -n "$log_file" ]]; then
    touch "$log_file" 2>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "Error: Cannot write to log file $log_file"
        exit 1
    fi
    exec >"$log_file"
fi

# Проверка доступности файла ошибок
if [[ -n "$error_file" ]]; then
    touch "$error_file" 2>/dev/null
    if [[ $? -ne 0 ]]; then
        echo "Error: Cannot write to error file $error_file" >&2
        exit 1
    fi
    exec 2>"$error_file"
fi

# Выполнение действия в зависимости от аргумента
case "$action" in
    "users")
        list_users
        ;;
    "processes")
        list_processes
        ;;
    *)
        echo "No action specified"
        usage
        exit 1
        ;;
esac
