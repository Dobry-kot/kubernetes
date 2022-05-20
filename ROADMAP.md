### ETCD

структура 

-------------------------
                        |       
                ----------------
                |   service    | etcd-{num}.{namespaceName}.svc.cluster.local
                ----------------
                        |
                        |
                        |             replicas=1 | deployments
                ----------------        ----------------      ----------------
replicas=1      |     etcd     | <------|  etcd-backup |----->|      S3      |
deployments     ----------------        ----------------      ----------------
                        ^
                        |---------------------------------------|
                        |                                       |
                ----------------                        ----------------    etcd-server
                |      pvc     | etcd-{num} | size=1G   |     certs    |    etcd-peer
                ----------------                        ----------------    etcd-healcheck

-------------------------

Задачи:

1) Написать оператор, который будет создавать кластер etcd.
    1. ресурс etcdСlusterInstance должен описывать полезные для обслуживания параметры:
        deployment ->
        - spec.cluster.instances                             | int
        - spec.cluster.pvc.size                              | string
        - spec.template.metadata.annotations                 | list 
        - spec.template.metadata.labels                      | list
        - spec.template.spec.nodeSelector                    | list
        - spec.template.spec.affinity                        | dict
        - spec.template.spec.containers[0].image             | string
        - spec.template.spec.containers[0].args              | list
        - spec.template.spec.containers[0].livenessProbe     | dict
        - spec.template.spec.containers[0].startupProbe      | dict
        - spec.template.spec.containers[0].resources         | dict
        - spec.template.spec.containers[0].priorityClassName | sring
        - ?
        политика обновления
        - update.srategy.name                                | sring
        - update.srategy.labelSelector.matchLabels           | list
        - update.srategy.rollingParams                       | dict

    2. ресурс etcdСlusterBackup должен описывать полезные для обслуживания параметры:
        - spec.s3.endpoints[0].name                          | sring
        - spec.s3.endpoints[0].url                           | sring
        - spec.s3.endpoints[0].credentials                   | sring
        - spec.?
    3. ресурс networkPolicy или ciliumNetworkPolicy должен описывать полезные для обслуживания параметры:
        - ?
    4. ресурс certificate должен описывать полезные для обслуживания параметры:
        - spec.ca.duration                                   | int
        - spec.ca.renewBefore                                | int
        - spec.certificates.duration                         | int
        - spec.certificates.renewBefore                      | int

    Сценарии:
        - создается ресурс etcdСlusterInstance с spec.cluster.instances = 2|4|6+ - создание запрещено кол-во должно быть 1 | 3 | 5
        - создается ресурс etcdСlusterInstance с spec.cluster.instances = 1 | 3 | 5
            аргументы для запуска:
                - --initial-cluster-state=new
                - --initial-cluster ${NAME_1}=http://${HOST_1}:2380,${NAME_2}=http://${HOST_2}:2380,${NAME_3}=http://${HOST_3}:2380....

2) Добавление в уже созданный кластер подов (узлов) с учетом доступного кол-ва подов (узлов) (1/3/5)
    Сценарии:
        - модифицируется ресурс etcdСlusterInstance с spec.cluster.instances = 2|4|6+ - модификация запрещена кол-во должно быть 1 | 3 | 5
        - модифицируется ресурс etcdСlusterInstance с spec.cluster.instances = 3 | 5
            аргументы для запуска:
                - --initial-cluster-state=existing
                - --initial-cluster ${NAME_1}=http://${HOST_1}:2380,+ NEW
            отправляется post запрос на регистрацию нового инстанса etcd

3) Удаление в существующем кластере подов (узлов) с сохранением консистентности данных и доступного кол-ва подов (узлов) (1/3/5)
    Сценарии:
        - модифицируется ресурс etcdСlusterInstance с spec.cluster.instances = 2|4|6+ - модификация запрещена кол-во должно быть 1 | 3 | 5
        - модифицируется ресурс etcdСlusterInstance с spec.cluster.instances = 1 | 3 
            - ищется лидер
            - отправляется post запрос на удаление нужного кол-ва инстансов etcd

4) Настройка стратегии обновления
    - указание сколько доступных инстансов етцд будет доступно при обновлении конфигурации.

5) Настройка стратегии бекапирования
    - указание интервалов времени между бекапами инкремент и фулл

6) Ротация сертификатов с перезапуском подов (узлов) по стратегии.
    - ротацией сертификатов занимается certManger но в случае изменения sha1 файла сертификата, требуется обновить конфигурацию етцд, что бы етцд перечитал секрет

7) В режиме работы PVC - RWO  требуется отслеживание и отмонтирование директории в случае выхода из строя экземпляра etcd.
    - проблема:
        Запушено 3 пода etcd с pvc (RWO) в случае выхода из строя одного пода, под удалится и переселится на свободную ноду, но 
        не сможет запуститься, т.к будет примаунчен к другой ноде и долгое время может находиться в таком состоянии.
    - требуется отслеживать такие моменты и предотвращать.
    - обходной вариант использовать pvc (RWX)