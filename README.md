# LiveStream Platform

A comprehensive live streaming platform built with Flutter and FastAPI, supporting multiple user roles including viewers, hosts, agents, agencies, and administrators.

## 🚀 Features

- **Multi-role System**: Support for users, hosts, agents, agencies, and admins
- **Live Streaming**: Real-time video streaming with WebSocket support
- **Virtual Economy**: Coin and gift system with real-time transactions
- **Gaming**: Integrated games with AI-powered balancing
- **Monetization**: In-app purchases and withdrawal system
- **Admin Dashboard**: Comprehensive management interface
- **Multi-region Support**: Country-specific branding and configurations

## 🛠 Tech Stack

- **Frontend**: Flutter
- **Backend**: FastAPI (Python)
- **Database**: MongoDB
- **Realtime**: WebSocket
- **Authentication**: JWT
- **Storage**: Firebase Storage / AWS S3
- **Payments**: Razorpay / Stripe
- **AI/ML**: Scikit-learn + custom models

## 📱 Screens

1. **Authentication**
   - Phone number login with OTP
   - Role-based access control

2. **User Flow**
   - Browse live streams
   - Send gifts to hosts
   - Play games
   - Manage wallet & transactions

3. **Host Flow**
   - Go live with camera/audio
   - View analytics
   - Manage earnings

4. **Admin Flow**
   - User management
   - Content moderation
   - Financial oversight
   - System configuration

## 🏗 Project Structure

```
lib/
├── core/
│   ├── constants/     # App constants and configurations
│   ├── routes/         # App routing
│   ├── theme/          # App theming
│   └── widgets/        # Reusable widgets
├── features/           # Feature modules
│   ├── auth/           # Authentication
│   ├── dashboard/      # Main dashboard
│   ├── live/           # Live streaming
│   ├── wallet/         # Wallet & transactions
│   └── ...
└── main.dart          # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (compatible with Flutter version)
- Android Studio / Xcode (for mobile development)
- VS Code / Android Studio (recommended IDEs)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/livestream_platform.git
   cd livestream_platform
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## 🔧 Configuration



1. Update `lib/core/constants/app_constants.dart` with your app-specific configurations.

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Team

- [Aadil]() - Project Lead

## 📝 Notes

- This is a work in progress. More features and improvements are coming soon!
- Feel free to submit issues and enhancement requests.
