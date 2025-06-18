# 🔁 PowerShell Reverse Proxy for API Redirection

This project provides a lightweight HTTP proxy written in **PowerShell 5.1**, designed to forward incoming API requests to an external endpoint. It's ideal for **restricted or isolated environments** where outbound access is blocked (e.g., development servers behind firewalls).

---

## ✅ Features

- 🟢 Listens on a configurable local port using `HttpListener`
- 🔁 Forwards `GET`, `POST`, and other HTTP methods
- 📦 Preserves request headers and request body
- 🔐 Automatically filters problematic headers (`Host`, `Connection`, `Keep-Alive`, etc.)
- 💻 Uses `Invoke-WebRequest` for maximum compatibility with PowerShell 5.1
- 📄 Returns full API responses to the original caller
- 🪵 Logs each request and response to the console

---

## 🛠 Use Case

You're working in a **development environment** that cannot directly access an external API (such as an OAuth2 token provider) due to network restrictions.  
This proxy can run on a **QA, staging, or relay server** that has the required internet access, and forward traffic from your dev machine transparently.

---

## 📦 Requirements

- Windows with PowerShell 5.1
- Outbound internet access from the server running the proxy
- Set `$tokenUrl` and `$serverPort` in the script to match your target

---

## ⚙️ Configuration

Inside the script:

```powershell
$tokenUrl = "https://external-api.domain.com"
$serverPort = 8032
