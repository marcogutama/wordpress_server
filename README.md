# Instalación y configuración de Wordpress con Chef

## Gestión de instancias

Para ver el estado de las instancias disponibles:
```bash
$ kitchen list
```

## Ejecucion cookbook:

Para ejecutar la configuración en las instancias:
```bash
$ kitchen converge
```

## Validación de la instalación de Wordpress 

Acceder desde el navegador de la máquina host:

Ubuntu: http://192.168.33.11

CentOS: http://192.168.33.12

## Ejecución de pruebas
### Pruebas unitarias
```bash
$chef exec rspec spec/unit/*_spec.rb
```
### Pruebas de integración:
```bash
$kitchen test
```