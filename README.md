# Cd_automation Erp App

A secure and collaborative mobile + web-based system for managing and monitoring employee energy meter readings, built using Flutter, Flask, MySQL, Firebase and YOLO.

---

## 🔐 Security

- Each user device is authenticated using a unique *device ID*.
- Device IDs are stored in the database to prevent unauthorized access.
- Only registered devices can access authentication and usage features.

---

## 👥 User Roles

### 👤 Normal User
- Can submit *daily energy meter readings* only.

### 👨‍💼 Admin
- Manage employee profiles, meter details, and all readings.
- *Download monthly readings* as a *PDF* report.
- *Visualize data* using charts and detect anomalies.
- *Push notifications* (via *Firebase Cloud Messaging*) when abnormal readings are detected.

---

## 🛠 Tech Stack

| Tech         | Description                                 |
|--------------|---------------------------------------------|
| *Flutter*  | Mobile app development                      |
| *Flask*    | Python backend API                          |
| *MySQL*    | Relational database for users and readings  |
| *Firebase FCM* | Push notification service               |
| *YOLO Model* | Used for anomaly/meter detection tasks    |

---

## 🤝 Teamwork

This project was developed in *collaboration with a team*, focusing on integrating secure authentication, smart data handling, and real-time alerts into a unified platform.

---

## 📄 Features Summary

- ✅ Device-based secure login
- ✅ Daily meter reading submission
- ✅ Admin dashboard with charts and reports
- ✅ PDF export of monthly readings
- ✅ Real-time FCM notifications for anomalies
- ✅ YOLO-based visual detection (optional module)

---

Let me know if you want to add demo screenshots, GitHub deployment instructions, or .env setup.
