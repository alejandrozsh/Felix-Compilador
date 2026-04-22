# Felix - Compilador

Este repositorio contiene el código fuente del proyecto del Compilador Felix, incluyendo su interfaz gráfica desarrollada en web.

## Cómo ejecutar el proyecto

Para usar la aplicación web, no requieres instalaciones complejas. Simplemente abre el archivo principal o inicia el servidor de la aplicación (dependiendo de cómo manejes el backend) y la interfaz ya tendrá todos los estilos cargados.

## Modificar los estilos (Tailwind CSS)

El proyecto utiliza **Tailwind CSS** para los estilos. Para mantener el repositorio ligero, la carpeta `node_modules` no se incluye en el control de versiones. 

El archivo CSS compilado (`src/frontend/dist/output.css`) ya está incluido en el repositorio, por lo que **el proyecto funciona directamente**.

Sin embargo, **si deseas modificar la interfaz o los estilos**, deberás instalar las dependencias de desarrollo de Tailwind:

1. Asegúrate de tener [Node.js](https://nodejs.org/) instalado.
2. Abre una terminal y navega a la carpeta del frontend:
   ```bash
   cd src/frontend
   ```
3. Instala las dependencias:
   ```bash
   npm install
   ```
4. Inicia el modo "Watch" de Tailwind. Esto recompilará automáticamente el archivo CSS cada vez que guardes un cambio en tus HTML o configuraciones:
   ```bash
   npm run dev
   ```

Si deseas generar el archivo minificado para producción en lugar de usar el modo de desarrollo, puedes ejecutar:
```bash
npm run build
```

IMPORTANTE: CUANDO SE DESCARGUE SE DEBEN BORRAR LOS .java QUE SE GENEREN PARA EVITAR PROBLEMAS, AL CORRER EL SERVIDOR SE CARGARAN AUTOMATICAMENTE
