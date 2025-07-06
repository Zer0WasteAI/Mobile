# Profile Module Documentation

## 🎉 **BACKEND INTEGRATION COMPLETED** ✅

### **Overview**
El módulo de perfil ahora tiene **integración completa con el backend** ZeroWasteAI API, proporcionando sincronización bidireccional entre Firestore y el backend MySQL.

### **Arquitectura**
- **Frontend**: UI completa con 19 pantallas
- **Backend**: API REST con endpoints `/api/user/profile`
- **Almacenamiento**: Híbrido Firestore + MySQL
- **Sincronización**: Automática con indicadores de estado

---

## 🚀 **Funcionalidades Implementadas**

### **1. Provider Principal** ✅
- **`userProfileProvider`**: Gestión completa del perfil
- **Backend sync**: Sincronización automática con API
- **Estado en tiempo real**: Loading, saving, error states
- **Indicador de sincronización**: Backend vs solo local

### **2. Gestión de Preferencias** ✅
- **Nivel de cocina**: Principiante, Intermedio, Avanzado
- **Tipos de comida**: Selección múltiple con persistencia
- **Alergias**: Lista personalizable con emojis
- **Dietas especiales**: Vegetariana, vegana, keto, etc.
- **Configuración**: Idioma, unidades de medida

### **3. UI Completamente Funcional** ✅
- **Pantalla principal**: Datos reales del usuario
- **Edición de perfil**: Nombre, foto, información básica
- **Selectores de preferencias**: UI completa para cada categoría
- **Configuración**: Idioma, unidades, notificaciones
- **Información y ayuda**: FAQs, términos, privacidad

---

## 📊 **Estructura de Datos**

### **UserPreferencesModel**
```dart
class UserPreferencesModel {
  final String language;           // 'es', 'en'
  final String measurementUnit;    // 'metric', 'imperial'
  final String? cookingLevel;      // 'beginner', 'intermediate', 'advanced'
  final List<String> allergies;    // ['gluten', 'lactose', ...]
  final List<String> specialDiets; // ['vegetarian', 'vegan', ...]
  final List<String> preferredFoodTypes; // ['italian', 'mexican', ...]
  
  // Structured data for rich UI
  final List<Map<String, dynamic>> allergyItems;
  final List<Map<String, dynamic>> specialDietItems;
  final List<Map<String, dynamic>> preferredFoodTypeItems;
}
```

### **Backend API Structure**
```json
{
  "uid": "firebase_user_id",
  "email": "user@example.com",
  "name": "User Name",
  "photo_url": "https://example.com/photo.jpg",
  "phone": "+1234567890",
  "prefs": {
    "language": "es",
    "measurementUnit": "metric",
    "cookingLevel": "intermediate",
    "allergies": ["gluten", "lactose"],
    "specialDiets": ["vegetarian"],
    "preferredFoodTypes": ["italian", "mexican"]
  }
}
```

---

## 🔧 **Uso del Provider**

### **Acceder a Datos del Perfil**
```dart
// Estado completo del perfil
final profileState = ref.watch(userProfileProvider);
final user = profileState.user;
final isLoading = profileState.isLoading;
final isBackendSynced = profileState.isBackendSynced;

// Solo las preferencias
final userPrefs = ref.watch(userPreferencesProvider);
final cookingLevel = userPrefs.cookingLevel;
final allergies = userPrefs.allergies;
```

### **Actualizar Preferencias**
```dart
final profileNotifier = ref.read(userProfileProvider.notifier);

// Actualizar nivel de cocina
await profileNotifier.updateCookingLevel('advanced');

// Actualizar alergias
await profileNotifier.updateAllergies(['gluten', 'nuts']);

// Actualizar perfil básico
await profileNotifier.updateBasicProfile(
  displayName: 'Nuevo Nombre',
  photoURL: 'https://nueva-foto.jpg',
);
```

### **Gestión de Estado**
```dart
// Loading states
ref.listen(userProfileProvider, (previous, next) {
  if (next.isLoading) {
    showLoadingSnackBar(context);
  } else if (next.error != null) {
    showErrorSnackBar(context, next.error!);
  } else if (next.isSaving) {
    showSavingSnackBar(context);
  }
});
```

---

## 🔄 **Sincronización Dual**

### **Firestore + Backend MySQL**
- **Escritura**: Actualiza ambos sistemas
- **Lectura**: Prioriza backend, fallback a Firestore
- **Consistencia**: Indicador visual de estado de sync
- **Offline**: Funciona con solo Firestore

### **Indicadores de Estado**
- 🟢 **"Sincronizado"**: Datos en backend y Firestore
- 🟠 **"Solo local"**: Solo en Firestore, pendiente sync
- 🔴 **Error**: Problema de sincronización

---

## 📱 **Pantallas Implementadas**

### **Principales**
- ✅ `ProfileScreen` - Vista principal con datos reales
- ✅ `EditProfileScreen` - Edición de información básica
- ✅ `ProfileCookingLevelSelectorScreen` - Nivel de cocina
- ✅ `ProfilePreferredFoodTypeScreen` - Tipos de comida
- ✅ `ProfileAllergySelectorScreen` - Gestión de alergias
- ✅ `ProfileSpecialDietSelectorScreen` - Dietas especiales

### **Configuración**
- ✅ `LanguageScreen` - Selección de idioma
- ✅ `UnitsScreen` - Unidades de medida
- ✅ `NotificationsScreen` - Configuración de notificaciones

### **Información**
- ✅ `SupportScreen` - Soporte y ayuda
- ✅ `FaqsScreen` - Preguntas frecuentes
- ✅ `TermsAndConditionsScreen` - Términos y condiciones
- ✅ `PrivacyPolicyScreen` - Política de privacidad
- ✅ `AboutAppScreen` - Información de la app

---

## 🔗 **Integración con Otros Módulos**

### **Autenticación**
- Usa `authRepositoryProvider` para operaciones Firebase
- Sincroniza tokens JWT para API calls
- Mantiene consistencia entre auth y perfil

### **Inventario**
- Las preferencias afectan recomendaciones
- Alergias filtran ingredientes peligrosos
- Dietas influyen en sugerencias de recetas

### **Recetas**
- Nivel de cocina determina complejidad
- Tipos de comida preferidos influyen en AI
- Alergias excluyen ingredientes automáticamente

---

## 🚀 **APIs del Backend Usadas**

### **Endpoints**
- `GET /api/user/profile` - Obtener perfil completo
- `PUT /api/user/profile` - Actualizar perfil y preferencias

### **Autenticación**
- Headers: `Authorization: Bearer <jwt_token>`
- Auto-refresh de tokens cuando expiran
- Manejo de errores 401/403

---

## 🛠️ **Próximas Mejoras**

### **Funcionalidades Avanzadas** 🔮
- Backup/restore de preferencias
- Importar preferencias de otros usuarios
- Recomendaciones inteligentes basadas en perfil
- Sincronización entre dispositivos
- Modo offline avanzado

### **UI/UX** 🎨
- Animaciones de transición
- Temas personalizables
- Accesibilidad mejorada
- Modo oscuro
- Widgets personalizables

---

## 🔍 **Testing y Debug**

### **Estados a Verificar**
- ✅ Loading inicial del perfil
- ✅ Sincronización backend exitosa
- ✅ Manejo de errores de red
- ✅ Persistencia offline
- ✅ Actualización de preferencias

### **Debug Tools**
```dart
// Verificar estado de sincronización
final isBackendSynced = ref.read(isBackendSyncedProvider);
print('Backend synced: $isBackendSynced');

// Forzar refresh desde backend
await ref.read(userProfileProvider.notifier).refresh();
```

---

## 📈 **Métricas de Uso**

### **Datos Rastreables**
- Preferencias más comunes
- Tiempo en configuración inicial
- Tasa de completación de perfil
- Frecuencia de cambios de preferencias

### **Analytics** (Próximamente)
- Heatmap de preferencias
- Correlación preferencias-uso de app
- Abandono en configuración inicial

---

## 💡 **Consejos de Desarrollo**

### **Best Practices**
1. **Siempre verificar `isBackendSynced`** antes de operaciones críticas
2. **Usar providers específicos** (`userPreferencesProvider`) para mejor performance
3. **Manejar estados de loading** para mejor UX
4. **Fallback a Firestore** si backend falla
5. **Validar datos** antes de enviar al backend

### **Debugging**
- Usar `DEBUG_PROFILE = true` para logs detallados
- Verificar tokens JWT válidos
- Comprobar conectividad de red
- Revisar estructura de datos en Firestore vs Backend

---

**¡El módulo de perfil está completamente integrado y listo para producción!** 🎉✨ 