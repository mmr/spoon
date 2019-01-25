#!/usr/bin/env bash

declare arg_all
declare arg_verybose

spoon_select_from_multiple() {
    if [[ $arg_all = 0 ]] && [[ $node_count -gt 1 ]]; then
        nodes_data="$(echo "${nodes}" | jq '.[] | .id + " " + .service + " " + (if .publicIp then .publicIp else ("*" + .privateIp) end) + " (" + .state + ")"' | tr -d '\"')"
        echo "${nodes_data}"| nl '-s) ' | column -t
        echo "*)  all"
        read -rp '==> ' reply
        if [[ "${reply}" = "" ]]; then
            verbose_log "[spoon] no instances selected"
            nodes='[]'
            return
        fi
        if [[ "${reply}" = '*' ]]; then
            verbose_log "[spoon] all instances selected"
        else
            jq_range_expression="$(jqrangify "${reply}")"
            [[ "${arg_verybose}" = 1 ]] && echo "[spoon] jq range expression: ${jq_range_expression}"
            if ! nodes="$(echo "${nodes}" | jq "${jq_range_expression}" 2>/dev/null)"; then
                echo "[spoon] jq error: invalid selector"
                exit 1
            fi
            node_count=$(echo "${nodes}" | jq '. | length')
            if [[ "${node_count}" -eq 0 ]]; then
                echo "[spoon] no instances selected"
                nodes='[]'
                return
            fi
            [[ "${arg_verybose}" = 1 ]] && echo -e "[spoon] selected instances:\\n${nodes}"
        fi
    fi
}