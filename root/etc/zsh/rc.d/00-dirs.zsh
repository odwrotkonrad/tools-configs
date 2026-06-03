typeset -a svc_dirs=(
    /var/log/grafana
    /var/log/jaeger
    /var/log/loki
    /var/log/prometheus
    /var/log/dir_size_exporter
    /var/log/port_exporter
    /var/log/otelcol
    /usr/local/var/grafana
    /usr/local/var/prometheus
    /usr/local/var/dir_size_exporter
)
typeset -a missing=()
for d in ${svc_dirs}; [[ -d $d ]] || missing+=$d
(( ${#missing} )) && sudo mkdir -p ${missing}
unset svc_dirs missing d
