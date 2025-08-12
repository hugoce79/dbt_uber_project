# dbt_uber_project

#  Proyecto BI - Análisis de Viajes Uber

##  Descripción
Este proyecto forma parte del **Bootcamp de Ingeniería de Datos** y tiene como objetivo construir un flujo de transformación de datos de viajes de Uber, desde su ingestión en bruto hasta la visualización final en un dashboard interactivo con **Power BI**.

La arquitectura sigue un enfoque de **data warehouse moderno**, con capas:
- **Bronze** → Datos crudos (raw)
- **Silver** → Limpieza, estandarización y enriquecimiento básico
- **Gold** → Modelos dimensionales (hechos y dimensiones) listos para analítica
- **BI** → Dashboard conectado a Snowflake

---

## 🗂 Estructura del Proyecto:

uber-project/
├─ README.md
├─ .gitignore
├─ .env.example                 
├─ airflow/                     # proyecto Airflow (Bronze)
│  ├─ dags/
│  │  ├─ uber_ingest_bronze_dag.py     # DAG: GCS→Local (si aplica) → Snowflake (PUT/COPY) o COPY con stage externo
│  │  ├─ snowflake_test_dag.py         # DAGs de smoke test (conexión, permisos)
│  │  └─ gcs_list_bucket_test_dag.py   # DAG simple para validar GCS
│  ├─ requirements.txt          # providers extra si los instalas al arranque
│  └─ README.md                 # cómo levantar Airflow, conexiones, variables, etc.
│
├─ dbt/                         # proyecto dbt (Silver & Gold)
│  ├─ dbt_project.yml
│  ├─ packages.yml              # dbt_utils u otros
│  ├─ models/
│  │  ├─ sources/
│  │  │  └─ bronze_sources.yml  # source() → BRONZE.UBER_RAW en Snowflake
│  │  ├─ silver/
│  │  │  ├─ silver_uber_trips.sql
│  │  │  └─ schema.yml          # tests (not_null, expresiones, relaciones)
│  │  ├─ gold/
│  │  │  ├─ dim_time.sql
│  │  │  ├─ dim_location.sql
│  │  │  ├─ dim_vendor.sql
│  │  │  ├─ fact_uber_trips.sql
│  │  │  ├─ fact_uber_trips_v.sql      # vista BI-friendly (geom, FKs resueltas)
│  │  │  └─ schema.yml
│  │  └─ macros/
│  │     └─ tests/
│  │        └─ is_positive.sql
│  └─ README.md                 # cómo correr dbt (perfiles, targets, selectores)
│
├─ bi/
│  ├─ powerbi/
│  │  ├─ dataset/               # capturas, pbids/pbit (si aplicas)
│  │  └─ measures.md            # catálogo de DAX (las medidas “Raw/Valid”, cancelados, etc.)
│  └─ docs/
│     └─ dashboard_wireframe.png


---

##  Tecnologías Utilizadas
- **Apache Airflow** → Ingesta de datos crudos
- **DBT Cloud** → Orquestación y modelado de datos
- **Snowflake** → Data Warehouse
- **Power BI** → Visualización de datos
- **GitHub** → Control de versiones

---

##  Flujo de Datos
1. **Bronze Layer** → Ingesta de datos crudos (`uber_raw`).
2. **Silver Layer** → Limpieza:
   - Conversión de tipos de datos
   - Cálculo de métricas base (`trip_duration_minutes`)
   - Inclusión de coordenadas geográficas
3. **Gold Layer** → Modelos dimensionales:
   - `dim_time` → Fecha y hora normalizada
   - `dim_location` → Latitud, longitud y atributos geográficos
   - `dim_vendor` → Información del proveedor
   - `dim_payment_type` Información del tipo de pago
   - `dim_rate_code` Información 
   - `fact_uber_trips` → Tabla de hechos con métricas y claves foráneas
4. **BI Layer** → Dashboard en Power BI con métricas clave.

---

##  KPIs Implementados
- **Revenue Total**
- **Revenue (Excluyendo Cancelados)**
- **Viajes Cancelados (conteo)**
- **Duración Promedio de Viaje**
- **Distancia Promedio de Viaje (solo válidos)**
- **Mapa interactivo** con puntos de recogida y destino
- **Análisis por Razón de Cancelación**

---





