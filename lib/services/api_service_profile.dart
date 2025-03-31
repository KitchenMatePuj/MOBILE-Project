import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/user_model.dart';

class ApiServiceProfile {
  static const String _baseUrl = 'http://localhost:8001';

  // Profiles
  Future<bool> createProfile(String firstName, String lastName, String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/profiles/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'keycloak_user_id': '12', // Placeholder value
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': '21312', // Default to empty string
        'account_status': 'active', // Default to 'active'
        'profile_photo': 'dawdadwa', // Default to empty string
        'cooking_time': 0, // Default to zero
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create profile: ${response.body}');
      return false;
    }
  }

  Future<UserModel?> getProfileByKeycloak(int keycloakUserId) async {
    final response = await http.get(Uri.parse('$_baseUrl/profiles/$keycloakUserId'));

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to get profile: ${response.body}');
      return null;
    }
  }

  Future<List<dynamic>> listProfiles() async {
    final response = await http.get(Uri.parse('$_baseUrl/profiles/'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to list profiles: ${response.body}');
      return [];
    }
  }

  /*Future<dynamic> getProfileByKeycloak(String keycloakUserId) async {
    final response = await http.get(Uri.parse('$_baseUrl/profiles/$keycloakUserId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to get profile: ${response.body}');
      return null;
    }
  }*/

  Future<bool> updateProfileByKeycloak(String keycloakUserId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/profiles/$keycloakUserId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update profile: ${response.body}');
      return false;
    }
  }

  Future<bool> deleteProfileByKeycloak(String keycloakUserId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/profiles/$keycloakUserId'));

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to delete profile: ${response.body}');
      return false;
    }
  }

  Future<dynamic> getProfileSummaryByKeycloakUserId(String keycloakUserId) async {
    final response = await http.get(Uri.parse('$_baseUrl/profiles/summary/$keycloakUserId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to get profile summary: ${response.body}');
      return null;
    }
  }

  // Follow
  Future<bool> createFollow(int followerId, int followedId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/follows/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'follower_id': followerId,
        'followed_id': followedId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create follow: ${response.body}');
      return false;
    }
  }

  Future<bool> deleteFollow(int followerId, int followedId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/follows/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'follower_id': followerId,
        'followed_id': followedId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to delete follow: ${response.body}');
      return false;
    }
  }

  Future<List<dynamic>> listFollowers(int profileId) async {
    final response = await http.get(Uri.parse('$_baseUrl/follows/followers/$profileId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to list followers: ${response.body}');
      return [];
    }
  }

  Future<List<dynamic>> listFollowed(int profileId) async {
    final response = await http.get(Uri.parse('$_baseUrl/follows/followed/$profileId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to list followed: ${response.body}');
      return [];
    }
  }

  // Ingredient
  Future<bool> createIngredient(int shoppingListId, String ingredientName, String measurementUnit, String quantity) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/ingredients/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'shopping_list_id': shoppingListId,
        'ingredient_name': ingredientName,
        'measurement_unit': measurementUnit,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create ingredient: ${response.body}');
      return false;
    }
  }

  Future<dynamic> getIngredient(int ingredientId) async {
    final response = await http.get(Uri.parse('$_baseUrl/ingredients/$ingredientId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to get ingredient: ${response.body}');
      return null;
    }
  }

  Future<bool> updateIngredient(int ingredientId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/ingredients/$ingredientId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update ingredient: ${response.body}');
      return false;
    }
  }

  Future<bool> deleteIngredient(int ingredientId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/ingredients/$ingredientId'));

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to delete ingredient: ${response.body}');
      return false;
    }
  }

  Future<List<dynamic>> listIngredients(int shoppingListId) async {
    final response = await http.get(Uri.parse('$_baseUrl/ingredients/shopping_list/$shoppingListId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to list ingredients: ${response.body}');
      return [];
    }
  }

  // Ingredient Allergy
  Future<bool> createAllergy(int profileId, String allergyName) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/ingredient_allergies/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'profile_id': profileId,
        'allergy_name': allergyName,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create allergy: ${response.body}');
      return false;
    }
  }

  Future<dynamic> getAllergy(int allergyId) async {
    final response = await http.get(Uri.parse('$_baseUrl/ingredient_allergies/$allergyId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to get allergy: ${response.body}');
      return null;
    }
  }

  Future<bool> updateAllergy(int allergyId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/ingredient_allergies/$allergyId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update allergy: ${response.body}');
      return false;
    }
  }

  Future<bool> deleteAllergy(int allergyId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/ingredient_allergies/$allergyId'));

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to delete allergy: ${response.body}');
      return false;
    }
  }

  Future<List<dynamic>> listAllergies(int profileId) async {
    final response = await http.get(Uri.parse('$_baseUrl/ingredient_allergies/profile/$profileId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to list allergies: ${response.body}');
      return [];
    }
  }

  // Shopping List
  Future<bool> createShoppingList(int profileId, String recipeName, String recipePhoto) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/shopping_lists/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'profile_id': profileId,
        'recipe_name': recipeName,
        'recipe_photo': recipePhoto,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create shopping list: ${response.body}');
      return false;
    }
  }

  Future<dynamic> getShoppingList(int shoppingListId) async {
    final response = await http.get(Uri.parse('$_baseUrl/shopping_lists/$shoppingListId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to get shopping list: ${response.body}');
      return null;
    }
  }

  Future<bool> updateShoppingList(int shoppingListId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/shopping_lists/$shoppingListId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update shopping list: ${response.body}');
      return false;
    }
  }

  Future<bool> deleteShoppingList(int shoppingListId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/shopping_lists/$shoppingListId'));

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to delete shopping list: ${response.body}');
      return false;
    }
  }

  Future<List<dynamic>> listShoppingLists(int profileId) async {
    final response = await http.get(Uri.parse('$_baseUrl/shopping_lists/profile/$profileId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to list shopping lists: ${response.body}');
      return [];
    }
  }

  // Saved Recipe
  Future<bool> createSavedRecipe(int profileId, int recipeId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/saved_recipes/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'profile_id': profileId,
        'recipe_id': recipeId,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create saved recipe: ${response.body}');
      return false;
    }
  }

  Future<List<dynamic>> listSavedRecipes() async {
    final response = await http.get(Uri.parse('$_baseUrl/saved_recipes/'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to list saved recipes: ${response.body}');
      return [];
    }
  }

  Future<dynamic> getSavedRecipe(int savedRecipeId) async {
    final response = await http.get(Uri.parse('$_baseUrl/saved_recipes/$savedRecipeId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to get saved recipe: ${response.body}');
      return null;
    }
  }

  Future<bool> updateSavedRecipe(int savedRecipeId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/saved_recipes/$savedRecipeId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to update saved recipe: ${response.body}');
      return false;
    }
  }

  Future<bool> deleteSavedRecipe(int savedRecipeId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/saved_recipes/$savedRecipeId'));

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to delete saved recipe: ${response.body}');
      return false;
    }
  }
}