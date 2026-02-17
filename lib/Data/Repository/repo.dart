import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:google_generative_ai/google_generative_ai.dart';



abstract class HomePageRepository {

  Future<String> askAI(String prompt);

}



class HomePageRepo extends HomePageRepository {

  @override

  Future<String> askAI(String prompt) async {

    final apiKey = dotenv.env['token'];

    if (apiKey == null) {

      return "Error: API key not found. Please check your .env file.";

    }



    // List of models to try (in order of preference)

    // 1. Flash (Fastest, usually free)

    // 2. Pro (Smarter, good backup)

    // 3. 1.0 Pro (Old reliable)

    final modelsToTry = [
      'gemini-2.0-flash',           // 3. Standard 2.0 Flash  
      'gemini-2.0-pro-exp-02-05',   // 4. Experimental Pro (often wor
      'gemini-2.0-flash-lite',      // 1. Lite is fast & often has separate quota
      'gemini-flash-latest',        // 2. Your main driver (currently hitting limits)
      'gemini-flash-latest',
     // --- Newer / Best Models ---
      'gemini-2.5-flash',
      'gemini-2.5-pro',
      'gemini-2.0-flash',
      'gemini-2.0-flash-lite',
      'gemini-2.0-flash-001',
      'gemini-2.0-flash-lite-001',
      
      // --- Latest Aliases ---
      'gemini-flash-latest',
      'gemini-flash-lite-latest',
      'gemini-pro-latest',
      
      // --- Experimental / Previews ---
      'gemini-exp-1206',
      'gemini-2.5-flash-preview-09-2025',
      'gemini-2.5-flash-lite-preview-09-2025',
      'gemini-3-pro-preview',
      'gemini-3-flash-preview',
      'deep-research-pro-preview-12-2025',
      'gemini-2.5-computer-use-preview-10-2025',
      'gemini-robotics-er-1.5-preview',

      // --- Gemma Models (Open Weights) ---
      'gemma-3-27b-it',
      'gemma-3-12b-it',
      'gemma-3-4b-it',
      'gemma-3-1b-it',
      'gemma-3n-e4b-it',
      'gemma-3n-e2b-it',
      
      // --- Audio/TTS Models (Some support text-in/text-out) ---
      'gemini-2.5-flash-native-audio-latest',
      'gemini-2.5-flash-preview-tts',
      'gemini-2.5-pro-preview-tts',
     

    ];



    String lastError = "";



    for (final modelName in modelsToTry) {

      try {

        print("DEBUG: Trying model $modelName..."); // Debug print to see what's happening

       

        final model = GenerativeModel(

          model: modelName,

          apiKey: apiKey,

        );



        final content = [

          Content.text(

             "Role: You are a world-class Executive Chef. Create a detailed recipe based on this input: $prompt. "
              "\n\nSTRICT LANGUAGE RULE:\n"
              "1. If the input '$prompt' is in Roman Urdu/Hinglish (e.g., Pyaaz, Murghi, Adrak), provide the ENTIRE response (Title, Ingredients, and Method) in Roman Urdu.\n"
              "2. If the input '$prompt' is in English, provide the ENTIRE response in English.\n"
              "\nRequirements:\n"
              "- Ingredients List: Must match the detected language (e.g., 'Namak' for Urdu, 'Salt' for English).\n"
              "- Method: Provide professional cooking steps with chef secrets in bulits points.\n"
              "- Formatting: Use CPITAL headers. Do NOT use markdown code blocks like ``` or JSON.")

        ];



        final response = await model.generateContent(content);

       

        if (response.text != null && response.text!.isNotEmpty) {

          return response.text!; // Success! Return the recipe.

        }

      } catch (e) {

        print("DEBUG: Model $modelName failed: $e");

        lastError = e.toString();

        // Use 'continue' to try the next model in the list

        continue;

      }

    }



    // If all models fail, return the last error message

    return "Network Eeeor. Please check your internet and try again later.\nDetails: $lastError";

  }

}