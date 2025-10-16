# 🐳 Guía de Docker para Figma MCP Server

Esta guía te mostrará cómo ejecutar el servidor Figma MCP en Docker por HTTP.

> **✅ Corrección Importante**: El servidor ha sido corregido para escuchar en `0.0.0.0` en lugar de `127.0.0.1`, permitiendo conexiones desde el host. Si instalaste una versión anterior, actualiza con `docker-compose up -d --build`. Ver detalles en [DOCKER_FIX.md](DOCKER_FIX.md)

## 📋 Requisitos Previos

- Docker instalado ([Descargar Docker](https://www.docker.com/products/docker-desktop))
- Docker Compose (incluido con Docker Desktop)
- Token de acceso de Figma ([Cómo obtenerlo](https://help.figma.com/hc/en-us/articles/8085703771159-Manage-personal-access-tokens))

## 🚀 Inicio Rápido

### 1. Configurar variables de entorno

Copia el archivo de ejemplo y configura tu token de Figma:

```bash
cp .env.example .env
```

Edita `.env` y agrega tu token de Figma:

```env
FIGMA_API_KEY=tu-token-de-figma-aqui
PORT=3333
OUTPUT_FORMAT=yaml
```

### 2. Construir y ejecutar con Docker Compose (Recomendado)

```bash
# Construir y ejecutar en segundo plano
docker-compose up -d

# Ver los logs
docker-compose logs -f

# Detener el servidor
docker-compose down
```

### 3. Verificar que funciona

El servidor estará disponible en:
- **StreamableHTTP**: `http://localhost:3333/mcp`
- **SSE**: `http://localhost:3333/sse`
- **Messages**: `http://localhost:3333/messages`

```bash
# Probar la conexión (debería devolver error de sesión, pero confirma que funciona)
curl -X POST http://localhost:3333/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"ping"}'
```

## 🔌 Configuración en IDEs

Una vez que el servidor Docker está corriendo, necesitas configurar tu IDE para conectarse al servidor MCP por HTTP.

### Cursor

Cursor soporta servidores MCP por HTTP. Agrega esta configuración a tu archivo de configuración MCP:

**MacOS/Linux**: `~/.cursor/mcp.json` o `~/.config/cursor/mcp.json`  
**Windows**: `%APPDATA%\Cursor\mcp.json`

```json
{
  "mcpServers": {
    "Framelink MCP for Figma (Docker)": {
      "url": "http://localhost:3333/mcp",
      "transport": "streamableHttp"
    }
  }
}
```

O si prefieres usar SSE:

```json
{
  "mcpServers": {
    "Framelink MCP for Figma (Docker SSE)": {
      "url": "http://localhost:3333/sse",
      "transport": "sse"
    }
  }
}
```

**Verificar conexión en Cursor:**
1. Abre Cursor
2. Presiona `Cmd/Ctrl + Shift + P`
3. Busca "MCP: Show MCP Servers"
4. Deberías ver "Framelink MCP for Figma (Docker)" con estado "Connected"

### Visual Studio Code (con extensión MCP)

VS Code requiere una extensión para soportar MCP. Una vez instalada la extensión MCP:

**Archivo de configuración**: `.vscode/settings.json` (en tu workspace)

```json
{
  "mcp.servers": {
    "figma-docker": {
      "type": "streamableHttp",
      "url": "http://localhost:3333/mcp"
    }
  }
}
```

**Nota**: VS Code tiene soporte limitado de MCP comparado con Cursor. Verifica la documentación de la extensión MCP que estés usando.

### Continue (Extensión para VS Code/JetBrains)

Si usas la extensión Continue para VS Code o JetBrains IDEs:

**Archivo**: `~/.continue/config.json`

```json
{
  "mcpServers": [
    {
      "name": "Figma MCP Docker",
      "url": "http://localhost:3333/mcp",
      "transport": "http"
    }
  ]
}
```

### Claude Desktop

Para usar el servidor Docker con Claude Desktop, edita el archivo de configuración:

**MacOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`  
**Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "figma-docker": {
      "url": "http://localhost:3333/mcp",
      "transport": "streamableHttp"
    }
  }
}
```

Luego reinicia Claude Desktop completamente.

### Configuración Genérica para otros clientes MCP

Para cualquier cliente MCP compatible con HTTP/SSE:

**StreamableHTTP (Recomendado - más moderno):**
```
URL: http://localhost:3333/mcp
Transport: streamableHttp
```

**SSE (Server-Sent Events - más compatible):**
```
URL: http://localhost:3333/sse
Messages URL: http://localhost:3333/messages
Transport: sse
```

### Probar la conexión desde tu IDE

Una vez configurado, puedes probar que funciona:

1. **En Cursor**: Abre el chat con IA (Cmd/Ctrl + L) y pega un enlace de Figma:
   ```
   https://www.figma.com/design/ABC123/My-Design
   ```
   Luego pide: "Implementa este diseño en React"

2. **En Claude Desktop**: Simplemente pega un enlace de Figma y pide ayuda con el diseño.

3. **Verificar herramientas disponibles**: El servidor debe exponer dos herramientas:
   - `get_figma_data` - Obtiene datos de diseño de Figma
   - `download_figma_images` - Descarga imágenes de Figma

### Solución de problemas de conexión IDE

**Error: "Cannot connect to MCP server"**
```bash
# 1. Verifica que el contenedor está corriendo
docker ps | grep figma-mcp-server

# 2. Verifica los logs del servidor
docker-compose logs -f

# 3. Prueba la conexión manualmente
curl http://localhost:3333/mcp
```

**Error: "Connection refused"**
- Asegúrate de que Docker Desktop está corriendo
- Verifica que el puerto 3333 no está bloqueado por firewall
- Prueba cambiar el puerto en `.env` y en la configuración del IDE

**El IDE no detecta las herramientas de Figma**
- Reinicia completamente el IDE
- Verifica que el servidor tiene tu `FIGMA_API_KEY` configurado correctamente
- Revisa los logs del servidor: `docker-compose logs -f`

**Cambiar de Docker a instalación local**

Si quieres volver a usar el servidor sin Docker (modo stdio):

```json
{
  "mcpServers": {
    "Framelink MCP for Figma": {
      "command": "npx",
      "args": ["-y", "figma-developer-mcp", "--figma-api-key=YOUR-KEY", "--stdio"]
    }
  }
}
```

## 🔧 Opciones Avanzadas

### Construir la imagen manualmente

```bash
# Construir la imagen
docker build -t figma-mcp-server .

# Ejecutar el contenedor
docker run -d \
  --name figma-mcp-server \
  -p 3333:3333 \
  -e FIGMA_API_KEY=tu-token-aqui \
  -e PORT=3333 \
  -e OUTPUT_FORMAT=yaml \
  figma-mcp-server

# Ver logs
docker logs -f figma-mcp-server

# Detener el contenedor
docker stop figma-mcp-server

# Eliminar el contenedor
docker rm figma-mcp-server
```

### Cambiar el puerto

Edita el archivo `.env`:

```env
PORT=8080
```

O especifica el puerto al ejecutar:

```bash
PORT=8080 docker-compose up -d
```

### Usar formato JSON en lugar de YAML

```env
OUTPUT_FORMAT=json
```

### Saltar descargas de imágenes

```env
SKIP_IMAGE_DOWNLOADS=true
```

### Usar OAuth en lugar de Personal Access Token

```env
# Comenta FIGMA_API_KEY y usa FIGMA_OAUTH_TOKEN
# FIGMA_API_KEY=
FIGMA_OAUTH_TOKEN=tu-oauth-token-aqui
```

## 📊 Comandos útiles de Docker

```bash
# Ver contenedores en ejecución
docker ps

# Ver todos los contenedores (incluyendo detenidos)
docker ps -a

# Ver logs en tiempo real
docker-compose logs -f

# Reiniciar el servidor
docker-compose restart

# Reconstruir la imagen después de cambios en el código
docker-compose up -d --build

# Eliminar el contenedor y volúmenes
docker-compose down -v

# Ver uso de recursos
docker stats figma-mcp-server
```

## 🐛 Solución de Problemas

### El contenedor no inicia

Verifica los logs:
```bash
docker-compose logs
```

### Error: "FIGMA_API_KEY is required"

Asegúrate de que el archivo `.env` existe y contiene tu token:
```bash
cat .env
```

### Error de permisos

En Linux, puede que necesites ejecutar Docker con sudo o agregar tu usuario al grupo docker:
```bash
sudo usermod -aG docker $USER
```

Luego cierra sesión y vuelve a iniciarla.

### Cambiar puerto si 3333 está ocupado

```bash
PORT=8080 docker-compose up -d
```

### El contenedor se detiene inmediatamente

Verifica que no estés ejecutando en modo stdio. El Dockerfile está configurado para HTTP por defecto.

## 🔒 Seguridad

- **Nunca** commitas el archivo `.env` con tokens reales
- El archivo `.env.example` es solo una plantilla
- Los tokens de Figma dan acceso a tus archivos de diseño
- Considera usar secrets de Docker en producción:

```bash
echo "tu-token-aqui" | docker secret create figma_api_key -
```

## 📚 Más Información

- [Documentación del Proyecto](README.md)
- [API de Figma](https://www.figma.com/developers/api)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Docker Documentation](https://docs.docker.com/)

