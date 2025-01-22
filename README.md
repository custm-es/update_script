# update_script
Repositorio para la gestión del script de actualización del customio

Este script se llama desde un cron diariamente dentro del customio.

Como se puede ver en el script, se definen una constante:

```BASH
# Remote URL of the configuration file
CONFIG_URL="https://custm.es/config1.xml"
```

Este sera el archivo que el customio descargará y aplicará como configuración cada vez que se ejecute la regla Cron. 

Dentro de ese archivo se encuentran las reglas que actualmente he conseguido configurar y que hacen al customio funcionar correctamente. 

Lo ideal es que ese archivo también esté bajo control de versiones, y además, que esté versionado para cada uno de los customios que implantemos, de forma que podamos volver atrás facilmente y de forma remota en la configuración de cada uno de ellos.

Para esto, deberiamos poder identificar cada custmomio con un numero de serie o similar que sea el que diferencie un archivo de configuración de otro.

