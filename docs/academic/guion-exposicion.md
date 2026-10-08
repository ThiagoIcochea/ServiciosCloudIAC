# Guion de exposición (5–8 minutos)

Proyecto: Diseño e implementación de Infraestructura como Código para la
gestión multi-cloud de 50 sucursales mediante Terraform y pruebas locales.

> Tiempo estimado total: ~7 minutos de exposición + demostración práctica.
> Cada bloque indica un tiempo orientativo; ajustar según el tiempo real
> asignado por el docente.

---

## 1. Problemática (45 s)

"Una empresa necesita administrar la infraestructura tecnológica de 50
sucursales con un patrón común: cada una requiere una red independiente,
dos servidores, reglas de seguridad y monitoreo, sobre dos proveedores
cloud — AWS y Google Cloud Platform. Hacerlo manualmente, o copiando
configuración sucursal por sucursal, no escala y no es auditable. A esto se
suma una restricción real de este proyecto: no contamos con credenciales
de AWS ni de GCP, por lo que toda la solución debe diseñarse, implementarse
y **validarse** sin depender de una cuenta cloud real."

## 2. Arquitectura propuesta (60 s)

"Diseñamos un patrón data-driven: un único archivo, `branches.yaml`,
describe las 50 sucursales — identificador, proveedor, región, red,
servidores, reglas y monitoreo. Un módulo orquestador, `branch-stack`, lee
ese archivo y, por cada sucursal, instancia los módulos de red, cómputo,
seguridad y monitoreo del proveedor correspondiente. [Mostrar Figura 1]
Definimos una interfaz común entre AWS y GCP — por ejemplo, el tamaño de un
servidor se declara como `small`/`medium`/`large` y cada módulo lo traduce
a su propio tipo de instancia — respetando a la vez las diferencias
técnicas reales entre proveedores, como que AWS fija la región a nivel de
proveedor y GCP a nivel de recurso."

## 3. Uso de Terraform (45 s)

"Usamos Terraform porque es declarativo, soporta múltiples proveedores con
la misma sintaxis, y desde la versión 1.6 incorpora `terraform test` con
`mock_provider`, que nos permite simular AWS y GCP sin hacer ninguna
llamada real a sus APIs. Eso fue decisivo dada nuestra restricción de no
tener credenciales."

## 4. Reutilización de módulos (45 s)

"Implementamos 8 módulos base — red, cómputo, seguridad y monitoreo, para
AWS y para GCP — cada uno con variables tipadas, validaciones de entrada,
outputs documentados y un README con ejemplo de uso. [Mostrar Figura 4] Ni
un solo recurso se repite manualmente: todo se genera con `for_each` sobre
los datos de `branches.yaml`."

## 5. Configuración de 50 sucursales (45 s)

"Las 50 sucursales se distribuyen 25 AWS / 25 GCP — un supuesto académico
que documentamos explícitamente — y en 3 entornos: 40 en producción, 6 en
staging, 4 en desarrollo. Agregar la sucursal 51 es agregar una entrada al
YAML: lo demostramos en la prueba CP15, confirmando con `git status` que
ningún archivo `.tf` cambia."

## 6. Gestión del State (40 s)

"Documentamos la estrategia empresarial — backend S3 con versionado y
cifrado en AWS, GCS en GCP, ambos con bloqueo e IAM de mínimo privilegio —
y la demostramos con un laboratorio 100% local usando el backend `local`:
inicialización, creación, consulta de estado, modificación, plan, apply
controlado y destrucción. [Mostrar Figura 6]"

## 7. Pipeline CI/CD (40 s)

"El pipeline de GitHub Actions corre formato, validación en los 3 entornos,
la validación de esquema de las 50 sucursales, las pruebas con
`mock_provider`, TFLint y análisis de seguridad con Checkov y gitleaks.
Nunca ejecuta `apply` contra AWS o GCP reales. [Mostrar Figura 5] De hecho,
en la ejecución real contra nuestro repositorio, el pipeline detectó dos
problemas genuinos — un archivo sin formatear y variables sin usar — que
corregimos y volvimos a subir; quedó registrado en la evidencia."

## 8. Seguridad (30 s)

"Ningún secreto vive en el repositorio: `.gitignore` excluye estados y
variables reales, y `gitleaks` escanea cada push. Documentamos el uso
futuro de AWS Secrets Manager, Google Secret Manager y autenticación OIDC
sin claves estáticas."

## 9. Demostración de Drift (50 s)

"Esta es la parte más ilustrativa: creamos un recurso con Terraform,
simulamos que alguien lo modifica manualmente — como pasaría si alguien
cambia algo en producción sin pasar por el pipeline —, y mostramos cómo
`terraform plan` detecta la diferencia. [Mostrar Figura 7] Después
decidimos reconciliar aplicando la configuración declarada, y verificamos
que el recurso volvió al estado esperado. Es el mismo mecanismo que usaría
Terraform contra un recurso real de AWS o GCP."

## 10. Resultados y conclusiones (40 s)

"De 16 casos de prueba, 14 se ejecutaron y pasaron; uno dependía de la
publicación del repositorio y ya se completó con evidencia real de GitHub
Actions; el laboratorio Docker quedó implementado pero sin ejecutar por no
contar con Docker Desktop en el equipo de desarrollo — lo documentamos en
vez de simularlo. La conclusión central: es posible diseñar, implementar y
validar honestamente una solución IaC multi-cloud para 50 sucursales sin
credenciales reales, dejando claro en todo momento qué se ejecutó
realmente y qué queda pendiente de infraestructura cloud real."

---

## Demostración práctica (PowerShell)

Ejecutar en vivo, en este orden, con el repositorio ya clonado:

```powershell
# 1. Validaciones estaticas (fmt + validate x3 entornos + esquema 50 sucursales)
./scripts/validate.ps1

# 2. Pruebas automatizadas con mock_provider (sin credenciales)
./scripts/test.ps1

# 3. Laboratorio de Drift: crear, modificar manualmente, detectar, reconciliar
cd lab/drift
./run_drift_demo.ps1
cd ../..
```

Si el tiempo lo permite, mostrar también `terraform/modules/branch-stack/main.tf`
y `config/branches/branches.yaml` para evidenciar el patrón data-driven.

---

## Preguntas y respuestas preparadas

**¿Por qué utilizar Terraform?**
Es declarativo, multi-cloud con una sola sintaxis (HCL), mantiene un estado
versionable de la infraestructura, y desde la 1.6 permite probar
configuraciones sin credenciales reales mediante `mock_provider`.

**¿Por qué AWS y GCP?**
El enunciado exige ambos proveedores. Elegimos distribuir las sucursales
25/25 como supuesto académico documentado; en un caso real la distribución
dependería de criterios de negocio (presencia regional, costos, contratos).

**¿Cómo se administran 50 sucursales?**
Con un único archivo de datos (`branches.yaml`) y un módulo orquestador
(`branch-stack`) que aplica `for_each` sobre esos datos, no con código
repetido por sucursal.

**¿Cómo se evita duplicar código?**
8 módulos reutilizables (4 por proveedor) parametrizados por variables
tipadas; la "duplicación" que existe son 50 entradas de *datos*, no 50
copias de código Terraform.

**¿Cómo se gestionan los secretos?**
No se almacenan en el repositorio: `.gitignore` los excluye, `gitleaks` los
escanea en cada push, y documentamos el uso futuro de Secrets Manager y
autenticación OIDC sin claves estáticas.

**¿Cómo funciona el State?**
Es el archivo donde Terraform registra qué recursos administra y sus
atributos; lo usamos para calcular diferencias entre lo declarado y lo
real. En este proyecto el backend es local (`terraform.tfstate`, nunca
versionado); en producción sería remoto (S3/GCS) con cifrado y bloqueo.

**¿Qué sucede cuando alguien modifica producción manualmente?**
Se genera Infrastructure Drift: la próxima vez que se ejecuta `terraform
plan`, Terraform detecta la diferencia entre el estado declarado y el
estado real, y el equipo decide si conservar el cambio (actualizando el
código) o revertirlo (aplicando la configuración declarada). Lo
demostramos en vivo en este proyecto.

**¿Qué diferencia existe entre una simulación y un despliegue real?**
`mock_provider` valida que nuestra configuración es internamente
consistente (referencias, tipos, cantidad de recursos) pero no prueba que
AWS o GCP acepten esa configuración en la práctica (cuotas, permisos,
disponibilidad de la imagen, etc.). Por eso el informe distingue
explícitamente, en cada sección, qué se ejecutó realmente y qué queda
documentado como diseño para un despliegue real futuro.
