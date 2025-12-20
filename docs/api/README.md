# 📚 Documentación API - PartiturasApp

## Autenticación

### Registro de usuario
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "usuario@ejemplo.com",
  "password": "contraseña123",
  "nombre": "Nombre",
  "apellido": "Apellido"
}
