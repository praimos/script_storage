#!/usr/bin/env bash

USE_NAMESPACE=""
USE_POD=""


exit_check() {
    if [ -z $1 ]; then
        echo -e "\033[31mТакого значения нет. Выходим!\033[37m"
        exit 1
    fi
}


write_lods() {
    echo "$(date +"%G/%m/%d %T") [COMMAND]- $1" >> $HOME/.k8s_menu.log
    COMMAND=$1
    $COMMAND
}


get_use_namespace() {
    for i in ${!NAMESPACE[*]}
    do
        echo -e "\033[36m$i)  ${NAMESPACE[$i]}\033[37m"
    done

    echo -e "\033[32mВыберите NAMESPACE\033[37m"
    read -r -p '> ' NUMBER
        exit_check ${NAMESPACE[$NUMBER]}
    USE_NAMESPACE=${NAMESPACE[$NUMBER]}
        echo -e "\033[33mАктивация $USE_NAMESPACE\033[37m"
        kubectl config set-context --current --namespace=$USE_NAMESPACE
}

get_use_pod() {
    echo -e "\033[32mДоступные PODS:\033[37m"

    PODS=($(kubectl get pods -o wide | awk '{print $1}'| sed -e '/NAME/d' | tr ' ' '\n'))

    for i in ${!PODS[*]}
    do
        echo -e "\033[36m$i)  ${PODS[$i]}\033[37m"
    done

    echo -e "\033[32mВыберите POD\033[37m"
    read -r -p '> ' NUMBER
        exit_check ${PODS[$NUMBER]}
    USE_POD=${PODS[$NUMBER]}
}

get_logs() {
    echo -e "\033[32mУкажите количество последних строк для вывода (пустое значение выведит полный лог)\033[37m"
    read -r -p '> ' LINES
    if [ $LINES ]; then
        kubectl logs $1 -n $2 | tail -n $LINES
    else
        write_lods "kubectl logs $1"
    fi
}

get_logs_real() {
    write_lods "kubectl logs -f $1"
}

search_log_data() {\
    echo -e "\033[32mУкажите ключевое слово для поиска\033[37m"
    read -r -p '> ' KEYWORDS
    kubectl logs $1| grep $KEYWORDS
}

log(){
    echo -e "\033[32mВыберите действие:\033[37m"
    echo "1) Вывести лог"
    echo "2) Отслеживание в реальном времени"
    echo "3) Поиск по логам"

    while true; do
    read -r -p '> ' NUM
        case $NUM in

        1)
            get_logs $USE_POD
            break
            ;;

        2)
            get_logs_real $USE_POD
            break
            ;;
        3)
            search_log_data $USE_POD
            break
            ;;
        *)
            echo -e "\033[32mВыберите один из представленных вариантов\033[37m"
            ;;
            esac
    done

}

port_forward() {
    echo -e "\033[32mУкажите сочетание портов в формате \033[31mlocal_port:pod_port\033[37m"
    read -r -p '> ' PORTS
    write_lods "kubectl port-forward pods/$1 $PORTS"
}

select_action() {
    echo -e "\033[32mВыберите действие:\033[37m"
    echo "1) Работа с логами"
    echo "2) Пробросить порт"

    while true; do
    read -r -p '> ' NUM
        case $NUM in

        1)
            log $USE_POD
            break
            ;;

        2)
            port_forward $USE_POD
            break
            ;;
        *)
            echo -e "\033[32mВыберите один из представленных вариантов\033[37m"
            ;;
            esac
    done
}



if [ $1 ]; then
        NAMESPACE=($(kubectl get ns | awk '{print $1}' | grep $1))

else
        NAMESPACE=($(kubectl get ns | awk '{print $1}' | sed -e '/NAME/d'))
fi

get_use_namespace
get_use_pod
select_action
