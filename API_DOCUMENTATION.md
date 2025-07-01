# ZeroWasteAI REST API Documentation

## Overview

**ZeroWasteAI** is a sophisticated food waste reduction platform that uses AI for food recognition and intelligent inventory management. The API follows Clean Architecture principles with Firebase Authentication + JWT security.

### Base Information
- **Base URL**: `http://localhost:3000`
- **Architecture**: Clean Architecture with Firebase Authentication + JWT
- **Version**: 1.0.0
- **Content-Type**: `application/json`
- **Authentication**: Firebase ID Token + JWT Bearer Token

### Key Features
🔥 **Firebase Authentication + JWT Security**  
👤 **User Profile Management**  
🤖 **AI Food Recognition with Image Generation**  
📦 **Smart Inventory Management**  
🍳 **AI Recipe Generation**  
📅 **Meal Planning System**  
📸 **Image Management & Upload**  
🛡️ **Enterprise Security Headers**  

---

## Authentication Endpoints

### 1. Firebase Sign-In
**Authenticates with Firebase and creates app-specific JWT tokens**

```http
POST /api/auth/firebase-signin
```

**Headers:**
```
Authorization: Bearer <firebase_id_token>
Content-Type: application/json
```

**Response:**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user": {
    "uid": "firebase_user_id",
    "email": "user@example.com",
    "name": "User Name",
    "picture": "https://...",
    "email_verified": true,
    "auth_provider": "password"
  },
  "expires_in": 3600
}
```

**Flow:**
1. Client sends Firebase ID token in Authorization header
2. Server validates token with Firebase
3. Server creates/updates user in local database
4. Server generates app-specific JWT tokens
5. Returns access + refresh tokens for subsequent requests

### 2. Refresh Token
**Rotates JWT tokens securely**

```http
POST /api/auth/refresh
```

**Headers:**
```
Authorization: Bearer <refresh_token>
Content-Type: application/json
```

**Response:**
```json
{
  "access_token": "new_jwt_token",
  "refresh_token": "new_refresh_token",
  "expires_in": 3600
}
```

**Flow:**
1. Client sends refresh token
2. Server validates and rotates tokens
3. Old tokens are blacklisted
4. New tokens returned

### 3. Logout
**Securely invalidates all user tokens**

```http
POST /api/auth/logout
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "message": "Logout successful",
  "tokens_invalidated": true
}
```

---

## User Profile Endpoints

### 1. Get User Profile
**Retrieves user profile from Firestore**

```http
GET /api/user/profile
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "uid": "00HkiYIBxoVGnIZQQ76S7dbM52E3",
  "displayName": "Carlos Primo",
  "email": "carlos@gm.co",
  "photoURL": null,
  "emailVerified": true,
  "authProvider": "password",
  "language": "es",
  "cookingLevel": "intermediate",
  "measurementUnit": "metric",
  "allergies": ["nuts", "dairy"],
  "allergyItems": ["almonds", "milk"],
  "preferredFoodTypes": ["vegetarian", "mediterranean"],
  "specialDietItems": [],
  "favoriteRecipes": [],
  "initialPreferencesCompleted": true,
  "createdAt": "2025-05-23T08:16:24Z",
  "lastLoginAt": "2025-05-23T08:16:25Z"
}
```

### 2. Update User Profile
**Updates user profile in Firestore**

```http
PUT /api/user/profile
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "displayName": "Updated Name",
  "language": "en",
  "cookingLevel": "advanced",
  "measurementUnit": "imperial",
  "allergies": ["nuts"],
  "allergyItems": ["peanuts"],
  "preferredFoodTypes": ["vegan"],
  "specialDietItems": ["gluten-free"],
  "initialPreferencesCompleted": true
}
```

**Response:**
```json
{
  "message": "Perfil actualizado exitosamente",
  "profile": {
    // Updated profile object
  }
}
```

---

## Food Recognition Endpoints

### 1. Hybrid Ingredient Recognition
**AI-powered ingredient recognition with async image generation**

```http
POST /api/recognition/ingredients
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "images_paths": [
    "uploads/user_images/image1.jpg",
    "uploads/user_images/image2.jpg"
  ]
}
```

**Response:**
```json
{
  "recognition_id": "uuid-123",
  "ingredients": [
    {
      "name": "Tomate",
      "quantity": 3,
      "type_unit": "unidades",
      "storage_type": "ambiente",
      "expiration_time": 5,
      "time_unit": "days",
      "tips": "Conservar en lugar fresco y seco",
      "image_path": null,
      "image_status": "generating",
      "added_at": "2025-01-20T10:00:00Z",
      "expiration_date": "2025-01-25T10:00:00Z"
    }
  ],
  "images": {
    "status": "generating",
    "task_id": "task-uuid-456",
    "check_images_url": "/api/recognition/images/status/task-uuid-456",
    "estimated_time": "20-40 segundos"
  },
  "allergy_alerts": [
    {
      "ingredient": "Tomate",
      "allergen": "nightshades",
      "severity": "warning",
      "message": "Este ingrediente puede contener alérgenos"
    }
  ],
  "message": "✅ Ingredientes reconocidos. Las imágenes se están generando en segundo plano."
}
```

**Flow:**
1. **Synchronous Phase**: AI analyzes images and returns ingredient data immediately
2. **Asynchronous Phase**: Image generation starts in background
3. **Response**: Immediate data + task ID for tracking image generation
4. **Image Completion**: Use status endpoint to check when images are ready

### 2. Complete Ingredient Recognition
**Full recognition with environmental impact and utilization ideas**

```http
POST /api/recognition/ingredients/complete
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "images_paths": [
    "uploads/user_images/vegetables.jpg"
  ]
}
```

**Response:**
```json
{
  "recognition_id": "uuid-789",
  "ingredients": [
    {
      "name": "Tomate",
      "quantity": 3,
      "type_unit": "unidades",
      "storage_type": "ambiente",
      "expiration_time": 5,
      "time_unit": "days",
      "tips": "Conservar en lugar fresco y seco",
      "image_path": "generated/tomato_reference.jpg",
      "environmental_impact": {
        "carbon_footprint": {
          "value": 1.2,
          "unit": "kg",
          "description": "CO2 equivalente"
        },
        "water_footprint": {
          "value": 15,
          "unit": "litros",
          "description": "agua necesaria"
        },
        "sustainability_message": "Los tomates locales reducen tu huella de carbono"
      },
      "utilization_ideas": [
        {
          "title": "Salsa de tomate casera",
          "description": "Aprovecha tomates maduros para hacer salsa",
          "type": "receta"
        },
        {
          "title": "Conservación en aceite",
          "description": "Preserva tomates en aceite de oliva",
          "type": "conservación"
        }
      ]
    }
  ]
}
```

### 3. Food Recognition
**Recognizes prepared dishes and meals**

```http
POST /api/recognition/foods
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "images_paths": [
    "uploads/user_images/dish.jpg"
  ]
}
```

**Response:**
```json
{
  "recognition_id": "uuid-food-123",
  "foods": [
    {
      "name": "Pasta con Salsa de Tomate",
      "quantity": 1,
      "type_unit": "porción",
      "estimated_calories": 450,
      "main_ingredients": ["pasta", "tomate", "aceite_oliva"],
      "expiration_time": 3,
      "time_unit": "days",
      "storage_recommendations": "Refrigerar después de enfriar",
      "image_path": null,
      "image_status": "generating"
    }
  ],
  "images": {
    "status": "generating",
    "task_id": "food-task-456",
    "check_images_url": "/api/recognition/images/status/food-task-456",
    "estimated_time": "20-40 segundos"
  }
}
```

### 4. Check Image Generation Status
**Monitor async image generation progress**

```http
GET /api/recognition/images/status/{task_id}
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "task_id": "task-uuid-456",
  "status": "completed", // "pending", "processing", "completed", "failed"
  "progress_percentage": 100,
  "current_step": "Generación completada",
  "created_at": "2025-01-20T10:00:00Z",
  "completed_at": "2025-01-20T10:00:35Z",
  "images_data": [
    {
      "ingredient_name": "Tomate",
      "image_path": "generated/references/tomate_ref_uuid.jpg",
      "generation_status": "ready"
    }
  ],
  "message": "🎉 Imágenes generadas exitosamente"
}
```

### 5. Get Recognition Images
**Retrieve recognition with updated image paths**

```http
GET /api/recognition/recognition/{recognition_id}/images
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "recognition_id": "uuid-123",
  "ingredients": [
    {
      "name": "Tomate",
      "image_path": "generated/references/tomate_ref_final.jpg",
      "image_status": "ready",
      // ... other ingredient data
    }
  ],
  "images_ready": true,
  "total_ingredients": 1,
  "images_generated": 1
}
``` 

---

## Inventory Management Endpoints

### 1. Add Ingredients to Inventory
**Batch add ingredients to user's inventory**

```http
POST /api/inventory/ingredients
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "ingredients": [
    {
      "name": "Tomate",
      "quantity": 3,
      "type_unit": "unidades",
      "storage_type": "ambiente",
      "expiration_date": "2025-01-25T10:00:00Z",
      "tips": "Conservar en lugar fresco y seco"
    },
    {
      "name": "Leche",
      "quantity": 1,
      "type_unit": "litros",
      "storage_type": "refrigerador",
      "expiration_date": "2025-01-30T23:59:59Z",
      "tips": "Mantener refrigerado"
    }
  ]
}
```

**Response:**
```json
{
  "message": "Ingredientes agregados exitosamente"
}
```

### 2. Get Basic Inventory
**Retrieve user's inventory with basic information**

```http
GET /api/inventory
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "ingredients": [
    {
      "name": "Tomate",
      "type_unit": "unidades",
      "storage_type": "ambiente",
      "tips": "Conservar en lugar fresco y seco",
      "image_path": "generated/tomato_ref.jpg",
      "stacks": [
        {
          "quantity": 3,
          "type_unit": "unidades",
          "expiration_date": "2025-01-25T10:00:00Z",
          "added_at": "2025-01-20T10:00:00Z"
        }
      ]
    }
  ],
  "food_items": []
}
```

### 3. Get Complete Inventory
**Retrieve enriched inventory with environmental impact and utilization ideas**

```http
GET /api/inventory/complete
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "ingredients": [
    {
      "name": "Tomate",
      "type_unit": "unidades",
      "storage_type": "ambiente",
      "tips": "Conservar en lugar fresco y seco",
      "image_path": "generated/tomato_ref.jpg",
      "stacks": [
        {
          "quantity": 3,
          "type_unit": "unidades",
          "expiration_date": "2025-01-25T10:00:00Z",
          "added_at": "2025-01-20T10:00:00Z"
        }
      ],
      "environmental_impact": {
        "carbon_footprint": {
          "value": 1.2,
          "unit": "kg",
          "description": "CO2"
        },
        "water_footprint": {
          "value": 15,
          "unit": "l",
          "description": "agua"
        },
        "sustainability_message": "Consume de manera responsable y evita el desperdicio."
      },
      "utilization_ideas": [
        {
          "title": "Salsa de tomate casera",
          "description": "Aprovecha tomates maduros para hacer salsa",
          "type": "receta"
        }
      ]
    }
  ],
  "food_items": [],
  "total_ingredients": 1,
  "enriched_with": ["environmental_impact", "utilization_ideas"]
}
```

### 4. Get Simple Inventory
**Lightweight inventory for quick access**

```http
GET /api/inventory/simple
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "ingredients": [
    {
      "name": "Tomate",
      "total_quantity": 3,
      "type_unit": "unidades",
      "earliest_expiration": "2025-01-25T10:00:00Z",
      "storage_type": "ambiente"
    }
  ]
}
```

### 5. Add Ingredients from Recognition
**Add ingredients directly from AI recognition results**

```http
POST /api/inventory/ingredients/from-recognition
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "ingredients": [
    {
      "name": "Tomate",
      "quantity": 3,
      "type_unit": "unidades",
      "storage_type": "ambiente",
      "expiration_time": 5,
      "time_unit": "days",
      "tips": "Conservar en lugar fresco y seco",
      "image_path": "generated/tomato_ref.jpg",
      "environmental_impact": {
        "carbon_footprint": {"value": 1.2, "unit": "kg", "description": "CO2"},
        "water_footprint": {"value": 15, "unit": "l", "description": "agua"}
      },
      "utilization_ideas": []
    }
  ]
}
```

**Response:**
```json
{
  "message": "Ingredientes agregados al inventario exitosamente",
  "processed_count": 1
}
```

### 6. Get Expiring Items
**Retrieve items close to expiration**

```http
GET /api/inventory/expiring?days=3
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `days` (optional): Number of days ahead to check (default: 7)

**Response:**
```json
{
  "expiring_ingredients": [
    {
      "name": "Tomate",
      "quantity": 3,
      "type_unit": "unidades",
      "expiration_date": "2025-01-23T10:00:00Z",
      "days_until_expiration": 2,
      "storage_type": "ambiente"
    }
  ],
  "expiring_foods": [],
  "total_expiring": 1
}
```

### 7. Update Ingredient Stack
**Update specific ingredient stack details**

```http
PUT /api/inventory/ingredients/{ingredient_name}/{added_at}
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Path Parameters:**
- `ingredient_name`: Name of ingredient (e.g., "Tomate")
- `added_at`: ISO timestamp when stack was added

**Request Body:**
```json
{
  "quantity": 5,
  "expiration_date": "2025-01-28T10:00:00Z"
}
```

**Response:**
```json
{
  "message": "Ingrediente actualizado exitosamente"
}
```

### 8. Update Ingredient Quantity
**Update only the quantity of an ingredient stack**

```http
PATCH /api/inventory/ingredients/{ingredient_name}/{added_at}/quantity
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "new_quantity": 5
}
```

**Response:**
```json
{
  "message": "Cantidad actualizada exitosamente",
  "ingredient_name": "Tomate",
  "old_quantity": 3,
  "new_quantity": 5
}
```

### 9. Delete Ingredient Stack
**Delete a specific ingredient stack**

```http
DELETE /api/inventory/ingredients/{ingredient_name}/{added_at}
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "message": "Stack de ingrediente eliminado exitosamente",
  "ingredient_deleted": false,
  "remaining_stacks": 2
}
```

### 10. Delete Complete Ingredient
**Delete all stacks of an ingredient**

```http
DELETE /api/inventory/ingredients/{ingredient_name}
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "message": "Ingrediente eliminado completamente del inventario",
  "ingredient_name": "Tomate",
  "stacks_deleted": 3
}
```

### 11. Mark Ingredient Consumed
**Mark ingredient stack as consumed with consumption details**

```http
POST /api/inventory/ingredients/{ingredient_name}/{added_at}/consume
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "consumed_quantity": 2,
  "consumption_reason": "Preparé salsa de tomate",
  "recipe_used": "Salsa de tomate casera"
}
```

**Response:**
```json
{
  "message": "Ingrediente marcado como consumido exitosamente",
  "consumption_data": {
    "ingredient_name": "Tomate",
    "consumed_quantity": 2,
    "remaining_quantity": 1,
    "consumption_reason": "Preparé salsa de tomate",
    "recipe_used": "Salsa de tomate casera",
    "consumed_at": "2025-01-20T15:30:00Z"
  }
}
```

### 12. Get Ingredient Detail
**Get detailed information about a specific ingredient**

```http
GET /api/inventory/ingredients/{ingredient_name}/detail
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "name": "Tomate",
  "type_unit": "unidades",
  "storage_type": "ambiente",
  "tips": "Conservar en lugar fresco y seco",
  "image_path": "generated/tomato_ref.jpg",
  "total_quantity": 5,
  "total_stacks": 2,
  "stacks": [
    {
      "quantity": 3,
      "expiration_date": "2025-01-25T10:00:00Z",
      "added_at": "2025-01-20T10:00:00Z",
      "days_until_expiration": 5
    }
  ]
}
```

### 13. Get Ingredients List
**Get simplified list of all ingredient names**

```http
GET /api/inventory/ingredients/list
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "ingredients": ["Tomate", "Leche", "Pan", "Huevos"],
  "count": 4
}
```

### 14. Upload Inventory Image
**Upload reference image for inventory items**

```http
POST /api/inventory/upload_image
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

**Form Data:**
- `image`: Image file (JPG, PNG, GIF, WEBP, max 10MB)
- `item_name`: Name of the item
- `image_type`: Type of image (food/ingredient/default)

**Response:**
```json
{
  "message": "Imagen subida exitosamente",
  "image_data": {
    "item_name": "Tomate",
    "image_path": "uploads/inventory/tomate_user_ref.jpg",
    "storage_path": "inventory_images/uuid.jpg"
  }
}
```

### 15. Add Single Item to Inventory
**Add individual item with advanced options**

```http
POST /api/inventory/add_item
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "item_type": "ingredient",
  "item_data": {
    "name": "Aguacate",
    "quantity": 2,
    "type_unit": "unidades",
    "storage_type": "ambiente",
    "expiration_date": "2025-01-22T23:59:59Z",
    "tips": "Presionar suavemente para verificar madurez"
  }
}
```

**Response:**
```json
{
  "message": "Item agregado al inventario exitosamente",
  "item": {
    "name": "Aguacate",
    "quantity": 2,
    "type_unit": "unidades",
    "added_at": "2025-01-20T10:00:00Z"
  }
}
``` 

---

## Recipe Management Endpoints

### 1. Generate Recipes from Inventory
**AI-generated recipes based on user's inventory**

```http
POST /api/recipes/generate-from-inventory
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Response:**
```json
{
  "generated_recipes": [
    {
      "title": "Pasta con Tomate y Albahaca",
      "description": "Una deliciosa pasta italiana con tomates frescos",
      "ingredients": [
        {
          "name": "Tomate",
          "quantity": 2,
          "unit": "unidades",
          "from_inventory": true
        },
        {
          "name": "Pasta",
          "quantity": 200,
          "unit": "gramos",
          "from_inventory": false
        }
      ],
      "instructions": [
        "Hervir agua con sal para la pasta",
        "Cortar los tomates en cubos pequeños",
        "Sofreír tomates con aceite de oliva",
        "Cocinar pasta al dente",
        "Mezclar pasta con salsa de tomate"
      ],
      "prep_time": 15,
      "cook_time": 20,
      "servings": 2,
      "difficulty": "fácil",
      "category": "pasta",
      "nutritional_info": {
        "calories": 450,
        "protein": 12,
        "carbs": 65,
        "fat": 8
      },
      "image_path": null,
      "image_status": "generating",
      "generated_at": "2025-01-20T10:00:00Z"
    }
  ],
  "total_recipes": 1,
  "inventory_utilization": {
    "ingredients_used": 1,
    "total_inventory_items": 5,
    "utilization_percentage": 20
  },
  "images": {
    "status": "generating",
    "task_id": "recipe-task-789",
    "check_images_url": "/api/generation/images/status/recipe-task-789",
    "estimated_time": "15-30 segundos"
  }
}
```

### 2. Generate Custom Recipes
**Generate recipes with specific ingredients and preferences**

```http
POST /api/recipes/generate-custom
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "ingredients": [
    "Pollo",
    "Arroz",
    "Pimiento"
  ],
  "preferences": [
    "bajo en sodio",
    "sin gluten"
  ],
  "num_recipes": 2,
  "recipe_categories": [
    "principal",
    "saludable"
  ]
}
```

**Response:**
```json
{
  "generated_recipes": [
    {
      "title": "Arroz con Pollo al Pimiento",
      "description": "Plato saludable y libre de gluten",
      "ingredients": [
        {
          "name": "Pollo",
          "quantity": 300,
          "unit": "gramos"
        },
        {
          "name": "Arroz",
          "quantity": 1,
          "unit": "taza"
        }
      ],
      "instructions": [
        "Cortar el pollo en trozos medianos",
        "Sofreír pollo hasta dorar",
        "Agregar arroz y caldo",
        "Cocinar a fuego lento 18 minutos"
      ],
      "prep_time": 15,
      "cook_time": 30,
      "servings": 2,
      "difficulty": "intermedio",
      "dietary_info": ["sin gluten", "bajo en sodio"],
      "image_path": null,
      "image_status": "generating"
    }
  ],
  "images": {
    "status": "generating",
    "task_id": "custom-recipe-456",
    "estimated_time": "15-30 segundos"
  }
}
```

### 3. Save Recipe
**Save a generated or custom recipe to user's collection**

```http
POST /api/recipes/save
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "Pasta con Tomate y Albahaca",
  "description": "Una deliciosa pasta italiana con tomates frescos",
  "ingredients": [
    {
      "name": "Tomate",
      "quantity": 2,
      "unit": "unidades"
    }
  ],
  "instructions": [
    "Hervir agua con sal para la pasta",
    "Cortar los tomates en cubos pequeños"
  ],
  "prep_time": 15,
  "cook_time": 20,
  "servings": 2,
  "difficulty": "fácil",
  "category": "pasta",
  "image_path": "generated/pasta_tomato.jpg"
}
```

**Response:**
```json
{
  "message": "Receta guardada exitosamente",
  "recipe": {
    "uid": "recipe-uuid-123",
    "title": "Pasta con Tomate y Albahaca",
    "saved_at": "2025-01-20T10:00:00Z",
    // ... other recipe data
  }
}
```

### 4. Get Saved Recipes
**Retrieve user's saved recipes**

```http
GET /api/recipes/saved
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "recipes": [
    {
      "uid": "recipe-uuid-123",
      "title": "Pasta con Tomate y Albahaca",
      "description": "Una deliciosa pasta italiana",
      "prep_time": 15,
      "cook_time": 20,
      "servings": 2,
      "difficulty": "fácil",
      "category": "pasta",
      "image_path": "generated/pasta_tomato.jpg",
      "saved_at": "2025-01-20T10:00:00Z"
    }
  ],
  "count": 1
}
```

### 5. Get All Recipes
**Retrieve all available recipes (public + user's)**

```http
GET /api/recipes/all
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "recipes": [
    // Array of all recipes
  ],
  "count": 50
}
```

### 6. Delete Recipe
**Delete a user's saved recipe**

```http
DELETE /api/recipes/delete
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "Pasta con Tomate y Albahaca"
}
```

**Response:**
```json
{
  "message": "Receta 'Pasta con Tomate y Albahaca' eliminada exitosamente"
}
```

---

## Meal Planning Endpoints

### 1. Save Meal Plan
**Save meal plan for a specific date**

```http
POST /api/planning/save
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "date": "2025-01-25",
  "meals": {
    "breakfast": {
      "recipe_title": "Tostadas con Aguacate",
      "ingredients_needed": [
        {
          "name": "Pan",
          "quantity": 2,
          "unit": "rebanadas"
        },
        {
          "name": "Aguacate",
          "quantity": 1,
          "unit": "unidad"
        }
      ],
      "prep_time": 10,
      "calories": 350
    },
    "lunch": {
      "recipe_title": "Pasta con Tomate y Albahaca",
      "ingredients_needed": [
        {
          "name": "Tomate",
          "quantity": 2,
          "unit": "unidades"
        }
      ],
      "prep_time": 20,
      "calories": 450
    },
    "dinner": {
      "recipe_title": "Ensalada Verde",
      "ingredients_needed": [
        {
          "name": "Lechuga",
          "quantity": 1,
          "unit": "cabeza"
        }
      ],
      "prep_time": 5,
      "calories": 120
    }
  }
}
```

**Response:**
```json
{
  "message": "Plan de comidas guardado exitosamente",
  "meal_plan": {
    "uid": "plan-uuid-456",
    "date": "2025-01-25",
    "total_calories": 920,
    "meals": {
      // ... meal details
    },
    "created_at": "2025-01-20T10:00:00Z"
  }
}
```

### 2. Update Meal Plan
**Update existing meal plan**

```http
PUT /api/planning/update
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "date": "2025-01-25",
  "meals": {
    // Updated meal structure
  }
}
```

**Response:**
```json
{
  "message": "Plan de comidas actualizado exitosamente",
  "meal_plan": {
    // Updated meal plan data
  }
}
```

### 3. Get Meal Plan by Date
**Retrieve meal plan for specific date**

```http
GET /api/planning/get?date=2025-01-25
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `date`: Date in YYYY-MM-DD format

**Response:**
```json
{
  "meal_plan": {
    "uid": "plan-uuid-456",
    "date": "2025-01-25",
    "meals": {
      "breakfast": {
        "recipe_title": "Tostadas con Aguacate",
        "ingredients_needed": [],
        "prep_time": 10,
        "calories": 350
      },
      "lunch": {},
      "dinner": {}
    },
    "total_calories": 920,
    "created_at": "2025-01-20T10:00:00Z"
  }
}
```

### 4. Get All Meal Plans
**Retrieve all user's meal plans**

```http
GET /api/planning/all
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "meal_plans": [
    {
      "uid": "plan-uuid-456",
      "date": "2025-01-25",
      "total_calories": 920,
      // ... plan details
    }
  ]
}
```

### 5. Get Meal Plan Dates
**Get list of dates with existing meal plans**

```http
GET /api/planning/dates
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "dates": [
    "2025-01-25",
    "2025-01-26",
    "2025-01-27"
  ]
}
```

### 6. Delete Meal Plan
**Delete meal plan for specific date**

```http
DELETE /api/planning/delete?date=2025-01-25
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `date`: Date in YYYY-MM-DD format

**Response:**
```json
{
  "message": "Plan de comidas del 2025-01-25 eliminado exitosamente."
}
``` 

---

## Image Management Endpoints

### 1. Upload Image
**Upload image files to Firebase Storage**

```http
POST /api/image_management/upload_image
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

**Form Data:**
- `image`: Image file (JPG, PNG, GIF, WEBP, max 10MB)
- `item_name`: Name/description of the item in the image
- `image_type`: Type of image (food/ingredient/default)

**Response:**
```json
{
  "message": "Image uploaded successfully",
  "image": {
    "uid": "img-uuid-123",
    "name": "banana",
    "image_path": "https://storage.googleapis.com/bucket/uploads/food/abc123.jpg",
    "image_type": "food",
    "storage_path": "uploads/food/abc123.jpg"
  }
}
```

### 2. Assign Image Reference
**Assign reference image to an item**

```http
POST /api/image_management/assign_image
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "item_name": "Tomate"
}
```

**Response:**
```json
{
  "uid": "ref-uuid-456",
  "name": "Tomate",
  "image_path": "references/tomate_ref.jpg",
  "image_type": "ingredient"
}
```

### 3. Search Similar Images
**Find similar reference images for an item**

```http
POST /api/image_management/search_similar_images
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "item_name": "Tomate"
}
```

**Response:**
```json
[
  {
    "uid": "ref-1",
    "name": "Tomate Cherry",
    "image_path": "references/cherry_tomato.jpg",
    "similarity_score": 0.95
  },
  {
    "uid": "ref-2",
    "name": "Tomate Roma",
    "image_path": "references/roma_tomato.jpg",
    "similarity_score": 0.89
  }
]
```

---

## Generation Status Endpoints

### 1. Check Recipe Image Generation Status
**Monitor recipe image generation progress**

```http
GET /api/generation/images/status/{task_id}
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "task_id": "recipe-task-789",
  "status": "completed",
  "progress_percentage": 100,
  "current_step": "Generación completada",
  "created_at": "2025-01-20T10:00:00Z",
  "completed_at": "2025-01-20T10:00:25Z",
  "images_data": [
    {
      "recipe_title": "Pasta con Tomate y Albahaca",
      "image_path": "generated/recipes/pasta_tomato_final.jpg",
      "generation_status": "ready"
    }
  ],
  "message": "🎉 Imágenes generadas exitosamente"
}
```

### 2. Get Generation Images
**Retrieve generated images for a specific generation**

```http
GET /api/generation/{generation_id}/images
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "generation_id": "gen-uuid-456",
  "recipes": [
    {
      "title": "Pasta con Tomate y Albahaca",
      "image_path": "generated/recipes/pasta_final.jpg",
      "image_status": "ready"
    }
  ],
  "images_ready": true,
  "total_recipes": 1,
  "images_generated": 1,
  "last_updated": "2025-01-20T10:00:00Z",
  "message": "✅ Todas las imágenes están listas"
}
```

---

## Admin Endpoints

### 1. Cleanup Expired Tokens
**Internal endpoint to clean expired security tokens**

```http
POST /api/admin/cleanup-tokens
```

**Headers:**
```
X-Internal-Secret: <internal_secret>
```

**Response:**
```json
{
  "message": "Token cleanup completed successfully",
  "cleaned": {
    "blacklist_cleaned": 15,
    "tracking_cleaned": 8
  }
}
```

### 2. Get Security Stats
**Internal endpoint for security statistics**

```http
GET /api/admin/security-stats
```

**Headers:**
```
X-Internal-Secret: <internal_secret>
```

**Response:**
```json
{
  "security_stats": {
    "blacklisted_tokens": 25,
    "active_refresh_tokens": 12,
    "used_refresh_tokens": 45,
    "total_refresh_tokens": 57
  }
}
```

---

## Error Handling

### Standard Error Response Format
All endpoints return consistent error responses:

```json
{
  "error": "Error message description",
  "error_type": "InvalidRequestDataException",
  "details": {
    "field_name": ["Validation error message"]
  },
  "status_code": 400
}
```

### Common HTTP Status Codes

| Code | Description | When |
|------|-------------|------|
| `200` | Success | Successful GET, PUT, PATCH |
| `201` | Created | Successful POST |
| `400` | Bad Request | Invalid request data, validation errors |
| `401` | Unauthorized | Missing or invalid authentication token |
| `403` | Forbidden | Valid token but insufficient permissions |
| `404` | Not Found | Resource doesn't exist |
| `409` | Conflict | Resource already exists |
| `422` | Unprocessable Entity | Valid JSON but business logic error |
| `429` | Too Many Requests | Rate limit exceeded |
| `500` | Internal Server Error | Unexpected server error |

### Error Examples

**Validation Error (400):**
```json
{
  "error": "Validation failed",
  "details": {
    "ingredients": ["This field is required"],
    "quantity": ["Must be a positive number"]
  }
}
```

**Authentication Error (401):**
```json
{
  "error": "Invalid or expired token"
}
```

**Rate Limit Error (429):**
```json
{
  "error": "Rate limit exceeded",
  "retry_after": 60
}
```

---

## Security Features

### Authentication Flow
1. **Firebase Authentication**: Users authenticate with Firebase (Google, email/password, etc.)
2. **Token Exchange**: Firebase ID token exchanged for app-specific JWT tokens
3. **Token Rotation**: Refresh tokens automatically rotate for security
4. **Token Blacklisting**: Used tokens are blacklisted to prevent reuse

### Security Headers
All responses include security headers:
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`
- `Strict-Transport-Security: max-age=31536000`

### Rate Limiting
- **Authentication endpoints**: 5 requests per minute
- **General API endpoints**: 100 requests per minute
- **Refresh token**: 10 requests per minute

---

## Common Workflows

### 1. Complete Food Recognition & Inventory Flow
```
1. POST /api/image_management/upload_image (upload food images)
2. POST /api/recognition/ingredients (recognize ingredients)
3. GET /api/recognition/images/status/{task_id} (check image generation)
4. POST /api/inventory/ingredients/from-recognition (add to inventory)
5. GET /api/inventory/complete (view enriched inventory)
```

### 2. Recipe Generation & Planning Flow
```
1. GET /api/inventory/simple (check available ingredients)
2. POST /api/recipes/generate-from-inventory (generate recipes)
3. GET /api/generation/images/status/{task_id} (check recipe images)
4. POST /api/recipes/save (save favorite recipe)
5. POST /api/planning/save (create meal plan)
```

### 3. Inventory Management Flow
```
1. GET /api/inventory (view current inventory)
2. GET /api/inventory/expiring?days=3 (check expiring items)
3. POST /api/inventory/ingredients/{name}/{date}/consume (mark consumed)
4. PATCH /api/inventory/ingredients/{name}/{date}/quantity (update quantities)
5. DELETE /api/inventory/ingredients/{name} (remove expired items)
```

---

## API Architecture

### Clean Architecture Layers
1. **Interface Layer**: Controllers and serializers (`src/interface/`)
2. **Application Layer**: Use cases and services (`src/application/`)
3. **Domain Layer**: Business entities and rules (`src/domain/`)
4. **Infrastructure Layer**: External services and data (`src/infrastructure/`)

### Key Technologies
- **Framework**: Flask with Blueprint organization
- **Authentication**: Firebase Authentication + JWT
- **Database**: MySQL with SQLAlchemy ORM
- **Storage**: Firebase Cloud Storage
- **AI Services**: Google Gemini API
- **Background Tasks**: Custom async task system
- **Documentation**: Swagger/OpenAPI

### Data Models
- **Users**: Firebase UID-based with MySQL sync
- **Inventory**: Stack-based ingredient management
- **Recipes**: AI-generated with nutritional info
- **Recognition**: AI analysis with image generation
- **Planning**: Date-based meal organization

---

## Development Information

### Base URLs
- **Development**: `http://localhost:3000`
- **Production**: `https://your-domain.com`

### Database Status
Check API health and database connection:
```http
GET /status
```

### API Documentation
Interactive Swagger documentation available at:
```
GET /apidocs
```

### Welcome Endpoint
API information and feature overview:
```http
GET /
```

---

## Support & Contact

**Team**: ZeroWasteAI Development Team  
**Mission**: Reducir el desperdicio alimentario a través de tecnología IA  
**Contact**: Desarrollado con ❤️ para un futuro más sustentable 🌍

For technical support or questions about this API, please refer to the development team. 