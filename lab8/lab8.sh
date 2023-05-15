#!/bin/bash

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S')]: $*" >&2
}

readInput() {
    local -n arr=$1
    arr+=("Справка" "Назад")
    select opt in "${arr[@]}"; do
    case $opt in
        Назад) return 0;;
        Справка) echo "Введите номер опции";;
        *)
            if [[ -z $opt ]]; then
                echo "Ошибка: введите число из списка" >&2
            else
                return $REPLY
            fi
            ;;
    esac
    done
}

unitpath() {
    tmp=$(systemctl status $1 | grep loaded | head -1)
    local path=$(awk '{ sub(/.*\(/, ""); sub(/;.*/, ""); print }' <<< $tmp)
    echo $path
}

if [ "$EUID" -ne 0 ]; then
    echo "Не админ"
    exit
fi

PS3=$'\n> '
options=(
    "Поиск системных служб"
    "Вывести список процессов и связанных с ними systemd служб"
    "Управление службами"
    "Поиск событий в журнале"
    "Справка"
    "Выйти"
)

select option in "${options[@]}"
do
    case $option in
    "Поиск системных служб")
        read -p "Введите имя службы или его часть: " unit
        systemctl list-units --type=service | head -n -7 |  tail -n +2 | grep "$unit"
        ;;

    "Вывести список процессов и связанных с ними systemd служб")
        ps ax -o'pid,unit' | grep  '\.service'
        ;;

    "Управление службами")
        readarray -t services < <(systemctl list-units --type=service | head -n -7 |  tail -n +2 | cut -d " " -f1)
        readInput services
        res=$?
        [ $res == 0 ] && continue
        service = ${services[res - 1]}
        select option in "Включить службу" "Отключить службу" "Запустить/перезапустить службу" "Остановить службу" "Вывести содержимое юнита службы" "Отредактировать юнит службы" "Справка" "Назад"; do
        case $option in
            "Включить службу")
                systemctl enable "$service"
                ;;
            "Отключить службу")
                systemctl disable "$service"
                ;;
            "Запустить/перезапустить службу")
                systemctl restart "$service"
                ;;
            "Остановить службу")
                systemctl stop "$service"
                ;;
            "Вывести содержимое юнита службы")
                cat "$(unitpath $service)"
                ;;
            "Отредактировать юнит службы")
                nano "$(unitpath $service)"
                ;;
            "Справка")
                echo "Выберите опцию $service"
                ;;
            "Назад")
                break
                ;;
            *) echo "Неправильная команда";;
        esac
        done
        ;;
    "Поиск событий в журнале")
        read -p "Введите имя службы: " serviceName
        echo "Выберите степень важности: "
        priorityList = ("emerg" "alert" "crit" "err" "warning" "notice" "info" "debug")
        readInput priorityList
        result = $?
        [ $result == 0 ] && continue
        priority = ${priorityList[result - 1]}
        read -p "Введите строку поиска: " searchString
        echo $priority
        if [$serviceName == ""]; then
            journalctl -p "$priority" -g "$searchString"
        else
            journalctl -p "$priority" -u "$serviceName" -g "$searchString"
        fi
        ;;
    "Справка")
        echo "Введите команду"
        ;;
    "Выйти")
        break
        ;;
    *) echo "Неправильная команда";;
    esac
done
