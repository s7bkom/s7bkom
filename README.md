# s7bkom

This repository contains two Flutter projects: `lucky_draw` and `lucky_draw_admin`.

## lucky_draw

A Flutter application for a lucky draw system.

### Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/s7bkom/s7bkom.git
    cd s7bkom/lucky_draw
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Configure Firebase:**
    *   Ensure you have a Firebase project set up.
    *   Create a `.env` file in the `lucky_draw/` directory with your Firebase credentials:
        ```
        FIREBASE_PROJECT_ID=your_firebase_project_id
        FIREBASE_API_KEY=your_firebase_api_key
        FIREBASE_APP_ID=your_firebase_app_id
        ```
    *   Set these environment variables in your system or CI/CD environment for Android builds.
4.  **Run the application:**
    ```bash
    flutter run
    ```

## lucky_draw_admin

A Flutter application for administering the lucky draw system.

### Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/s7bkom/s7bkom.git
    cd s7bkom/lucky_draw_admin
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Configure Firebase:**
    *   Ensure you have a Firebase project set up.
    *   Create a `.env` file in the `lucky_draw_admin/` directory with your Firebase credentials:
        ```
        FIREBASE_PROJECT_ID=your_admin_firebase_project_id
        FIREBASE_API_KEY=your_admin_firebase_api_key
        FIREBASE_APP_ID=your_admin_firebase_app_id
        FIREBASE_MESSAGING_SENDER_ID=your_admin_firebase_messaging_sender_id
        ```
    *   Set these environment variables in your system or CI/CD environment for Android builds.
4.  **Run the application:**
    ```bash
    flutter run
