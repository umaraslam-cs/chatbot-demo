![License](https://img.shields.io/badge/License-MIT-green)

# Car Showroom Chatbot

A Flutter-based chatbot application that provides information about car models, specifications, features, and pricing using OpenAI's GPT-4 API. This is a demo application that can be easily adapted for use in any field by modifying the system instructions in the OpenAI service.

## Features

- Real-time chat interface
- Stream-based responses for better user experience
- Detailed information about car models
- Technical specifications
- Features and options
- Pricing and availability
- Model comparisons

## Prerequisites

- Flutter SDK
- OpenAI API key
- Dart SDK

## Setup Instructions

1. Clone the repository:
```bash
git clone <https://github.com/umaraslam-cs/chatbot-demo.git>
cd chatbot-demo
```

2. Install dependencies:
```bash
flutter pub get
```

3. Create a `.env` file in the root directory of the project:
```bash
touch .env
```

4. Add your OpenAI API key to the `.env` file:
```
OPENAI_API_KEY=your_api_key_here
```

Replace `your_api_key_here` with your actual OpenAI API key. You can get an API key by:
1. Going to [OpenAI's platform](https://platform.openai.com)
2. Creating an account or signing in
3. Navigating to the API keys section
4. Creating a new API key

## Running the Application

1. Make sure you have set up your `.env` file with the API key
2. Run the application:
```bash
flutter run
```

## Important Notes

- Never commit your `.env` file to version control
- Keep your API key secure and don't share it publicly
- The chatbot uses GPT-4 model for generating responses
- The system is configured to provide car showroom-specific information

## Customization

The chatbot can be easily adapted for use in any field by modifying the system instructions in the `OpenAIService` class. The instructions are located in the `content` parameter of the system message in `lib/services/openai_service.dart`. Simply update the instructions to match your desired use case, and the chatbot will respond accordingly.

For example, to change it from a car showroom chatbot to a restaurant chatbot, you would modify the system instructions to include information about:
- Menu items and prices
- Operating hours
- Reservation policies
- Special offers
- Dietary restrictions
- And other restaurant-specific details

## Getting Started with Flutter

If you're new to Flutter, check out these resources:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Online documentation](https://docs.flutter.dev/)
