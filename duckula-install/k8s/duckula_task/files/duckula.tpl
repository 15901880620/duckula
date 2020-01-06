    spec:
{{- if .Values.hosts  }} 
      hostAliases:
    {{- range $index, $element := .Values.hosts }}
      - ip: {{ $element.ip | quote }}
        hostnames: 
      {{- range $element.host }}
        - {{ . | quote }}
       {{- end }}
    {{- end }} 
{{- end }}
      #  TODO 这添加条件会出错。。。。
      restartPolicy: Never
      containers:
      - name: {{ template "duckula.fullname" . }}
        image: '{{ .Values.image }}:{{ .Values.imageTaskTag }}'
        imagePullPolicy: IfNotPresent
        resources:
{{ toYaml .Values.resources | indent 10 }}
        env:
        - name: zk
          value: {{ .Values.env.zk }}
        - name: taskid
          value: {{ .Values.env.taskid }}
        - name: taskpattern
          value: tiller
        {{- if .Values.env.rootpath  }} 
        - name: rootpath
          value: {{ .Values.env.rootpath }}
        {{- end }}       
        #不能有command否则会覆盖ENTRYPOINT
        args: [{{ .Values.cmd |quote }},"$(taskid)","2723"]
        ports:
        - name: jmx
          containerPort: 2723
        - name: jmxexporter
          containerPort: 2780
        - name: debug
          containerPort: 2113
        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - "/bin/echo 0"
          initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
          periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
          timeoutSeconds: {{ .Values.livenessProbe.timeoutSeconds }}
          successThreshold: {{ .Values.livenessProbe.successThreshold }}
          failureThreshold: {{ .Values.livenessProbe.failureThreshold }}
        readinessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - "/bin/echo 0"
          initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds }}
          periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
          timeoutSeconds: {{ .Values.readinessProbe.timeoutSeconds }}
          successThreshold: {{ .Values.readinessProbe.successThreshold }}
          failureThreshold: {{ .Values.readinessProbe.failureThreshold }}
        volumeMounts:
        - name: data
          mountPath: /data/duckula-data
      {{- if .Values.userconfig.root }}
        - name: userconfig-root
          mountPath: /opt/userconfig
      {{- end }}
      {{- if .Values.userconfig.es }}
        - name: userconfig-es
          mountPath: /opt/userconfig/es
      {{- end }}
      {{- if .Values.userconfig.kafka }}
        - name: userconfig-kafka
          mountPath: /opt/userconfig/kafka
      {{- end }}
      {{- if .Values.userconfig.redis }}
        - name: userconfig-redis
          mountPath: /opt/userconfig/redis
      {{- end }}

      volumes:
      - name: data
      {{- if and .Values.persistence.enabled .Values.persistence.existingClaim }}
        persistentVolumeClaim:
          claimName: {{ .Values.persistence.existingClaim }}
      {{- else }}
        emptyDir: {}
      {{- end -}}
      {{- if .Values.userconfig.root }}
      - name: userconfig-root
        configMap:
          name: {{ template "duckula.fullname" . }}-root
      {{- end }}
      {{- if .Values.userconfig.es }}
      - name: userconfig-es
        configMap:
          name: {{ template "duckula.fullname" . }}-es
      {{- end }}
      {{- if .Values.userconfig.kafka }}
      - name: userconfig-kafka
        configMap:
          name: {{ template "duckula.fullname" . }}-kafka
      {{- end }}
      {{- if .Values.userconfig.redis }}
      - name: userconfig-redis
        configMap:
          name: {{ template "duckula.fullname" . }}-redis
      {{- end }}
      
      
      {{- if .Values.extraVolumes }}
{{ tpl .Values.extraVolumes . | indent 6 }}
      {{- end }}