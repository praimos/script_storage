#!/usr/bin/env bash

USE_NAMESPACE=""
SECRETS_NAME=""


exit_check() {
    if [ -z $1 ]; then
        echo -e "\033[31mТакого значения нет. Выходим!\033[37m"
        exit 1
    fi
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

get_all_secrets() {
        LIST_SECRETS=($(kubectl get secrets | awk '{print $1}' | sed -e '/NAME/d'))
    for i in ${!LIST_SECRETS[*]}
    do
        echo -e "\033[36m$i)  ${LIST_SECRETS[$i]}\033[37m"
    done

    echo -e "\033[32mВыберите SECRET\033[37m"
    read -r -p '> ' NUMBER
    exit_check ${LIST_SECRETS[$NUMBER]}
    SECRETS_NAME=${LIST_SECRETS[$NUMBER]}
        echo -e "\033[33mПросмотр данных $SECRETS_NAME\033[37m"
}

get_data_secrets() {
        kubectl get secret $SECRETS_NAME -o jsonpath="{.data}" | jq 'map_values(@base64d)'
}


if [ $1 ]; then
        NAMESPACE=($(kubectl get ns | awk '{print $1}' | grep $1))
else
        NAMESPACE=($(kubectl get ns | awk '{print $1}' | sed -e '/NAME/d'))
fi

get_use_namespace
get_all_secrets
get_data_secrets
