# SSL Pinning in iOS Using Swift and Alamofire

This repository demonstrates how to implement **SSL Pinning** in an iOS app using Swift. It provides a secure way to protect your app from man-in-the-middle (MITM) attacks by validating server certificates or public keys.

---

## What is SSL Pinning?

SSL Pinning is a security technique that ensures your app only communicates with trusted servers by verifying the server’s identity against a known certificate or public key embedded inside the app. This prevents interception or spoofing attacks, even if a certificate authority (CA) is compromised.

---

## Why Use SSL Pinning?

- Protects against MITM attacks.
- Prevents acceptance of fake or rogue certificates.
- Enhances security beyond standard HTTPS.

---

## How to Get Started

1. **Export your server’s certificate or public key**

   Use `openssl` commands (included in this repo's documentation) to export the server certificate in DER format or extract and hash the public key for pinning.

2. **Add the pinned certificate or public key hash to your app**

   Store these securely within your app to compare against the server during the TLS handshake.

3. **Use the provided Swift utilities and delegate classes**

   Implement SSL Pinning using the example utilities provided for both native `URLSession` and `Alamofire` networking.

---

## Features

- Certificate and Public Key pinning support.
- SHA256 hashing utility for keys.
- URLSessionDelegate and Alamofire SessionDelegate examples.
- Clear workflow for extracting and embedding pinned values.

---

## Repository Contents

- `SSLPinningUtility.swift` — Utility class for key hashing and validation.
- `URLSessionPinningDelegate.swift` — Example delegate for URLSession SSL Pinning.
- `AlamofirePinningDelegate.swift` — Example Alamofire delegate subclass for SSL Pinning.
- Documentation and OpenSSL commands for certificate and key extraction.

---

## Notes

- Prefer public key pinning to ease certificate renewals.
- Test thoroughly with both valid and invalid certificates.
- Handle connection failures gracefully to inform users.

---

## Additional Resources

- Full blog post with explanation: [Medium](https://medium.com/@sohanursagor56/how-to-implement-ssl-pinning-in-ios-using-urlsession-and-alamofire-82a841f40e23)

---

## License

This project is licensed under the MIT License.

---

## Author

Developed by Sohanur Rahman 
[Portfolio](https://devsohanur.github.io/)

---

**Secure your app beyond HTTPS—pin it down. 🔐**
