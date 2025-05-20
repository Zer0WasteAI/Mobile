# Verificación de Correo Electrónico - Flujo de Prueba

Este documento detalla el flujo de verificación de correo electrónico implementado en la aplicación.

## 1. Flujo de registro

1. El usuario completa el formulario de registro con email/contraseña
2. Al hacer clic en "Registrar", se crea la cuenta en Firebase Auth
3. Se envía automáticamente un correo de verificación al email del usuario
4. El usuario es desconectado (se cierra su sesión)
5. Se redirige al usuario a la pantalla `EmailVerificationScreen`

## 2. Pantalla de verificación de correo

En la pantalla de verificación, el usuario tiene dos opciones:

1. **Ya verifiqué mi correo**: 
   - La aplicación verifica si el email ha sido verificado
   - Si está verificado, redirige al usuario a la pantalla de login
   - Si no está verificado, muestra un mensaje de error

2. **Reenviar correo de verificación**:
   - Envía un nuevo correo de verificación al usuario
   - Muestra un mensaje de confirmación

## 3. Flujo de inicio de sesión

1. El usuario introduce sus credenciales en la pantalla de login
2. Al hacer clic en "Iniciar sesión", se verifica:
   - Si el usuario usa email/contraseña (no redes sociales)
   - Si el email está verificado

3. Si el email no está verificado:
   - Se muestra el diálogo `EmailVerificationDialog`
   - Al confirmar, el usuario es desconectado y redirigido a `EmailVerificationScreen`

4. Si el email está verificado o usa otro método de autenticación:
   - Se verifica si es primera vez (para el flujo de onboarding)
   - Se redirige al Home o al onboarding según corresponda

## 4. Rutas registradas

- Se agregó la ruta `/email-verification` que muestra la pantalla de verificación
- Se agregó la constante `emailVerificationRouteName` para referirse a esta ruta

## 5. Verificación del sistema

Para verificar que el sistema funciona correctamente:

1. Registrar un nuevo usuario con email/contraseña
2. Comprobar que se redirige a la pantalla de verificación
3. Sin verificar, intentar iniciar sesión con el mismo usuario
4. Comprobar que se muestra el diálogo de verificación pendiente
5. Verificar el correo haciendo clic en el enlace recibido
6. Volver a la app e iniciar sesión
7. Comprobar que ahora permite el acceso correctamente
